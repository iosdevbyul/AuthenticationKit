import Foundation
import Combine
import NetworkKit

@MainActor
public final class EmailVerificationViewModel: ObservableObject {
    public static var resendMessage: String { AuthL10n.string("error.verification_privacy") }

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
            message = AuthL10n.string("auth.email_verification.completed")
        } catch {
            errorMessage = AuthenticationErrorMessageMapper.message(for: error, context: .verifyEmail)
            return
        }
        // A profile refresh failure does not make a consumed verification token invalid.
        if authenticationService.isAuthenticated {
            do { try await updateCurrentUser() }
            catch {
                errorMessage = AuthL10n.string("auth.email_verification.refresh_failed")
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
            message = isEmailVerified\n                ? AuthL10n.string("auth.email_verification.completed")\n                : AuthL10n.string("auth.email_verification.not_verified")
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
