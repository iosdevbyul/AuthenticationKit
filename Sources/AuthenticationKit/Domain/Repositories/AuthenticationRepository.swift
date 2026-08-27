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

    func logout() async throws

    func withdraw() async throws
}
