//
//  ChangePasswordViewModel.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-04.
//

import Foundation

@MainActor
public final class ChangePasswordViewModel: ObservableObject {

    @Published public var currentPassword = ""
    @Published public var newPassword = ""
    @Published public var passwordConfirmation = ""

    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?

    public var onChangePasswordSuccess: (() -> Void)?

    private let changePasswordUseCase: ChangePasswordUseCase

    public init(
        changePasswordUseCase: ChangePasswordUseCase
    ) {
        self.changePasswordUseCase = changePasswordUseCase
    }

    public func changePassword() {
        guard !currentPassword.isEmpty else {
            errorMessage = "현재 비밀번호를 입력해주세요."
            return
        }

        guard !newPassword.isEmpty else {
            errorMessage = "새 비밀번호를 입력해주세요."
            return
        }

        guard !passwordConfirmation.isEmpty else {
            errorMessage = "새 비밀번호를 한 번 더 입력해주세요."
            return
        }

        guard newPassword == passwordConfirmation else {
            errorMessage = "비밀번호가 일치하지 않습니다."
            return
        }

        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await changePasswordUseCase.execute(
                    currentPassword: currentPassword,
                    newPassword: newPassword
                )

                isLoading = false
                onChangePasswordSuccess?()
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
