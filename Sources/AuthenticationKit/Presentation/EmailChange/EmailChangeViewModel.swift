//
//  EmailChangeViewModel.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-11.
//

import Foundation

@MainActor
public final class EmailChangeViewModel: ObservableObject {

    @Published public var currentPassword = ""
    @Published public var newEmail = ""

    @Published public private(set) var isLoading = false
    @Published public private(set) var message: String?
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var didConfirmEmailChange = false

    public var onEmailChangeConfirmed: ((User) -> Void)?

    private var token: String?
    private let authenticationService: AuthenticationService

    public var hasConfirmationToken: Bool {
        token != nil
    }

    public init(
        token: String? = nil,
        authenticationService: AuthenticationService = .shared
    ) {
        self.token = token
        self.authenticationService = authenticationService
    }

    public func requestEmailChange() async {
        guard !isLoading else {
            return
        }

        guard !currentPassword.isEmpty else {
            errorMessage = AuthL10n.string("validation.current_password.required")
            return
        }

        guard !newEmail.isEmpty else {
            errorMessage = AuthL10n.string("validation.email.required")
            return
        }

        guard newEmail.utf8.count <= 254,
              newEmail.contains("@"),
              newEmail.contains(".")
        else {
            errorMessage = AuthL10n.string("validation.email.invalid")
            return
        }

        isLoading = true
        message = nil
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await authenticationService.requestEmailChange(
                currentPassword: currentPassword,
                newEmail: newEmail
            )

            message = AuthL10n.string("auth.email_change.sent")
        } catch {
            errorMessage = AuthenticationErrorMessageMapper.message(
                for: error,
                context: .requestEmailChange
            )
        }
    }

    public func confirmEmailChange() async {
        guard !isLoading,
              !didConfirmEmailChange,
              let token
        else {
            return
        }

        isLoading = true
        message = nil
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await authenticationService.confirmEmailChange(
                token: token
            )

            self.token = nil
            didConfirmEmailChange = true

            guard let user = authenticationService.currentSession?.user else {
                message = AuthL10n.string("auth.email_change.changed")
                return
            }

            message = AuthL10n.string("auth.email_change.changed")
            onEmailChangeConfirmed?(user)

        } catch {
            errorMessage = AuthenticationErrorMessageMapper.message(
                for: error,
                context: .confirmEmailChange
            )
        }
    }
}
