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
        let useCase = LoginUseCase(repository: repository)

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
        let useCase = LoginUseCase(repository: repository)

        await #expect(throws: AuthenticationError.invalidCredentials) {
            try await useCase.execute(
                email: "test@test.com",
                password: "wrong-password"
            )
        }
    }
}
