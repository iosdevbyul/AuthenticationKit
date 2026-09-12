//
//  MockAuthenticationRepository.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation

public final class MockAuthenticationRepository:
    AuthenticationRepository,
    @unchecked Sendable {

    private let testEmail = "test@test.com"
    private let testPassword = "1234"

    private let shouldFailWithdrawal: Bool
    private let shouldFailSignUp: Bool
    private let shouldFailForgotPassword: Bool
    private let shouldFailChangePassword: Bool

    var requestEmailChangeCurrentPassword: String?
    var requestEmailChangeNewEmail: String?
    var confirmEmailChangeToken: String?

    public var currentUserResponse: User?

    public init(
        shouldFailWithdrawal: Bool = false,
        shouldFailSignUp: Bool = false,
        shouldFailForgotPassword: Bool = false,
        shouldFailChangePassword: Bool = false,
        currentUserResponse: User? = nil
    ) {
        self.shouldFailWithdrawal = shouldFailWithdrawal
        self.shouldFailSignUp = shouldFailSignUp
        self.shouldFailForgotPassword = shouldFailForgotPassword
        self.shouldFailChangePassword = shouldFailChangePassword
        self.currentUserResponse = currentUserResponse
    }

    public func currentUser() async throws -> User {
        if let currentUserResponse {
            return currentUserResponse
        }

        return User(
            id: "mock-user-id",
            email: testEmail
        )
    }

    public func login(
        email: String,
        password: String
    ) async throws -> Session {
        guard email == testEmail,
              password == testPassword
        else {
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

        guard !email.isEmpty,
              !password.isEmpty
        else {
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

    public func logout() async throws {}

    public func withdraw() async throws {
        if shouldFailWithdrawal {
            throw AuthenticationError.withdrawalFailed
        }
    }

    public func forgotPassword(
        email: String
    ) async throws {
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

    public func requestEmailChange(
        currentPassword: String,
        newEmail: String
    ) async throws {
        requestEmailChangeCurrentPassword = currentPassword
        requestEmailChangeNewEmail = newEmail
    }

    public func confirmEmailChange(
        token: String
    ) async throws {
        confirmEmailChangeToken = token
    }
}
