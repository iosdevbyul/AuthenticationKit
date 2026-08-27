//
//  LogoutUseCase.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation

public struct LogoutUseCase: Sendable {
    private let repository: any AuthenticationRepository
    private let sessionManager: SessionManager

    public init(
        repository: any AuthenticationRepository,
        sessionManager: SessionManager
    ) {
        self.repository = repository
        self.sessionManager = sessionManager
    }

    public func execute() async throws {
        try await repository.logout()
        try sessionManager.clearSession()
    }
}
