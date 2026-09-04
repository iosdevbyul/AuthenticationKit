//
//  ForgotPasswordViewModel.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-04.
//

import Foundation

@MainActor
public final class ForgotPasswordViewModel: ObservableObject {

    @Published public var email = ""

    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var isSuccess = false

    public var onForgotPasswordSuccess: (() -> Void)?

    private let forgotPasswordUseCase: ForgotPasswordUseCase

    public init(
        forgotPasswordUseCase: ForgotPasswordUseCase
    ) {
        self.forgotPasswordUseCase = forgotPasswordUseCase
    }

    public func forgotPassword() {
        guard !email.isEmpty else {
            errorMessage = "이메일을 입력해주세요."
            return
        }

        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil
        isSuccess = false

        Task {
            do {
                try await forgotPasswordUseCase.execute(
                    email: email
                )

                isLoading = false
                isSuccess = true
                onForgotPasswordSuccess?()
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
