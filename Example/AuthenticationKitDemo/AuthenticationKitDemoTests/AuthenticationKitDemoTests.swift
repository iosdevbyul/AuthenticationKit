import XCTest
import AuthenticationKit
import NetworkKit
@testable import AuthenticationKitDemo

// Run only against WakTrainerServer started with --env testing (see E2E.md).
@MainActor
final class AuthenticationKitDemoTests: XCTestCase {
    private let baseURL = URL(string: "http://127.0.0.1:8080")!

    private func assertStatus(_ expected: Int, _ operation: () async throws -> Void) async {
        do {
            try await operation()
            XCTFail("Expected HTTP \(expected)")
        } catch NetworkError.serverError(let status) {
            XCTAssertEqual(status, expected)
        } catch { XCTFail("Unexpected error: \(error)") }
    }

    private func repository(token: String? = nil) -> NetworkAuthenticationRepository {
        let manager = SessionManager(tokenStorage: UserDefaultsTokenStorage(
            userDefaults: UserDefaults(suiteName: UUID().uuidString)!
        ))
        if let token {
            try! manager.setSession(Session(user: User(id: "unused", email: "unused"), accessToken: token))
        }
        return NetworkAuthenticationRepository(networkClient: URLSessionNetworkClient(
            configuration: NetworkConfiguration(baseURL: baseURL),
            interceptor: AuthorizationRequestInterceptor(tokenProvider: manager)
        ))
    }

    func testServerAuthenticationLifecycle() async throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: "AuthenticationKit.E2E." + UUID().uuidString))
        let storage = UserDefaultsTokenStorage(userDefaults: defaults)
        defer { try? storage.clear() }
        let service = AuthenticationService(baseURL: baseURL, tokenStorage: storage)
        let email = "e2e-" + UUID().uuidString + "@example.com"
        let password = "Password123!"
        let updatedPassword = "Updated456!"

        for invalid in ["123456", String(repeating: "a", count: 21)] {
            await assertStatus(400) { _ = try await service.signUp(email: email, password: invalid) }
        }
        // Both accepted policy boundaries are checked against PostgreSQL.
        for count in [7, 20] {
            let boundary = try await service.signUp(email: UUID().uuidString + "@example.com", password: String(repeating: "a", count: count))
            XCTAssertEqual(service.currentSession, boundary)
            try await service.withdraw()
        }
        let signedUp = try await service.signUp(email: email, password: password)
        XCTAssertEqual(signedUp.user.email, email)
        XCTAssertNotNil(UUID(uuidString: signedUp.user.id))
        XCTAssertEqual(signedUp.accessToken.split(separator: ".").count, 3)
        XCTAssertEqual(signedUp.refreshToken?.count, 64)
        XCTAssertEqual(service.currentSession, signedUp)
        XCTAssertEqual(try storage.loadSession(), signedUp)
        await assertStatus(409) { _ = try await service.signUp(email: email, password: password) }
        await assertStatus(401) { _ = try await service.login(email: email, password: "Wrong123!") }
        await assertStatus(401) { _ = try await service.login(email: UUID().uuidString + "@example.com", password: password) }
        let loggedIn = try await service.login(email: email, password: password)
        XCTAssertEqual(try storage.loadSession(), loggedIn)
        let restored = AuthenticationService(baseURL: baseURL, tokenStorage: storage)
        try restored.restoreSession()
        XCTAssertEqual(restored.currentSession, loggedIn)
        let me = try await restored.currentUser()
        XCTAssertEqual(me, loggedIn.user)
        await assertStatus(401) { _ = try await self.repository(token: loggedIn.accessToken + "x").currentUser() }

        let rotated = try await service.refreshSession()
        XCTAssertNotEqual(rotated.accessToken, loggedIn.accessToken)
        XCTAssertNotEqual(rotated.refreshToken, loggedIn.refreshToken)
        XCTAssertEqual(service.currentSession, rotated)
        XCTAssertEqual(try storage.loadSession(), rotated)
        await assertStatus(401) { _ = try await self.repository().refresh(refreshToken: try XCTUnwrap(loggedIn.refreshToken)) }
        await assertStatus(401) { _ = try await self.repository(token: loggedIn.accessToken).currentUser() }
        let rotatedUser = try await service.currentUser()
        XCTAssertEqual(rotatedUser, loggedIn.user)

        try await service.changePassword(currentPassword: password, newPassword: updatedPassword)
        XCTAssertNil(service.currentSession)
        XCTAssertNil(try storage.loadSession())
        await assertStatus(401) { _ = try await self.repository(token: rotated.accessToken).currentUser() }
        await assertStatus(401) { _ = try await self.repository().refresh(refreshToken: try XCTUnwrap(rotated.refreshToken)) }
        await assertStatus(401) { _ = try await service.login(email: email, password: password) }
        let updated = try await service.login(email: email, password: updatedPassword)
        try await service.logout()
        XCTAssertNil(service.currentSession)
        XCTAssertNil(try storage.loadSession())
        await assertStatus(401) { _ = try await service.currentUser() }
        await assertStatus(401) { _ = try await self.repository(token: updated.accessToken).currentUser() }
        await assertStatus(401) { _ = try await self.repository().refresh(refreshToken: try XCTUnwrap(updated.refreshToken)) }
        _ = try await service.login(email: email, password: updatedPassword)
        try await service.withdraw()
        XCTAssertNil(service.currentSession)
        XCTAssertNil(try storage.loadSession())
        await assertStatus(401) { _ = try await service.login(email: email, password: updatedPassword) }
        // Unknown users receive success without revealing account existence or sending mail.
        try await service.forgotPassword(email: email)
    }

    func testResetPasswordWithPostgresFixture() async throws {
        // Random, disposable values are supplied by the local fixture runner, never committed.
        // This proves the real reset endpoint; inbox delivery is a separate manual check.
        let env = ProcessInfo.processInfo.environment
        let email = try XCTUnwrap(env["E2E_RESET_EMAIL"])
        let oldPassword = try XCTUnwrap(env["E2E_RESET_PASSWORD"])
        let token = try XCTUnwrap(env["E2E_RESET_TOKEN"])
        let expiredToken = try XCTUnwrap(env["E2E_EXPIRED_TOKEN"])
        let service = AuthenticationService(baseURL: baseURL, tokenStorage: UserDefaultsTokenStorage(
            userDefaults: UserDefaults(suiteName: UUID().uuidString)!
        ))
        let oldSession = try await service.login(email: email, password: oldPassword)
        await assertStatus(400) { try await service.resetPassword(token: expiredToken, newPassword: "Expired123!") }
        let newPassword = "ResetPassword789!"
        try await service.resetPassword(token: token, newPassword: newPassword)
        XCTAssertNil(service.currentSession)
        await assertStatus(400) { try await service.resetPassword(token: token, newPassword: oldPassword) }
        await assertStatus(401) { _ = try await service.login(email: email, password: oldPassword) }
        await assertStatus(401) { _ = try await self.repository(token: oldSession.accessToken).currentUser() }
        await assertStatus(401) { _ = try await self.repository().refresh(refreshToken: try XCTUnwrap(oldSession.refreshToken)) }
        _ = try await service.login(email: email, password: newPassword)
        try await service.withdraw()
    }
}
