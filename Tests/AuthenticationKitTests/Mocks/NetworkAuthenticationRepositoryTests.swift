//
//  NetworkAuthenticationRepositoryTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Testing
@testable import AuthenticationKit
import Foundation

struct NetworkAuthenticationRepositoryTests {

    @Test
    func loginReturnsSessionFromNetworkResponse() async throws {
        let networkClient = MockNetworkClient()

        networkClient.response = LoginResponseDTO(
            user: UserDTO(
                id: "user-1",
                email: "test@test.com"
            ),
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        let repository = NetworkAuthenticationRepository(
            networkClient: networkClient
        )

        let session = try await repository.login(
            email: "test@test.com",
            password: "1234"
        )

        #expect(session.user.id == "user-1")
        #expect(session.user.email == "test@test.com")
        #expect(session.accessToken == "access-token")
        #expect(session.refreshToken == "refresh-token")
    }

    @Test
    func loginCreatesCorrectEndpoint() async throws {
        let networkClient = MockNetworkClient()

        networkClient.response = LoginResponseDTO(
            user: UserDTO(
                id: "user-1",
                email: "test@test.com"
            ),
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        let repository = NetworkAuthenticationRepository(
            networkClient: networkClient
        )

        _ = try await repository.login(
            email: "test@test.com",
            password: "1234"
        )

        let endpoint = try #require(
            networkClient.requestedEndpoint
        )

        #expect(endpoint.path == "/auth/login")
        #expect(endpoint.method == .post)
        #expect(
            endpoint.headers["Content-Type"] == "application/json"
        )
    }

    @Test
    func loginEndpointContainsCredentials() async throws {
        let networkClient = MockNetworkClient()

        networkClient.response = LoginResponseDTO(
            user: UserDTO(
                id: "user-1",
                email: "test@test.com"
            ),
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        let repository = NetworkAuthenticationRepository(
            networkClient: networkClient
        )

        _ = try await repository.login(
            email: "test@test.com",
            password: "1234"
        )

        let endpoint = try #require(
            networkClient.requestedEndpoint
        )

        let body = try #require(endpoint.body)

        let json = try #require(
            JSONSerialization.jsonObject(
                with: body
            ) as? [String: Any]
        )

        #expect(
            json["email"] as? String == "test@test.com"
        )

        #expect(
            json["password"] as? String == "1234"
        )
    }

    @Test
    func withdrawSendsCorrectEndpoint() async throws {
        let networkClient = MockNetworkClient()
        networkClient.response = EmptyResponse()

        let repository = NetworkAuthenticationRepository(
            networkClient: networkClient
        )

        try await repository.withdraw()

        let endpoint = try #require(
            networkClient.requestedEndpoint
        )

        #expect(endpoint.path == "/auth/withdraw")
        #expect(endpoint.method == .delete)
        #expect(endpoint.body == nil)
    }

    // MARK: - Forgot Password

    @Test
    func forgotPasswordCreatesCorrectEndpoint() async throws {
        let networkClient = MockNetworkClient()
        networkClient.response = EmptyResponse()

        let repository = NetworkAuthenticationRepository(
            networkClient: networkClient
        )

        try await repository.forgotPassword(
            email: "forgot@test.com"
        )

        let endpoint = try #require(
            networkClient.requestedEndpoint
        )

        #expect(endpoint.path == "/auth/forgot-password")
        #expect(endpoint.method == .post)
        #expect(
            endpoint.headers["Content-Type"] == "application/json"
        )
    }

    @Test
    func forgotPasswordEndpointContainsEmail() async throws {
        let networkClient = MockNetworkClient()
        networkClient.response = EmptyResponse()

        let repository = NetworkAuthenticationRepository(
            networkClient: networkClient
        )

        try await repository.forgotPassword(
            email: "forgot@test.com"
        )

        let endpoint = try #require(
            networkClient.requestedEndpoint
        )

        let body = try #require(endpoint.body)

        let json = try #require(
            JSONSerialization.jsonObject(
                with: body
            ) as? [String: Any]
        )

        #expect(
            json["email"] as? String == "forgot@test.com"
        )
    }

    // MARK: - Change Password

    @Test
    func changePasswordCreatesCorrectEndpoint() async throws {
        let networkClient = MockNetworkClient()
        networkClient.response = EmptyResponse()

        let repository = NetworkAuthenticationRepository(
            networkClient: networkClient
        )

        try await repository.changePassword(
            currentPassword: "old-password",
            newPassword: "new-password"
        )

        let endpoint = try #require(
            networkClient.requestedEndpoint
        )

        #expect(
            endpoint.path == "/auth/change-password"
        )

        #expect(
            endpoint.method == .post
        )

        #expect(
            endpoint.headers["Content-Type"] == "application/json"
        )
    }

    @Test
    func changePasswordEndpointContainsPasswords() async throws {
        let networkClient = MockNetworkClient()
        networkClient.response = EmptyResponse()

        let repository = NetworkAuthenticationRepository(
            networkClient: networkClient
        )

        try await repository.changePassword(
            currentPassword: "old-password",
            newPassword: "new-password"
        )

        let endpoint = try #require(
            networkClient.requestedEndpoint
        )

        let body = try #require(
            endpoint.body
        )

        let json = try #require(
            JSONSerialization.jsonObject(
                with: body
            ) as? [String: Any]
        )

        #expect(
            json["currentPassword"] as? String == "old-password"
        )

        #expect(
            json["newPassword"] as? String == "new-password"
        )
    }
    
    // MARK: - Email Change

    @Test
    func requestEmailChangeCreatesCorrectEndpoint() async throws {
        let networkClient = MockNetworkClient()
        networkClient.response = EmptyResponse()

        let repository = NetworkAuthenticationRepository(
            networkClient: networkClient
        )

        try await repository.requestEmailChange(
            currentPassword: "current-password",
            newEmail: "New@Test.com"
        )

        let endpoint = try #require(
            networkClient.requestedEndpoint
        )

        #expect(
            endpoint.path == "/auth/request-email-change"
        )

        #expect(
            endpoint.method == .post
        )

        #expect(
            endpoint.headers["Content-Type"] == "application/json"
        )
    }

    @Test
    func requestEmailChangeEndpointContainsCurrentPasswordAndNewEmail() async throws {
        let networkClient = MockNetworkClient()
        networkClient.response = EmptyResponse()

        let repository = NetworkAuthenticationRepository(
            networkClient: networkClient
        )

        try await repository.requestEmailChange(
            currentPassword: "current-password",
            newEmail: "New@Test.com"
        )

        let endpoint = try #require(
            networkClient.requestedEndpoint
        )

        let body = try #require(
            endpoint.body
        )

        let json = try #require(
            JSONSerialization.jsonObject(
                with: body
            ) as? [String: Any]
        )

        #expect(
            json["currentPassword"] as? String == "current-password"
        )

        #expect(
            json["newEmail"] as? String == "New@Test.com"
        )
    }

    @Test
    func confirmEmailChangeCreatesCorrectEndpoint() async throws {
        let networkClient = MockNetworkClient()
        networkClient.response = EmptyResponse()

        let repository = NetworkAuthenticationRepository(
            networkClient: networkClient
        )

        try await repository.confirmEmailChange(
            token: "email-change-token"
        )

        let endpoint = try #require(
            networkClient.requestedEndpoint
        )

        #expect(
            endpoint.path == "/auth/confirm-email-change"
        )

        #expect(
            endpoint.method == .post
        )

        #expect(
            endpoint.headers["Content-Type"] == "application/json"
        )
    }

    @Test
    func confirmEmailChangeEndpointContainsToken() async throws {
        let networkClient = MockNetworkClient()
        networkClient.response = EmptyResponse()

        let repository = NetworkAuthenticationRepository(
            networkClient: networkClient
        )

        try await repository.confirmEmailChange(
            token: "email-change-token"
        )

        let endpoint = try #require(
            networkClient.requestedEndpoint
        )

        let body = try #require(
            endpoint.body
        )

        let json = try #require(
            JSONSerialization.jsonObject(
                with: body
            ) as? [String: Any]
        )

        #expect(
            json["token"] as? String == "email-change-token"
        )
    }
}
