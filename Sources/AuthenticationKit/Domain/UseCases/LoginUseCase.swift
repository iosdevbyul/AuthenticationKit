//
//  LoginUseCase.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation

public struct LoginUseCase: Sendable {
    private let repository: any AuthenticationRepository

    public init(
        repository: any AuthenticationRepository
    ) {
        self.repository = repository
    }

    public func execute(
        email: String,
        password: String
    ) async throws -> Session {
        try await repository.login(
            email: email,
            password: password
        )
    }
}
