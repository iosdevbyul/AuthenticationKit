//
//  MockAuthenticationRepository.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation

public struct MockAuthenticationRepository: AuthenticationRepository {
    private let testEmail = "test@test.com"
    private let testPassword = "1234"

    public init() {}

    public func login(
        email: String,
        password: String
    ) async throws -> Session {
        guard email == testEmail, password == testPassword else {
            throw AuthenticationError.invalidCredentials
        }

        let user = User(
            id: "mock-user-id",
            email: email
        )

        return Session(
            user: user,
            accessToken: "mock-access-token",
            refreshToken: "mock-refresh-token"
        )
    }

    public func signUp(
        email: String,
        password: String
    ) async throws -> Session {
        fatalError("Not implemented")
    }

    public func logout() async throws {
        fatalError("Not implemented")
    }

    public func withdraw() async throws {
        fatalError("Not implemented")
    }
}
