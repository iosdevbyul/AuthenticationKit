import Foundation
import Testing
import NetworkKit
@testable import AuthenticationKit

private final class VerificationClient: NetworkClient, @unchecked Sendable {
    var responses: [Result<Data, NetworkError>] = []
    var requests: [any Endpoint] = []

    func respond(_ json: String) { responses.append(.success(Data(json.utf8))) }
    func fail(_ status: Int) { responses.append(.failure(.serverError(status))) }

    func request<T: Decodable>(endpoint: any Endpoint, responseType: T.Type) async throws -> T {
        requests.append(endpoint)
        guard !responses.isEmpty else { throw NetworkError.invalidResponse }
        return try JSONDecoder().decode(T.self, from: responses.removeFirst().get())
    }
}

@MainActor
struct EmailVerificationTests {
    private let profile = #"{"id":"user","email":"user@example.com","isEmailVerified":true}"#
    private let session = #"{"user":{"id":"user","email":"user@example.com","isEmailVerified":false},"accessToken":"access","refreshToken":"refresh"}"#

    private func service(_ client: VerificationClient, storage: InMemoryTokenStorage = .init()) -> AuthenticationService {
        AuthenticationService(repository: NetworkAuthenticationRepository(networkClient: client), tokenStorage: storage)
    }

    @Test(arguments: [true, false])
    func sessionDTOsPreserveVerification(_ verified: Bool) throws {
        let json = session.replacingOccurrences(of: "false", with: String(verified))
        let login = try JSONDecoder().decode(LoginResponseDTO.self, from: Data(json.utf8)).toDomain()
        let signup = try JSONDecoder().decode(SignUpResponseDTO.self, from: Data(json.utf8)).toDomain()
        #expect(login.user.isEmailVerified == verified)
        #expect(signup.user.isEmailVerified == verified)
    }

    @Test
    func legacyStoredSessionStillDecodes() throws {
        let json = session.replacingOccurrences(of: ",\"isEmailVerified\":false", with: "")
        let decoded = try JSONDecoder().decode(Session.self, from: Data(json.utf8))
        #expect(!decoded.user.isEmailVerified)
        #expect(decoded.accessToken == "access")
        #expect(decoded.refreshToken == "refresh")
        let dto = try JSONDecoder().decode(LoginResponseDTO.self, from: Data(json.utf8))
        #expect(!dto.toDomain().user.isEmailVerified)
    }

    @Test
    func loginSignupRefreshAndCurrentUserPreserveStatusAndTokens() async throws {
        let client = VerificationClient()
        let storage = InMemoryTokenStorage()
        let service = service(client, storage: storage)
        client.respond(session)
        let signedUp = try await service.signUp(email: "user@example.com", password: "Password123")
        #expect(!signedUp.user.isEmailVerified)
        #expect(service.isAuthenticated)
        client.respond(session)
        let loggedIn = try await service.login(email: "user@example.com", password: "Password123")
        #expect(!loggedIn.user.isEmailVerified)
        client.respond(profile)
        let user = try await service.currentUser()
        #expect(user.isEmailVerified)
        #expect(service.currentSession?.user.isEmailVerified == true)
        #expect(service.currentSession?.accessToken == "access")
        #expect(service.currentSession?.refreshToken == "refresh")
        try service.restoreSession()
        #expect(service.currentSession?.user.isEmailVerified == true)
        client.respond(session.replacingOccurrences(of: "false", with: "true"))
        let refreshed = try await service.refreshSession()
        #expect(refreshed.user.isEmailVerified)
        #expect(try storage.loadSession() == refreshed)
        #expect(client.requests.map(\.path) == ["/auth/signup", "/auth/login", "/auth/me", "/auth/refresh"])
    }

    @Test
    func verifyWorksWithoutLoggingInAndEncodesOnlyToken() async throws {
        let client = VerificationClient()
        let service = service(client)
        client.respond(#"{"message":"이메일 인증이 완료되었습니다."}"#)
        try await service.verifyEmail(token: "verification-token")
        let endpoint = try #require(client.requests.last)
        #expect(endpoint.path == "/auth/verify-email")
        #expect(endpoint.method == .post)
        let data = try #require(endpoint.body)
        #expect(try JSONDecoder().decode([String: String].self, from: data) == ["token": "verification-token"])
        #expect(!service.isAuthenticated)
    }

    @Test(arguments: ["invalid-token", "expired-token"])
    func invalidOrExpiredTokenUsesSameSafeMessage(_ token: String) async {
        let client = VerificationClient()
        client.fail(400)
        let model = EmailVerificationViewModel(token: token, authenticationService: service(client))
        await model.verifyEmail()
        #expect(model.errorMessage == "인증 링크가 유효하지 않거나 만료되었습니다.")
        #expect(!model.didVerifyToken)
    }

    @Test
    func emptyTokenIsRejectedBeforeNetwork() async {
        let client = VerificationClient()
        let model = EmailVerificationViewModel(token: "", authenticationService: service(client))
        await model.verifyEmail()
        #expect(client.requests.isEmpty)
        #expect(model.errorMessage == "인증 링크가 유효하지 않거나 만료되었습니다.")
    }

    @Test
    func resendNormalizesEmailAndIgnoresServerMessage() async throws {
        let client = VerificationClient()
        client.respond(#"{"message":"arbitrary provider detail"}"#)
        let model = EmailVerificationViewModel(email: "  USER@Example.COM\n", authenticationService: service(client))
        await model.resendVerificationEmail()
        #expect(model.message == "가입된 이메일인 경우 인증 메일이 전송됩니다.")
        #expect(model.errorMessage == nil)
        let endpoint = try #require(client.requests.last)
        #expect(endpoint.path == "/auth/resend-verification-email")
        #expect(endpoint.method == .post)
        #expect(try JSONDecoder().decode([String: String].self, from: #require(endpoint.body)) == ["email": "user@example.com"])
    }

    @Test(arguments: [404, 409, 429])
    func resendDoesNotExposeAccountOrRateLimitStatus(_ status: Int) async {
        let client = VerificationClient()
        client.fail(status)
        let model = EmailVerificationViewModel(email: "user@example.com", authenticationService: service(client))
        await model.resendVerificationEmail()
        #expect(model.message == EmailVerificationViewModel.resendMessage)
        #expect(model.errorMessage == nil)
    }

    @Test
    func verificationRefreshesCurrentUserWithoutRotatingSession() async throws {
        let client = VerificationClient()
        let service = service(client)
        client.respond(session)
        _ = try await service.login(email: "user@example.com", password: "Password123")
        client.respond(#"{"message":"verified"}"#)
        client.respond(profile)
        let model = EmailVerificationViewModel(token: "token", authenticationService: service)
        var updated: User?
        model.onUserUpdated = { updated = $0 }
        await model.verifyEmail()
        #expect(model.didVerifyToken)
        #expect(model.isEmailVerified)
        #expect(updated?.isEmailVerified == true)
        #expect(service.currentSession?.accessToken == "access")
        let count = client.requests.count
        await model.verifyEmail()
        await model.resendVerificationEmail()
        #expect(client.requests.count == count)
    }

    @Test
    func profileRefreshFailureDoesNotRetryConsumedToken() async throws {
        let client = VerificationClient()
        let service = service(client)
        client.respond(session)
        _ = try await service.login(email: "user@example.com", password: "Password123")
        client.respond(#"{"message":"verified"}"#)
        client.fail(503)
        let model = EmailVerificationViewModel(token: "token", authenticationService: service)
        await model.verifyEmail()
        #expect(model.didVerifyToken)
        #expect(model.message == "이메일 인증이 완료되었습니다.")
        #expect(!model.isEmailVerified)
        client.respond(profile)
        await model.refreshUser()
        #expect(model.isEmailVerified)
        #expect(client.requests.filter { $0.path == "/auth/verify-email" }.count == 1)
    }

    @Test
    func staleUserDoesNotRestoreLoggedOutSessionOrReplaceAnotherUser() throws {
        let manager = SessionManager(tokenStorage: InMemoryTokenStorage())
        let original = Session(user: User(id: "user", email: "user@example.com"), accessToken: "access", refreshToken: "refresh")
        try manager.setSession(original)
        try manager.clearSession()
        try manager.updateUser(User(id: "user", email: "user@example.com", isEmailVerified: true), for: original)
        #expect(manager.currentSession == nil)
        try manager.setSession(original)
        try manager.updateUser(User(id: "other", email: "other@example.com", isEmailVerified: true), for: original)
        #expect(manager.currentSession == original)
    }

    @Test
    func deepLinkParsesTokenAndRejectsAmbiguousOrUnrelatedURLs() throws {
        let url = try #require(URL(string: "waktrainer://verify-email?token=abc"))
        let link = try #require(EmailVerificationLink(url: url))
        #expect(link.token == "abc")
        for raw in [
            "https://verify-email?token=abc", "other://verify-email?token=abc",
            "waktrainer://reset-password?token=abc", "waktrainer://verify-email",
            "waktrainer://verify-email?token=", "waktrainer://verify-email?token=a&token=b",
            "waktrainer://verify-email/extra?token=a"
        ] {
            #expect(EmailVerificationLink(url: try #require(URL(string: raw))) == nil)
        }
    }
}
