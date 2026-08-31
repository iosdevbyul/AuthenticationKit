//
//  LoginUseCaseTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Testing
@testable import AuthenticationKit

struct LoginUseCaseTests {

    @Test
    func loginSucceedsWithValidCredentials() async throws {
        let repository = MockAuthenticationRepository()
        let storage = InMemoryTokenStorage()
        let sessionManager = SessionManager(tokenStorage: storage)

        let useCase = LoginUseCase(
            repository: repository,
            sessionManager: sessionManager
        )

        let session = try await useCase.execute(
            email: "test@test.com",
            password: "1234"
        )

        #expect(session.user.email == "test@test.com")
        #expect(session.accessToken == "mock-access-token")
    }
    @Test
    func loginFailsWithInvalidCredentials() async {
        let repository = MockAuthenticationRepository()
        let storage = InMemoryTokenStorage()
        let sessionManager = SessionManager(tokenStorage: storage)

        let useCase = LoginUseCase(
            repository: repository,
            sessionManager: sessionManager
        )

        await #expect(throws: AuthenticationError.invalidCredentials) {
            try await useCase.execute(
                email: "test@test.com",
                password: "wrong-password"
            )
        }
    }
    @Test
    func loginStoresSession() async throws {
        let repository = MockAuthenticationRepository()
        let storage = InMemoryTokenStorage()
        let sessionManager = SessionManager(tokenStorage: storage)

        let useCase = LoginUseCase(
            repository: repository,
            sessionManager: sessionManager
        )

        let session = try await useCase.execute(
            email: "test@test.com",
            password: "1234"
        )

        #expect(sessionManager.currentSession == session)
        #expect(sessionManager.isAuthenticated)
    }
    @Test
    func loginFailureDoesNotCreateSession() async {
        let repository = MockAuthenticationRepository()
        let storage = InMemoryTokenStorage()
        let sessionManager = SessionManager(tokenStorage: storage)

        let useCase = LoginUseCase(
            repository: repository,
            sessionManager: sessionManager
        )

        await #expect(throws: AuthenticationError.invalidCredentials) {
            try await useCase.execute(
                email: "test@test.com",
                password: "wrong-password"
            )
        }

        #expect(sessionManager.currentSession == nil)
        #expect(!sessionManager.isAuthenticated)
    }
}
