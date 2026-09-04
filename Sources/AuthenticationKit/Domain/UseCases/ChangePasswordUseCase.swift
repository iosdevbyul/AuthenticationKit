//
//  ChangePasswordUseCase.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-04.
//

import Foundation

public struct ChangePasswordUseCase: Sendable {

    private let repository: any AuthenticationRepository

    public init(
        repository: any AuthenticationRepository
    ) {
        self.repository = repository
    }

    public func execute(
        currentPassword: String,
        newPassword: String
    ) async throws {
        try await repository.changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword
        )
    }
}
