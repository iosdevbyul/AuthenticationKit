import SwiftUI

@available(iOS 17.0, *)
public struct ResetPasswordView: View {
    @StateObject private var viewModel: ResetPasswordViewModel

    public init(token: String = "", onResetPasswordSuccess: (() -> Void)? = nil) {
        let model = ResetPasswordViewModel(token: token)
        model.onResetPasswordSuccess = onResetPasswordSuccess
        _viewModel = StateObject(wrappedValue: model)
    }

    public var body: some View {
        Form {
            SecureField("재설정 토큰", text: $viewModel.token)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            SecureField("새 비밀번호 (7~20자)", text: $viewModel.newPassword)
            SecureField("새 비밀번호 확인", text: $viewModel.passwordConfirmation)
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }
            if viewModel.isSuccess {
                Text("비밀번호가 재설정되었습니다. 새 비밀번호로 로그인해주세요.")
            }
            Button("비밀번호 재설정") { viewModel.resetPassword() }
                .disabled(viewModel.isLoading)
        }
        .navigationTitle("Reset Password")
    }
}
