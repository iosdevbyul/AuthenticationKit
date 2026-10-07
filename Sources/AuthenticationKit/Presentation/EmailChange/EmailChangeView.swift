//
//  EmailChangeView.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-11.
//

import SwiftUI

public struct EmailChangeView: View {

    @ObservedObject private var viewModel: EmailChangeViewModel
    private let theme: AuthenticationTheme

    public init(
        viewModel: EmailChangeViewModel,
        theme: AuthenticationTheme = .default
    ) {
        self.viewModel = viewModel
        self.theme = theme
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                Text(
                    viewModel.hasConfirmationToken
                    ? AuthL10n.string("auth.email_change.confirm_title")
                    : AuthL10n.string("auth.email_change.title")
                )
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(theme.text)

                if viewModel.hasConfirmationToken {
                    confirmationContent
                } else {
                    requestContent
                }

                if let message = viewModel.message {
                    Text(message)
                        .font(.footnote)
                        .foregroundColor(theme.primary)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(theme.error)
                }
            }
            .padding(24)
        }
        .background(theme.background)
    }

    private var requestContent: some View {
        VStack(spacing: 16) {

            AuthenticationSecureField(
                title: AuthL10n.string("auth.change.current_password"),
                placeholder: AuthL10n.string("auth.change.current_password.placeholder"),
                text: $viewModel.currentPassword,
                theme: theme
            )

            AuthenticationTextField(
                title: AuthL10n.string("auth.email_change.new_email"),
                placeholder: AuthL10n.string("auth.email_change.new_email.placeholder"),
                text: $viewModel.newEmail,
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .none,
                disableAutocorrection: true,
                theme: theme
            )

            actionButton(AuthL10n.string("auth.email_change.request")) {
                await viewModel.requestEmailChange()
            }
        }
    }

    private var confirmationContent: some View {
        VStack(spacing: 16) {

            Text(AuthL10n.string("auth.email_change.confirm_message"))
                .font(.subheadline)
                .foregroundColor(theme.secondaryText)

            actionButton(AuthL10n.string("auth.email_change.complete")) {
                await viewModel.confirmEmailChange()
            }
        }
    }

    private func actionButton(
        _ title: String,
        perform: @escaping @MainActor () async -> Void
    ) -> some View {
        Button {
            Task {
                await perform()
            }
        } label: {
            Text(viewModel.isLoading ? AuthL10n.string("auth.processing") : title)
                .font(.headline)
                .foregroundColor(theme.button.foreground)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
        }
        .background(
            viewModel.isLoading
            ? theme.button.disabled
            : theme.button.background
        )
        .cornerRadius(10)
        .disabled(viewModel.isLoading)
    }
}
