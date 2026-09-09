import Foundation
import Combine
import NetworkKit

@MainActor
public final class EmailVerificationViewModel: ObservableObject {
    public static let resendMessage = "가입된 이메일인 경우 인증 메일이 전송됩니다."

    @Published public var email: String
    @Published public private(set) var isEmailVerified: Bool
    @Published public private(set) var isLoading = false
    @Published public private(set) var message: String?
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var didVerifyToken = false
    public var onUserUpdated: ((User) -> Void)?

    private var token: String?
    private let authenticationService: AuthenticationService

    public var hasVerificationToken: Bool { token != nil }
    public var canRefreshUser: Bool { authenticationService.isAuthenticated }

    public init(email: String = "", token: String? = nil,
                authenticationService: AuthenticationService = .shared) {
        self.authenticationService = authenticationService
        self.email = email.isEmpty ? authenticationService.currentSession?.user.email ?? "" : email
        self.token = token
        self.isEmailVerified = authenticationService.currentSession?.user.isEmailVerified ?? false
    }

    public func verifyEmail() async {
        guard !isLoading, !didVerifyToken else { return }
        isLoading = true
        message = nil
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await authenticationService.verifyEmail(token: token ?? "")
            token = nil
            didVerifyToken = true
            message = "이메일 인증이 완료되었습니다."
        } catch {
            errorMessage = AuthenticationErrorMessageMapper.message(for: error, context: .verifyEmail)
            return
        }
        // A profile refresh failure does not make a consumed verification token invalid.
        if authenticationService.isAuthenticated {
            do { try await updateCurrentUser() }
            catch {
                errorMessage = "인증은 완료되었지만 상태를 갱신하지 못했습니다. 다시 확인해주세요."
            }
        }
    }

    public func resendVerificationEmail() async {
        guard !isLoading, !isEmailVerified else { return }
        isLoading = true
        message = nil
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await authenticationService.resendVerificationEmail(email: email)
            message = Self.resendMessage
        } catch let error as NetworkError {
            // Never turn account existence or throttling hints into a UI distinction.
            if case .serverError(let status) = error, [404, 409, 429].contains(status) {
                message = AuthenticationErrorMessageMapper.message(for: error, context: .resendVerificationEmail)
            } else {
                errorMessage = AuthenticationErrorMessageMapper.message(for: error, context: .resendVerificationEmail)
            }
        } catch {
            errorMessage = AuthenticationErrorMessageMapper.message(for: error, context: .resendVerificationEmail)
        }
    }

    public func refreshUser() async {
        guard !isLoading, authenticationService.isAuthenticated else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await updateCurrentUser()
            message = isEmailVerified ? "이메일 인증이 완료되었습니다." : "아직 이메일 인증이 확인되지 않았습니다."
        } catch {
            errorMessage = AuthenticationErrorMessageMapper.message(for: error, context: .session)
        }
    }

    private func updateCurrentUser() async throws {
        let user = try await authenticationService.currentUser()
        guard authenticationService.currentSession?.user.id == user.id else { return }
        isEmailVerified = user.isEmailVerified
        onUserUpdated?(user)
    }
}
