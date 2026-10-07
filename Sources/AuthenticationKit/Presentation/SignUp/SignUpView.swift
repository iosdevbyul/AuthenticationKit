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
        viewModel: SignUpViewModel = SignUpViewModel(),
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

                    AuthenticationSecureField(
                        title: AuthL10n.string("auth.password.confirm"),
                        placeholder: AuthL10n.string("auth.password.confirm.placeholder"),
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
                    title: AuthL10n.string("auth.sign_up"),
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
            Text(AuthL10n.string("auth.sign_up"))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(theme.text)

            Text(AuthL10n.string("auth.sign_up.subtitle"))
                .font(.subheadline)
                .foregroundColor(theme.secondaryText)
        }
        .padding(.top, 32)
    }
}
