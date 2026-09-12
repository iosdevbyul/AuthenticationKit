//
//  RevokeSessionUseCase.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import Foundation

public struct RevokeSessionUseCase {

    private let repository: AuthenticationRepository

    public init(
        repository: AuthenticationRepository
    ) {
        self.repository = repository
    }

    public func execute(
        id: String
    ) async throws {
        try await repository.revokeSession(
            id: id
        )
    }
}
