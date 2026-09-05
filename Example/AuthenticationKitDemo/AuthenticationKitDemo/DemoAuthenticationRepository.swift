//
//  DemoAuthenticationRepository.swift
//  AuthenticationKitDemo
//
//  Created by COMATOKI on 2026-09-05.
//

import AuthenticationKit

final class DemoAuthenticationRepository: AuthenticationRepository, @unchecked Sendable {

    func login(
        email: String,
        password: String
    ) async throws -> Session {
        makeSession(email: email)
    }

    func signUp(
        email: String,
        password: String
    ) async throws -> Session {
        makeSession(email: email)
    }

    func logout() async throws {
    }

    func withdraw() async throws {
    }

    func forgotPassword(email: String) async throws {
    }

    func changePassword(
        currentPassword: String,
        newPassword: String
    ) async throws {
    }

    private func makeSession(email: String) -> Session {
        Session(
            user: User(
                id: "demo-user",
                email: email
            ),
            accessToken: "demo-access-token",
            refreshToken: "demo-refresh-token"
        )
    }
}


