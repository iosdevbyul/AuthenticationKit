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
            SecureField(AuthL10n.string("auth.reset.token"), text: $viewModel.token)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            SecureField(AuthL10n.string("auth.reset.new_password"), text: $viewModel.newPassword)
            SecureField(AuthL10n.string("auth.reset.confirm_password"), text: $viewModel.passwordConfirmation)
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }
            if viewModel.isSuccess {
                Text(AuthL10n.string("auth.reset.success"))
            }
            Button(AuthL10n.string("auth.reset_password")) { viewModel.resetPassword() }
                .disabled(viewModel.isLoading)
        }
        .navigationTitle(AuthL10n.string("auth.reset_password"))
    }
}
