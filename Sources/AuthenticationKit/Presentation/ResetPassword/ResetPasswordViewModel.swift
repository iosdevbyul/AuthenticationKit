import Foundation

@MainActor
public final class ResetPasswordViewModel: ObservableObject {
    @Published public var token: String
    @Published public var newPassword = ""
    @Published public var passwordConfirmation = ""
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var isSuccess = false
    public var onResetPasswordSuccess: (() -> Void)?
    private let authenticationService: AuthenticationService

    public init(token: String = "", authenticationService: AuthenticationService = .shared) {
        self.token = token
        self.authenticationService = authenticationService
    }

    public func resetPassword() {
        guard !isLoading else { return }
        guard !token.isEmpty, (7...20).contains(newPassword.count), newPassword.utf8.count <= 72 else {
            errorMessage = AuthL10n.string("validation.reset_password")
            return
        }
        guard newPassword == passwordConfirmation else {
            errorMessage = AuthL10n.string("validation.password.mismatch")
            return
        }
        isLoading = true
        errorMessage = nil
        isSuccess = false
        Task {
            do {
                try await authenticationService.resetPassword(token: token, newPassword: newPassword)
                isLoading = false
                isSuccess = true
                onResetPasswordSuccess?()
            } catch {
                isLoading = false
                errorMessage = AuthenticationErrorMessageMapper.message(for: error, context: .resetPassword)
            }
        }
    }
}
