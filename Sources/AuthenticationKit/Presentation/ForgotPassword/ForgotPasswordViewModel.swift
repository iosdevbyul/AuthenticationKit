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
    
    private let authenticationService: AuthenticationService

    public init(
        authenticationService: AuthenticationService = .shared
    ) {
        self.authenticationService = authenticationService
    }

    public func forgotPassword() {
        guard !email.isEmpty else {
            errorMessage = AuthL10n.string("validation.email.required")
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
                try await authenticationService.forgotPassword(
                    email: email
                )

                isLoading = false
                isSuccess = true
                onForgotPasswordSuccess?()

            } catch {
                isLoading = false
                errorMessage = AuthenticationErrorMessageMapper.message(\n                    for: error,\n                    context: .forgotPassword\n                )
            }
        }
    }
}
