//
//  LoginViewModel.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-03.
//

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

    private let authenticationService: AuthenticationService

    public init(
        authenticationService: AuthenticationService = .shared
    ) {
        self.authenticationService = authenticationService
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
                let session = try await authenticationService.login(
                    email: email,
                    password: password
                )

                isLoading = false
                onLoginSuccess?(session)

            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
