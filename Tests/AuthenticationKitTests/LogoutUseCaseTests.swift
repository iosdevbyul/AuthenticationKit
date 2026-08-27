//
//  LogoutUseCaseTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Testing
@testable import AuthenticationKit

struct LogoutUseCaseTests {

    @Test
    func logoutClearsSession() async throws {
        let repository = MockAuthenticationRepository()
        let storage = InMemoryTokenStorage()
        let sessionManager = SessionManager(tokenStorage: storage)

        let loginUseCase = LoginUseCase(
            repository: repository,
            sessionManager: sessionManager
        )

        _ = try await loginUseCase.execute(
            email: "test@test.com",
            password: "1234"
        )

        #expect(sessionManager.isAuthenticated)

        let logoutUseCase = LogoutUseCase(
            repository: repository,
            sessionManager: sessionManager
        )

        try await logoutUseCase.execute()

        #expect(sessionManager.currentSession == nil)
        #expect(!sessionManager.isAuthenticated)
    }
    
    @Test
    func logoutClearsStoredSession() async throws {
        let repository = MockAuthenticationRepository()
        let storage = InMemoryTokenStorage()
        let sessionManager = SessionManager(tokenStorage: storage)

        let loginUseCase = LoginUseCase(
            repository: repository,
            sessionManager: sessionManager
        )

        _ = try await loginUseCase.execute(
            email: "test@test.com",
            password: "1234"
        )

        let logoutUseCase = LogoutUseCase(
            repository: repository,
            sessionManager: sessionManager
        )

        try await logoutUseCase.execute()

        #expect(try storage.loadSession() == nil)
    }
}
