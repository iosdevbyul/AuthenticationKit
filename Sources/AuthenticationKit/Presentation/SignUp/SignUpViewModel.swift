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

    private let authenticationService: AuthenticationService

    public init(
        authenticationService: AuthenticationService = .shared
    ) {
        self.authenticationService = authenticationService
    }

    public func signUp() {
        let normalizedEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !normalizedEmail.isEmpty else {
            errorMessage = AuthL10n.string("validation.email.required")
            return
        }

        guard !password.isEmpty else {
            errorMessage = AuthL10n.string("validation.password.required")
            return
        }

        guard password.count >= 7 && password.count <= 20 else {
            errorMessage = AuthL10n.string("validation.password.length")
            return
        }

        guard !passwordConfirmation.isEmpty else {
            errorMessage = AuthL10n.string("validation.password.confirm_required")
            return
        }

        guard password == passwordConfirmation else {
            errorMessage = AuthL10n.string("validation.password.mismatch")
            return
        }

        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let session = try await authenticationService.signUp(
                    email: normalizedEmail,
                    password: password
                )

                isLoading = false
                onSignUpSuccess?(session)

            } catch {
                isLoading = false
                errorMessage = AuthenticationErrorMessageMapper.message(
                    for: error,
                    context: .signUp
                )
            }
        }
    }
}
