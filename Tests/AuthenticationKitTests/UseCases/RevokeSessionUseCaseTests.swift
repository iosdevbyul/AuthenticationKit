//
//  RevokeSessionUseCaseTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import Testing
@testable import AuthenticationKit

struct RevokeSessionUseCaseTests {

    @Test
    func executePassesSessionIDToRepository() async throws {
        let repository = MockAuthenticationRepository()

        let useCase = RevokeSessionUseCase(
            repository: repository
        )

        try await useCase.execute(
            id: "session-1"
        )

        #expect(
            repository.revokedSessionID == "session-1"
        )
    }
}
