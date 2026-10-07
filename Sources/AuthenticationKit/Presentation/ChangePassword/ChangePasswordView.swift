//
//  ChangePasswordView.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-04.
//

import SwiftUI

public struct ChangePasswordView: View {

    @ObservedObject private var viewModel: ChangePasswordViewModel

    private let theme: AuthenticationTheme
    private let onChangePasswordSuccess: (() -> Void)?

    public init(
        viewModel: ChangePasswordViewModel = ChangePasswordViewModel(),
        theme: AuthenticationTheme = .default,
        onChangePasswordSuccess: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.theme = theme
        self.onChangePasswordSuccess = onChangePasswordSuccess

        viewModel.onChangePasswordSuccess = onChangePasswordSuccess
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                header

                VStack(spacing: 16) {
                    AuthenticationSecureField(
                        title: AuthL10n.string("auth.change.current_password"),
                        placeholder: AuthL10n.string("auth.change.current_password.placeholder"),
                        text: $viewModel.currentPassword,
                        theme: theme
                    )

                    AuthenticationSecureField(
                        title: AuthL10n.string("auth.change.new_password"),
                        placeholder: AuthL10n.string("auth.change.new_password.placeholder"),
                        text: $viewModel.newPassword,
                        theme: theme
                    )

                    AuthenticationSecureField(
                        title: AuthL10n.string("auth.change.confirm_password"),
                        placeholder: AuthL10n.string("auth.change.confirm_password.placeholder"),
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
                    title: AuthL10n.string("auth.change.title"),
                    isEnabled: canChangePassword,
                    isLoading: viewModel.isLoading,
                    theme: theme
                ) {
                    viewModel.changePassword()
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .background(theme.background)
    }

    private var canChangePassword: Bool {
        !viewModel.currentPassword.isEmpty
            && !viewModel.newPassword.isEmpty
            && !viewModel.passwordConfirmation.isEmpty
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(AuthL10n.string("auth.change.title"))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(theme.text)

            Text(AuthL10n.string("auth.change.subtitle"))
                .font(.subheadline)
                .foregroundColor(theme.secondaryText)
        }
        .padding(.top, 32)
    }
}
