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
                Text(viewModel.isEmailVerified ? "이메일 인증 완료" : "이메일 인증")
                    .font(.title).fontWeight(.bold).foregroundColor(theme.text)

                if viewModel.hasVerificationToken {
                    Text("메일 링크의 이메일 인증을 완료해주세요.")
                        .foregroundColor(theme.secondaryText)
                    action("이메일 인증 완료하기") {
                        await viewModel.verifyEmail()
                    }
                }

                if !viewModel.isEmailVerified {
                    Text("이메일을 인증하지 않아도 로그인과 앱 이용은 계속할 수 있습니다.")
                        .font(.subheadline).foregroundColor(theme.secondaryText)
                    AuthenticationTextField(
                        title: "이메일", placeholder: "이메일을 입력해주세요.",
                        text: $viewModel.email, keyboardType: .emailAddress,
                        textContentType: .emailAddress, autocapitalization: .none,
                        disableAutocorrection: true, theme: theme
                    )
                    action("인증 메일 재전송") {
                        await viewModel.resendVerificationEmail()
                    }
                }

                if viewModel.canRefreshUser {
                    action("인증 상태 확인") {
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
            Text(viewModel.isLoading ? "처리 중…" : title)
                .font(.headline)
                .foregroundColor(theme.button.foreground)
                .frame(maxWidth: .infinity).frame(height: 52)
        }
        .background(viewModel.isLoading ? theme.button.disabled : theme.button.background)
        .cornerRadius(10)
        .disabled(viewModel.isLoading)
    }
}
