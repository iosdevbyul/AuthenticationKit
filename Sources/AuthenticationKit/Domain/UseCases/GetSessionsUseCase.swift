//
//  GetSessionsUseCase.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import Foundation

public struct GetSessionsUseCase {

    private let repository: AuthenticationRepository

    public init(
        repository: AuthenticationRepository
    ) {
        self.repository = repository
    }

    public func execute() async throws -> [ManagedSession] {
        try await repository.sessions()
    }
}
