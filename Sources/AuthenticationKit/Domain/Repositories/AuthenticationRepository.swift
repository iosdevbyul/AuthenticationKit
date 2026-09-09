//
//  AuthenticationRepository.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation

public protocol AuthenticationRepository: Sendable {
    func login(
        email: String,
        password: String
    ) async throws -> Session

    func signUp(
        email: String,
        password: String
    ) async throws -> Session

    func currentUser() async throws -> User

    func refresh(refreshToken: String) async throws -> Session

    func resetPassword(token: String, newPassword: String) async throws

    func verifyEmail(token: String) async throws

    func resendVerificationEmail(email: String) async throws

    func logout() async throws

    func withdraw() async throws
    
    func forgotPassword(email: String) async throws
    
    func changePassword(
        currentPassword: String,
        newPassword: String
    ) async throws
}

// Keep existing custom repositories source compatible; unsupported APIs fail explicitly.
public extension AuthenticationRepository {
    func verifyEmail(token: String) async throws { throw AuthenticationError.unsupportedOperation }
    func resendVerificationEmail(email: String) async throws { throw AuthenticationError.unsupportedOperation }
    func currentUser() async throws -> User { throw AuthenticationError.unsupportedOperation }
    func refresh(refreshToken: String) async throws -> Session { throw AuthenticationError.unsupportedOperation }
    func resetPassword(token: String, newPassword: String) async throws { throw AuthenticationError.unsupportedOperation }
}
