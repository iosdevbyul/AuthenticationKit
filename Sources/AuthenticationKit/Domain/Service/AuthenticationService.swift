//
//  AuthenticationService.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-05.
//

import Foundation
import NetworkKit

public final class AuthenticationService: @unchecked Sendable {

    public static let shared = AuthenticationService()

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

    internal convenience init(session: URLSession = .shared) {
        guard let baseURL = AuthenticationConfiguration.shared.baseURL else {
            fatalError("AuthenticationConfiguration must be configured before using AuthenticationService.")
        }
        self.init(baseURL: baseURL, tokenStorage: DefaultTokenStorage(), session: session)
    }

    public convenience init(
        baseURL: URL,
        tokenStorage: any TokenStorage,
        session: URLSession = .shared
    ) {
        let manager = SessionManager(tokenStorage: tokenStorage)
        let client = URLSessionNetworkClient(
            configuration: NetworkConfiguration(baseURL: baseURL),
            session: session,
            interceptor: AuthorizationRequestInterceptor(tokenProvider: manager)
        )
        self.init(repository: NetworkAuthenticationRepository(networkClient: client), sessionManager: manager)
    }

    public convenience init(
        repository: any AuthenticationRepository,
        tokenStorage: any TokenStorage
    ) {
        self.init(repository: repository, sessionManager: SessionManager(tokenStorage: tokenStorage))
    }

    private init(repository: any AuthenticationRepository, sessionManager: SessionManager) {
        self.repository = repository
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
        try sessionManager.clearSession()
    }

    public func currentUser() async throws -> User {
        try await repository.currentUser()
    }

    public func refreshSession() async throws -> Session {
        try await RefreshSessionUseCase(repository: repository, sessionManager: sessionManager).execute()
    }

    public func resetPassword(token: String, newPassword: String) async throws {
        try await ResetPasswordUseCase(repository: repository).execute(token: token, newPassword: newPassword)
        try sessionManager.clearSession()
    }

    public func restoreSession() throws {
        try sessionManager.restoreSession()
    }
}
