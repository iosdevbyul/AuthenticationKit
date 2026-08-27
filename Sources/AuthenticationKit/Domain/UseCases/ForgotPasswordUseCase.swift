//
//  ForgotPasswordUseCase.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation

public struct ForgotPasswordUseCase: Sendable {
    private let repository: any AuthenticationRepository

    public init(repository: any AuthenticationRepository) {
        self.repository = repository
    }

    public func execute(email: String) async throws {
        guard !email.isEmpty else {
            throw AuthenticationError.invalidInput
        }

        try await repository.forgotPassword(email: email)
    }
}
