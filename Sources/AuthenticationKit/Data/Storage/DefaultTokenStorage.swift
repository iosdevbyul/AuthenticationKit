//
//  DefaultTokenStorage.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-06.
//

import Foundation

final class DefaultTokenStorage: TokenStorage, @unchecked Sendable {

    private let key = "AuthenticationKit.Session"

    func save(session: Session) throws {
        let data = try JSONEncoder().encode(session)
        UserDefaults.standard.set(data, forKey: key)
    }

    func loadSession() throws -> Session? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        return try JSONDecoder().decode(
            Session.self,
            from: data
        )
    }

    func clear() throws {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
