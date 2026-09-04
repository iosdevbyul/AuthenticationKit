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
    private let shouldFailSignUp: Bool
    private let shouldFailForgotPassword: Bool
    private let shouldFailChangePassword: Bool
    
    public init(
        shouldFailWithdrawal: Bool = false,
        shouldFailSignUp: Bool = false,
        shouldFailForgotPassword: Bool = false,
        shouldFailChangePassword: Bool = false
    ) {
        self.shouldFailWithdrawal = shouldFailWithdrawal
        self.shouldFailSignUp = shouldFailSignUp
        self.shouldFailForgotPassword = shouldFailForgotPassword
        self.shouldFailChangePassword = shouldFailChangePassword
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
        if shouldFailSignUp {
            throw AuthenticationError.invalidInput
        }
        
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
    
    public func forgotPassword(email: String) async throws {
        if shouldFailForgotPassword {
            throw AuthenticationError.invalidInput
        }

        guard !email.isEmpty else {
            throw AuthenticationError.invalidInput
        }
    }
    
    public func changePassword(
        currentPassword: String,
        newPassword: String
    ) async throws {
        if shouldFailChangePassword {
            throw AuthenticationError.invalidInput
        }
    }
}
