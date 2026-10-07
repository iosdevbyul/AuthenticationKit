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

    private let authenticationService: AuthenticationService

    public init(
        authenticationService: AuthenticationService = .shared
    ) {
        self.authenticationService = authenticationService
    }

    public func changePassword() {
        guard !currentPassword.isEmpty else {
            errorMessage = AuthL10n.string("validation.current_password.required")
            return
        }

        guard !newPassword.isEmpty else {
            errorMessage = AuthL10n.string("validation.new_password.required")
            return
        }

        guard !passwordConfirmation.isEmpty else {
            errorMessage = AuthL10n.string("validation.new_password.confirm_required")
            return
        }

        guard newPassword == passwordConfirmation else {
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
                try await authenticationService.changePassword(
                    currentPassword: currentPassword,
                    newPassword: newPassword
                )

                isLoading = false
                onChangePasswordSuccess?()
            } catch {
                isLoading = false
                errorMessage = AuthenticationErrorMessageMapper.message(\n                    for: error,\n                    context: .changePassword\n                )
            }
        }
    }
}
