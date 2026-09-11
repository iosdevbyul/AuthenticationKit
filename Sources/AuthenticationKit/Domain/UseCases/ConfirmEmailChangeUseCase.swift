//
//  ConfirmEmailChangeUseCase.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-11.
//

import Foundation

public struct ConfirmEmailChangeUseCase: Sendable {

    private let repository: any AuthenticationRepository

    public init(repository: any AuthenticationRepository) {
        self.repository = repository
    }

    public func execute(token: String) async throws {
        try await repository.confirmEmailChange(token: token)
    }
}
