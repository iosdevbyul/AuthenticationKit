//
//  SignUpUseCaseTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Testing
@testable import AuthenticationKit

struct SignUpUseCaseTests {

    @Test
    func signUpCreatesAndStoresSession() async throws {
        let repository = MockAuthenticationRepository()
        let storage = InMemoryTokenStorage()
        let sessionManager = SessionManager(tokenStorage: storage)

        let useCase = SignUpUseCase(
            repository: repository,
            sessionManager: sessionManager
        )

        let session = try await useCase.execute(
            email: "new@test.com",
            password: "1234"
        )

        #expect(session.user.email == "new@test.com")
        #expect(sessionManager.currentSession == session)
        #expect(sessionManager.isAuthenticated)
    }
    @Test
    func signUpFailsWithEmptyInput() async {
        let repository = MockAuthenticationRepository()
        let storage = InMemoryTokenStorage()
        let sessionManager = SessionManager(tokenStorage: storage)

        let useCase = SignUpUseCase(
            repository: repository,
            sessionManager: sessionManager
        )

        await #expect(throws: AuthenticationError.invalidInput) {
            try await useCase.execute(
                email: "",
                password: ""
            )
        }

        #expect(sessionManager.currentSession == nil)
        #expect(!sessionManager.isAuthenticated)
    }
}
