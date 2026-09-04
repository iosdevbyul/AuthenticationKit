//
//  SignUpView.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-04.
//

import SwiftUI

public struct SignUpView: View {

    @ObservedObject private var viewModel: SignUpViewModel
    private let theme: AuthenticationTheme

    private let onSignUpSuccess: ((Session) -> Void)?

    public init(
        viewModel: SignUpViewModel,
        theme: AuthenticationTheme = .default,
        onSignUpSuccess: ((Session) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.theme = theme
        self.onSignUpSuccess = onSignUpSuccess
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                header

                VStack(spacing: 16) {
                    AuthenticationTextField(
                        title: "이메일",
                        placeholder: "이메일을 입력해주세요.",
                        text: $viewModel.email,
                        theme: theme
                    )

                    AuthenticationSecureField(
                        title: "비밀번호",
                        placeholder: "비밀번호를 입력해주세요.",
                        text: $viewModel.password,
                        theme: theme
                    )

                    AuthenticationSecureField(
                        title: "비밀번호 확인",
                        placeholder: "비밀번호를 다시 입력해주세요.",
                        text: $viewModel.passwordConfirmation,
                        theme: theme
                    )
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(theme.error)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                }

                AuthenticationButton(
                    title: "회원가입",
                    isEnabled: canSignUp,
                    isLoading: viewModel.isLoading,
                    theme: theme
                ) {
                    viewModel.signUp()
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .background(theme.background)
        .onAppear {
            viewModel.onSignUpSuccess = onSignUpSuccess
        }
    }

    private var canSignUp: Bool {
        !viewModel.email.isEmpty
            && !viewModel.password.isEmpty
            && !viewModel.passwordConfirmation.isEmpty
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("회원가입")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(theme.text)

            Text("계정을 만들어주세요.")
                .font(.subheadline)
                .foregroundColor(theme.secondaryText)
        }
        .padding(.top, 32)
    }
}
