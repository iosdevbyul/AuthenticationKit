//
//  LogoutOtherSessionsUseCaseTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import Testing
@testable import AuthenticationKit

struct LogoutOtherSessionsUseCaseTests {

    @Test
    func executeCallsRepository() async throws {
        let repository = MockAuthenticationRepository()

        let useCase = LogoutOtherSessionsUseCase(
            repository: repository
        )

        try await useCase.execute()

        #expect(
            repository.didLogoutOtherSessions
        )
    }
}
