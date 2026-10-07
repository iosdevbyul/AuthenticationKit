//
//  ForgotPasswordView.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-04.
//

import SwiftUI

public struct ForgotPasswordView: View {

    @ObservedObject private var viewModel: ForgotPasswordViewModel

    private let theme: AuthenticationTheme
    private let onForgotPasswordSuccess: (() -> Void)?

    public init(
        viewModel: ForgotPasswordViewModel = ForgotPasswordViewModel(),
        theme: AuthenticationTheme = .default,
        onForgotPasswordSuccess: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.theme = theme
        self.onForgotPasswordSuccess = onForgotPasswordSuccess

        viewModel.onForgotPasswordSuccess = onForgotPasswordSuccess
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                header

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

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(theme.error)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                }

                if viewModel.isSuccess {
                    successMessage
                }

                AuthenticationButton(
                    title: AuthL10n.string("auth.reset_password"),
                    isEnabled: !viewModel.email.isEmpty,
                    isLoading: viewModel.isLoading,
                    theme: theme
                ) {
                    viewModel.forgotPassword()
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .background(theme.background)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(AuthL10n.string("auth.forgot_password.title"))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(theme.text)

            Text(AuthL10n.string("auth.forgot_password.subtitle"))
                .font(.subheadline)
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 32)
    }

    private var successMessage: some View {
        Text(AuthL10n.string("auth.forgot_password.success"))
            .font(.footnote)
            .foregroundColor(theme.primary)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
    }
}
