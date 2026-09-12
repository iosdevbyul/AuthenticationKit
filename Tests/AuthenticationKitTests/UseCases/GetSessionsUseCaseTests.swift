//
//  GetSessionsUseCaseTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import Testing
@testable import AuthenticationKit

struct GetSessionsUseCaseTests {

    @Test
    func executeReturnsRepositorySessions() async throws {
        let repository = MockAuthenticationRepository()

        let expected = [
            ManagedSession(
                id: "session-1",
                createdAt: nil,
                startedAt: nil,
                expiresAt: .distantFuture,
                lastRefreshedAt: nil,
                isCurrent: true,
                deviceName: "iPhone"
            )
        ]

        repository.sessionsResponse = expected

        let useCase = GetSessionsUseCase(
            repository: repository
        )

        let sessions = try await useCase.execute()

        #expect(sessions == expected)
    }
}
