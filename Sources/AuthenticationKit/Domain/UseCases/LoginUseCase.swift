//
//  LoginUseCase.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation

public struct LoginUseCase: Sendable {
    private let repository: any AuthenticationRepository
    private let sessionManager: SessionManager

    public init(
        repository: any AuthenticationRepository,
        sessionManager: SessionManager
    ) {
        self.repository = repository
        self.sessionManager = sessionManager
    }

    public func execute(
        email: String,
        password: String
    ) async throws -> Session {
        let session = try await repository.login(
            email: email,
            password: password
        )

        try sessionManager.setSession(session)

        return session
    }
}
