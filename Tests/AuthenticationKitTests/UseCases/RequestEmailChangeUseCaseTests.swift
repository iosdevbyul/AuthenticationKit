//
//  RequestEmailChangeUseCaseTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import Testing
@testable import AuthenticationKit

struct RequestEmailChangeUseCaseTests {

    @Test
    func executeCallsRepositoryWithProvidedValues() async throws {
        let repository = MockAuthenticationRepository()

        let useCase = RequestEmailChangeUseCase(
            repository: repository
        )

        try await useCase.execute(
            currentPassword: "current-password",
            newEmail: "New@Test.com"
        )

        #expect(
            repository.requestEmailChangeCurrentPassword
                == "current-password"
        )

        #expect(
            repository.requestEmailChangeNewEmail
                == "New@Test.com"
        )
    }
}
