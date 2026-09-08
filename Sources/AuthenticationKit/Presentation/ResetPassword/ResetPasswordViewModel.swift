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
            errorMessage = "재설정 토큰과 7~20자의 새 비밀번호를 입력해주세요."
            return
        }
        guard newPassword == passwordConfirmation else {
            errorMessage = "비밀번호가 일치하지 않습니다."
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
                errorMessage = error.localizedDescription
            }
        }
    }
}
