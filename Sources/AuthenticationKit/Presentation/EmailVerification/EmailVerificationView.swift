import SwiftUI

/// The host owns the observable model, just as with LoginView and ForgotPasswordView.
public struct EmailVerificationView: View {
    @ObservedObject private var viewModel: EmailVerificationViewModel
    private let theme: AuthenticationTheme

    public init(viewModel: EmailVerificationViewModel,
                theme: AuthenticationTheme = .default) {
        self.viewModel = viewModel
        self.theme = theme
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(viewModel.isEmailVerified ? AuthL10n.string("auth.email_verification.complete_title") : AuthL10n.string("auth.email_verification.title"))
                    .font(.title).fontWeight(.bold).foregroundColor(theme.text)

                if viewModel.hasVerificationToken {
                    Text(AuthL10n.string("auth.email_verification.instruction"))
                        .foregroundColor(theme.secondaryText)
                    action(AuthL10n.string("auth.email_verification.complete")) {
                        await viewModel.verifyEmail()
                    }
                }

                if !viewModel.isEmailVerified {
                    Text(AuthL10n.string("auth.email_verification.optional"))
                        .font(.subheadline).foregroundColor(theme.secondaryText)
                    AuthenticationTextField(
                        title: AuthL10n.string("auth.email"), placeholder: AuthL10n.string("auth.email.placeholder"),
                        text: $viewModel.email, keyboardType: .emailAddress,
                        textContentType: .emailAddress, autocapitalization: .none,
                        disableAutocorrection: true, theme: theme
                    )
                    action(AuthL10n.string("auth.email_verification.resend")) {
                        await viewModel.resendVerificationEmail()
                    }
                }

                if viewModel.canRefreshUser {
                    action(AuthL10n.string("auth.email_verification.refresh")) {
                        await viewModel.refreshUser()
                    }
                }

                if let message = viewModel.message {
                    Text(message).font(.footnote).foregroundColor(theme.primary)
                }
                if let error = viewModel.errorMessage {
                    Text(error).font(.footnote).foregroundColor(theme.error)
                }
            }
            .padding(24)
        }
        .background(theme.background)
    }

    private func action(_ title: String, perform: @escaping @MainActor () async -> Void) -> some View {
        Button(action: { Task { await perform() } }) {
            Text(viewModel.isLoading ? AuthL10n.string("auth.processing") : title)
                .font(.headline)
                .foregroundColor(theme.button.foreground)
                .frame(maxWidth: .infinity).frame(height: 52)
        }
        .background(viewModel.isLoading ? theme.button.disabled : theme.button.background)
        .cornerRadius(10)
        .disabled(viewModel.isLoading)
    }
}
