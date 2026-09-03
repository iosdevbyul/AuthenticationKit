//
//  LoginViewModel.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-03.
//

import Foundation

@MainActor
public final class LoginViewModel: ObservableObject {

    @Published public var email = ""
    @Published public var password = ""
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?

    private let loginUseCase: LoginUseCase

    public init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }

    public func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "이메일과 비밀번호를 입력해주세요."
            return
        }

        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                _ = try await loginUseCase.execute(
                    email: email,
                    password: password
                )

                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
