//
//  LogoutAllSessionsUseCaseTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import Testing
@testable import AuthenticationKit

struct LogoutAllSessionsUseCaseTests {

    @Test
    func executeCallsRepository() async throws {
        let repository = MockAuthenticationRepository()

        let useCase = LogoutAllSessionsUseCase(
            repository: repository
        )

        try await useCase.execute()

        #expect(
            repository.didLogoutAllSessions
        )
    }
}
