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
        viewModel: ForgotPasswordViewModel,
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
                    title: "이메일",
                    placeholder: "가입한 이메일을 입력해주세요.",
                    text: $viewModel.email,
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
                    title: "비밀번호 재설정",
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
            Text("비밀번호 찾기")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(theme.text)

            Text("가입한 이메일로 비밀번호 재설정 안내를 보내드립니다.")
                .font(.subheadline)
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 32)
    }

    private var successMessage: some View {
        Text("비밀번호 재설정 안내를 이메일로 보내드렸습니다.")
            .font(.footnote)
            .foregroundColor(theme.primary)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
    }
}
