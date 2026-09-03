//
//  SignUpViewModel.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-04.
//

import Foundation

@MainActor
public final class SignUpViewModel: ObservableObject {

    @Published public var email = ""
    @Published public var password = ""
    @Published public var passwordConfirmation = ""

    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?

    public var onSignUpSuccess: ((Session) -> Void)?

    private let signUpUseCase: SignUpUseCase

    public init(signUpUseCase: SignUpUseCase) {
        self.signUpUseCase = signUpUseCase
    }

    public func signUp() {
        guard !email.isEmpty else {
            errorMessage = "이메일을 입력해주세요."
            return
        }

        guard !password.isEmpty else {
            errorMessage = "비밀번호를 입력해주세요."
            return
        }

        guard !passwordConfirmation.isEmpty else {
            errorMessage = "비밀번호를 한 번 더 입력해주세요."
            return
        }

        guard password == passwordConfirmation else {
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
                let session = try await signUpUseCase.execute(
                    email: email,
                    password: password
                )

                isLoading = false
                onSignUpSuccess?(session)
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
