//
//  NetworkAuthenticationRepository.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation
import NetworkKit

public final class NetworkAuthenticationRepository: AuthenticationRepository, Sendable {

    private let networkClient: any NetworkClient

    public init(networkClient: any NetworkClient) {
        self.networkClient = networkClient
    }

    public func login(
        email: String,
        password: String
    ) async throws -> Session {

        let endpoint = AuthenticationEndpoint.login(
            email: email,
            password: password
        )

        let response = try await networkClient.request(
            endpoint: endpoint,
            responseType: LoginResponseDTO.self
        )

        return response.toDomain()
    }

    public func signUp(
        email: String,
        password: String
    ) async throws -> Session {

        let endpoint = AuthenticationEndpoint.signUp(
            email: email,
            password: password
        )

        let response = try await networkClient.request(
            endpoint: endpoint,
            responseType: SignUpResponseDTO.self
        )

        return response.toDomain()
    }

    public func currentUser() async throws -> User {
        try await networkClient.request(endpoint: AuthenticationEndpoint.currentUser, responseType: User.self)
    }

    public func refresh(refreshToken: String) async throws -> Session {
        let response = try await networkClient.request(
            endpoint: AuthenticationEndpoint.refresh(refreshToken: refreshToken),
            responseType: LoginResponseDTO.self
        )
        return response.toDomain()
    }

    public func resetPassword(token: String, newPassword: String) async throws {
        let _: EmptyResponse = try await networkClient.request(
            endpoint: AuthenticationEndpoint.resetPassword(token: token, newPassword: newPassword),
            responseType: EmptyResponse.self
        )
    }

    public func verifyEmail(token: String) async throws {
        let _: EmailVerificationResponseDTO = try await networkClient.request(
            endpoint: AuthenticationEndpoint.verifyEmail(token: token),
            responseType: EmailVerificationResponseDTO.self
        )
    }

    public func resendVerificationEmail(email: String) async throws {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let _: EmailVerificationResponseDTO = try await networkClient.request(
            endpoint: AuthenticationEndpoint.resendVerificationEmail(email: normalized),
            responseType: EmailVerificationResponseDTO.self
        )
    }

    public func logout() async throws {
        let endpoint = AuthenticationEndpoint.logout

        try await networkClient.request(
            endpoint: endpoint,
            responseType: EmptyResponse.self
        )
    }

    public func withdraw() async throws {
        let endpoint = AuthenticationEndpoint.withdraw

        try await networkClient.request(
            endpoint: endpoint,
            responseType: EmptyResponse.self
        )
    }

    public func forgotPassword(
        email: String
    ) async throws {
        let endpoint = AuthenticationEndpoint.forgotPassword(
            email: email
        )

        try await networkClient.request(
            endpoint: endpoint,
            responseType: EmptyResponse.self
        )
    }
    
    public func changePassword(
        currentPassword: String,
        newPassword: String
    ) async throws {
        let endpoint = AuthenticationEndpoint.changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword
        )

        try await networkClient.request(
            endpoint: endpoint,
            responseType: EmptyResponse.self
        )
    }
    
    public func requestEmailChange(
        currentPassword: String,
        newEmail: String
    ) async throws {
        let _: EmptyResponse = try await networkClient.request(
            endpoint: AuthenticationEndpoint.requestEmailChange(
                currentPassword: currentPassword,
                newEmail: newEmail
            ),
            responseType: EmptyResponse.self
        )
    }

    public func confirmEmailChange(token: String) async throws {
        let _: EmptyResponse = try await networkClient.request(
            endpoint: AuthenticationEndpoint.confirmEmailChange(
                token: token
            ),
            responseType: EmptyResponse.self
        )
    }
}
