//
//  WithdrawalUseCaseTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Testing
@testable import AuthenticationKit

struct WithdrawalUseCaseTests {

    @Test
    func withdrawalClearsSession() async throws {
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

        let withdrawalUseCase = WithdrawalUseCase(
            repository: repository,
            sessionManager: sessionManager
        )

        try await withdrawalUseCase.execute()

        #expect(sessionManager.currentSession == nil)
        #expect(!sessionManager.isAuthenticated)
        #expect(try storage.loadSession() == nil)
    }
    
    @Test
    func withdrawalFailureKeepsSession() async throws {
        let repository = MockAuthenticationRepository(
            shouldFailWithdrawal: true
        )

        let storage = InMemoryTokenStorage()
        let sessionManager = SessionManager(tokenStorage: storage)

        let loginRepository = MockAuthenticationRepository()

        let loginUseCase = LoginUseCase(
            repository: loginRepository,
            sessionManager: sessionManager
        )

        _ = try await loginUseCase.execute(
            email: "test@test.com",
            password: "1234"
        )

        let withdrawalUseCase = WithdrawalUseCase(
            repository: repository,
            sessionManager: sessionManager
        )

        await #expect(throws: AuthenticationError.withdrawalFailed) {
            try await withdrawalUseCase.execute()
        }

        #expect(sessionManager.isAuthenticated)
        #expect(sessionManager.currentSession != nil)
    }
}
