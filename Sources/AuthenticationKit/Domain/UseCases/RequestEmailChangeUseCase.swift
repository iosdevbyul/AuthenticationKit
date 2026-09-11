//
//  RequestEmailChangeUseCase.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-11.
//

import Foundation

public struct RequestEmailChangeUseCase: Sendable {

    private let repository: any AuthenticationRepository

    public init(repository: any AuthenticationRepository) {
        self.repository = repository
    }

    public func execute(
        currentPassword: String,
        newEmail: String
    ) async throws {
        try await repository.requestEmailChange(
            currentPassword: currentPassword,
            newEmail: newEmail
        )
    }
}
