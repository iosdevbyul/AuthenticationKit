//
//  ForgotPasswordUseCaseTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Testing
@testable import AuthenticationKit

struct ForgotPasswordUseCaseTests {

    @Test
    func forgotPasswordSucceedsWithValidEmail() async throws {
        let repository = MockAuthenticationRepository()

        let useCase = ForgotPasswordUseCase(
            repository: repository
        )

        try await useCase.execute(
            email: "test@test.com"
        )
    }
    
    @Test
    func forgotPasswordFailsWithEmptyEmail() async {
        let repository = MockAuthenticationRepository()

        let useCase = ForgotPasswordUseCase(
            repository: repository
        )

        await #expect(throws: AuthenticationError.invalidInput) {
            try await useCase.execute(email: "")
        }
    }
    
    @Test
    func forgotPasswordDoesNotChangeSession() async throws {
        let repository = MockAuthenticationRepository()
        let storage = InMemoryTokenStorage()
        let sessionManager = SessionManager(
            tokenStorage: storage
        )

        let loginUseCase = LoginUseCase(
            repository: repository,
            sessionManager: sessionManager
        )

        _ = try await loginUseCase.execute(
            email: "test@test.com",
            password: "1234"
        )

        let sessionBefore = sessionManager.currentSession

        let forgotPasswordUseCase = ForgotPasswordUseCase(
            repository: repository
        )

        try await forgotPasswordUseCase.execute(
            email: "test@test.com"
        )

        #expect(sessionManager.currentSession == sessionBefore)
        #expect(sessionManager.isAuthenticated)
    }
}
