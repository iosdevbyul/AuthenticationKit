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

    private let onLoginSuccess: ((Session) -> Void)?

    public init(
        viewModel: LoginViewModel = LoginViewModel(),
        theme: AuthenticationTheme = .default,
        onLoginSuccess: ((Session) -> Void)? = nil,
        onSignUp: (() -> Void)? = nil,
        onForgotPassword: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.theme = theme
        self.onLoginSuccess = onLoginSuccess
        self.onSignUp = onSignUp
        self.onForgotPassword = onForgotPassword

        viewModel.onLoginSuccess = onLoginSuccess
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                header

                VStack(spacing: 16) {
                    AuthenticationTextField(
                        title: AuthL10n.string("auth.email"),
                        placeholder: AuthL10n.string("auth.email.placeholder"),
                        text: $viewModel.email,
                        keyboardType: .emailAddress,
                        textContentType: .emailAddress,
                        autocapitalization: .none,
                        disableAutocorrection: true,
                        theme: theme
                    )

                    AuthenticationSecureField(
                        title: AuthL10n.string("auth.password"),
                        placeholder: AuthL10n.string("auth.password.placeholder"),
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
                    title: AuthL10n.string("auth.login"),
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
            Text(AuthL10n.string("auth.login"))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(theme.text)

            Text(AuthL10n.string("auth.login.subtitle"))
                .font(.subheadline)
                .foregroundColor(theme.secondaryText)
        }
        .padding(.top, 32)
    }

    private var forgotPasswordButton: some View {
        HStack {
            Spacer()

            Button {
                onForgotPassword?()
            } label: {
                Text(AuthL10n.string("auth.forgot_password.question"))
                    .font(.footnote)
                    .foregroundColor(theme.link)
            }
        }
    }

    private var signUpButton: some View {
        HStack(spacing: 4) {
            Text(AuthL10n.string("auth.no_account"))
                .font(.footnote)
                .foregroundColor(theme.secondaryText)

            Button {
                onSignUp?()
            } label: {
                Text(AuthL10n.string("auth.sign_up"))
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.link)
            }
        }
    }
}
