//
//  ConfirmEmailChangeUseCaseTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import Testing
@testable import AuthenticationKit

struct ConfirmEmailChangeUseCaseTests {

    @Test
    func executeCallsRepositoryWithToken() async throws {
        let repository = MockAuthenticationRepository()

        let useCase = ConfirmEmailChangeUseCase(
            repository: repository
        )

        try await useCase.execute(
            token: "email-change-token"
        )

        #expect(
            repository.confirmEmailChangeToken
                == "email-change-token"
        )
    }
}
