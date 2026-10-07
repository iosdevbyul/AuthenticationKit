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
            errorMessage = AuthL10n.string("validation.email_password.required")
            return
        }

        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let normalizedEmail = email
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased()

                let session = try await authenticationService.login(
                    email: normalizedEmail,
                    password: password
                )

                isLoading = false
                onLoginSuccess?(session)

            } catch {
                isLoading = false
                errorMessage = AuthenticationErrorMessageMapper.message(
                    for: error,
                    context: .login
                )
            }
        }
    }
}
