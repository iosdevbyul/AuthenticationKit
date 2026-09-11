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
                    ? "이메일 변경 확인"
                    : "이메일 변경"
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
                title: "현재 비밀번호",
                placeholder: "현재 비밀번호를 입력해주세요.",
                text: $viewModel.currentPassword,
                textContentType: .password,
                theme: theme
            )

            AuthenticationTextField(
                title: "새 이메일",
                placeholder: "새 이메일을 입력해주세요.",
                text: $viewModel.newEmail,
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .none,
                disableAutocorrection: true,
                theme: theme
            )

            actionButton("이메일 변경 요청") {
                await viewModel.requestEmailChange()
            }
        }
    }

    private var confirmationContent: some View {
        VStack(spacing: 16) {

            Text("새 이메일 주소로 변경을 완료합니다.")
                .font(.subheadline)
                .foregroundColor(theme.secondaryText)

            actionButton("이메일 변경 완료하기") {
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
            Text(viewModel.isLoading ? "처리 중…" : title)
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
