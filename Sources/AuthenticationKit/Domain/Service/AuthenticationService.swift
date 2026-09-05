//
//  AuthenticationService.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-05.
//

import Foundation

public final class AuthenticationService: @unchecked Sendable {

    private let loginUseCase: LoginUseCase
    private let signUpUseCase: SignUpUseCase
    private let forgotPasswordUseCase: ForgotPasswordUseCase
    private let changePasswordUseCase: ChangePasswordUseCase
    private let repository: any AuthenticationRepository
    private let sessionManager: SessionManager

    public var currentSession: Session? {
        sessionManager.currentSession
    }

    public var isAuthenticated: Bool {
        sessionManager.isAuthenticated
    }

    public init(
        repository: any AuthenticationRepository,
        tokenStorage: any TokenStorage
    ) {
        self.repository = repository

        let sessionManager = SessionManager(
            tokenStorage: tokenStorage
        )

        self.sessionManager = sessionManager

        self.loginUseCase = LoginUseCase(
            repository: repository,
            sessionManager: sessionManager
        )

        self.signUpUseCase = SignUpUseCase(
            repository: repository,
            sessionManager: sessionManager
        )

        self.forgotPasswordUseCase = ForgotPasswordUseCase(
            repository: repository
        )

        self.changePasswordUseCase = ChangePasswordUseCase(
            repository: repository
        )
    }

    public func login(
        email: String,
        password: String
    ) async throws -> Session {
        try await loginUseCase.execute(
            email: email,
            password: password
        )
    }

    public func signUp(
        email: String,
        password: String
    ) async throws -> Session {
        try await signUpUseCase.execute(
            email: email,
            password: password
        )
    }

    public func logout() async throws {
        try await repository.logout()
        try sessionManager.clearSession()
    }

    public func withdraw() async throws {
        try await repository.withdraw()
        try sessionManager.clearSession()
    }

    public func forgotPassword(
        email: String
    ) async throws {
        try await forgotPasswordUseCase.execute(
            email: email
        )
    }

    public func changePassword(
        currentPassword: String,
        newPassword: String
    ) async throws {
        try await changePasswordUseCase.execute(
            currentPassword: currentPassword,
            newPassword: newPassword
        )
    }

    public func restoreSession() throws {
        try sessionManager.restoreSession()
    }
}
