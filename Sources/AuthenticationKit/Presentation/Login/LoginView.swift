//
//  LoginView.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-01.
//

import SwiftUI

public struct LoginView: View {

    @ObservedObject private var viewModel: LoginViewModel
    private let theme: AuthenticationTheme

    private let onSignUp: (() -> Void)?
    private let onForgotPassword: (() -> Void)?

//    @State private var isPasswordVisible = false

    public init(
        viewModel: LoginViewModel,
        theme: AuthenticationTheme = .default,
        onSignUp: (() -> Void)? = nil,
        onForgotPassword: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.theme = theme
        self.onSignUp = onSignUp
        self.onForgotPassword = onForgotPassword
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

//                    passwordField
                    AuthenticationSecureField(
                        title: "비밀번호",
                        placeholder: "비밀번호를 입력해주세요.",
                        text: $viewModel.password,
                        theme: theme
                    )
                }

                forgotPasswordButton

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(theme.error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                AuthenticationButton(
                    title: "로그인",
                    isEnabled: !viewModel.email.isEmpty
                        && !viewModel.password.isEmpty,
                    isLoading: viewModel.isLoading,
                    theme: theme
                ) {
                    viewModel.login()
                }

                signUpButton
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .background(theme.background)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("로그인")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(theme.text)

            Text("계정에 로그인해주세요.")
                .font(.subheadline)
                .foregroundColor(theme.secondaryText)
        }
        .padding(.top, 32)
    }

//    private var passwordField: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("비밀번호")
//                .font(.subheadline)
//                .foregroundColor(theme.text)
//
//            HStack(spacing: 8) {
//                Group {
//                    if isPasswordVisible {
//                        TextField(
//                            "비밀번호를 입력해주세요.",
//                            text: $viewModel.password
//                        )
//                    } else {
//                        SecureField(
//                            "비밀번호를 입력해주세요.",
//                            text: $viewModel.password
//                        )
//                    }
//                }
//                .foregroundColor(theme.textField.text)
//
//                Button {
//                    isPasswordVisible.toggle()
//                } label: {
//                    Image(
//                        systemName: isPasswordVisible
//                            ? "eye.slash"
//                            : "eye"
//                    )
//                    .foregroundColor(theme.secondaryText)
//                }
//            }
//            .padding(.horizontal, 16)
//            .frame(height: 52)
//            .background(theme.textField.background)
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(
//                        theme.textField.border,
//                        lineWidth: 1
//                    )
//            )
//        }
//    }

    private var forgotPasswordButton: some View {
        HStack {
            Spacer()

            Button {
                onForgotPassword?()
            } label: {
                Text("비밀번호를 잊으셨나요?")
                    .font(.footnote)
                    .foregroundColor(theme.link)
            }
        }
    }

    private var signUpButton: some View {
        HStack(spacing: 4) {
            Text("계정이 없으신가요?")
                .font(.footnote)
                .foregroundColor(theme.secondaryText)

            Button {
                onSignUp?()
            } label: {
                Text("회원가입")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.link)
            }
        }
    }
}
