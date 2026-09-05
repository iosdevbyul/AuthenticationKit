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

    public var onLoginSuccess: ((Session) -> Void)?

    private let loginUseCase: LoginUseCase

    public init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }

    public func login() {
        print("LoginViewModel.login() called")
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "이메일과 비밀번호를 입력해주세요."
            return
        }

        guard !isLoading else {
            return
        }
        print("LoginViewModel.login() isLoading")
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let session = try await loginUseCase.execute(
                    email: email,
                    password: password
                )
                print("LoginViewModel.login() Task")
                isLoading = false
                onLoginSuccess?(session)
            } catch {
                print("LoginViewModel.login() errorMessage")
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
