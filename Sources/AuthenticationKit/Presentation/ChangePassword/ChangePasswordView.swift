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
        viewModel: ChangePasswordViewModel,
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
                        title: "현재 비밀번호",
                        placeholder: "현재 비밀번호를 입력해주세요.",
                        text: $viewModel.currentPassword,
                        theme: theme
                    )

                    AuthenticationSecureField(
                        title: "새 비밀번호",
                        placeholder: "새 비밀번호를 입력해주세요.",
                        text: $viewModel.newPassword,
                        theme: theme
                    )

                    AuthenticationSecureField(
                        title: "새 비밀번호 확인",
                        placeholder: "새 비밀번호를 다시 입력해주세요.",
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
                    title: "비밀번호 변경",
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
            Text("비밀번호 변경")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(theme.text)

            Text("새로운 비밀번호를 입력해주세요.")
                .font(.subheadline)
                .foregroundColor(theme.secondaryText)
        }
        .padding(.top, 32)
    }
}
