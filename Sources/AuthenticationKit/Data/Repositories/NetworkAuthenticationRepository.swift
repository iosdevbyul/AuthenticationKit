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
        fatalError("Not implemented")
    }

    public func logout() async throws {
        fatalError("Not implemented")
    }

    public func withdraw() async throws {
        fatalError("Not implemented")
    }

    public func forgotPassword(
        email: String
    ) async throws {
        fatalError("Not implemented")
    }
}
