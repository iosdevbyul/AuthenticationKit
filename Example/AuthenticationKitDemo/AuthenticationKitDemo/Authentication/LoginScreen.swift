//
//  LoginScreen.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

private struct LoginScreen: View {

    let onAuthenticated: (Session) -> Void

    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack(spacing: 24) {
            LoginView(
                viewModel: viewModel,
                onLoginSuccess: onAuthenticated
            )

            VStack(spacing: 16) {
                NavigationLink {
                    SignUpScreen(
                        onAuthenticated: onAuthenticated
                    )
                } label: {
                    Text("계정이 없으신가요? 회원가입")
                }

                NavigationLink {
                    ForgotPasswordScreen()
                } label: {
                    Text("비밀번호를 잊으셨나요?")
                }
            }
            .padding(.bottom, 32)
        }
    }
}
