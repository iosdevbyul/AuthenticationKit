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
        password: String,
        persistSession: Bool = true
    ) async throws -> Session {
        let session = try await repository.login(
            email: email,
            password: password
        )

        try sessionManager.setSession(
            session,
            persist: persistSession
        )

        return session
    }
}
