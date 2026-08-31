//
//  MockTokenStorage.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-01.
//

import AuthenticationKit

final class MockTokenStorage: TokenStorage, @unchecked Sendable {

    var savedSession: Session?
    var shouldThrowError = false

    func save(session: Session) throws {
        if shouldThrowError {
            throw MockTokenStorageError.saveFailed
        }

        savedSession = session
    }

    func loadSession() throws -> Session? {
        if shouldThrowError {
            throw MockTokenStorageError.loadFailed
        }

        return savedSession
    }

    func clear() throws {
        if shouldThrowError {
            throw MockTokenStorageError.clearFailed
        }

        savedSession = nil
    }
}

enum MockTokenStorageError: Error {
    case saveFailed
    case loadFailed
    case clearFailed
}
