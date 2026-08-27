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
    private let shouldFailWithdrawal: Bool
    
    public init(
        shouldFailWithdrawal: Bool = false
    ) {
        self.shouldFailWithdrawal = shouldFailWithdrawal
    }

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
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthenticationError.invalidInput
        }

        let user = User(
            id: "mock-user-\(email)",
            email: email
        )

        return Session(
            user: user,
            accessToken: "mock-access-token-\(email)",
            refreshToken: "mock-refresh-token-\(email)"
        )
    }

    public func logout() async throws {
        // Mock에서는 서버 요청 없이 성공으로 처리
    }

    public func withdraw() async throws {
        if shouldFailWithdrawal {
            throw AuthenticationError.withdrawalFailed
        }
    }
}
