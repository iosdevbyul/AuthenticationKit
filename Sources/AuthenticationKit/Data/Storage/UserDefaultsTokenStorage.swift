//
//  UserDefaultsTokenStorage.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-31.
//

import Foundation

public final class UserDefaultsTokenStorage: TokenStorage, @unchecked Sendable {

    private let userDefaults: UserDefaults

    private let sessionKey = "AuthenticationKit.session"

    public init(
        userDefaults: UserDefaults = .standard
    ) {
        self.userDefaults = userDefaults
    }

    public func save(session: Session) throws {
        let data = try JSONEncoder().encode(session)

        userDefaults.set(
            data,
            forKey: sessionKey
        )
    }

    public func loadSession() throws -> Session? {
        guard let data = userDefaults.data(
            forKey: sessionKey
        ) else {
            return nil
        }

        return try JSONDecoder().decode(
            Session.self,
            from: data
        )
    }

    public func clear() throws {
        userDefaults.removeObject(
            forKey: sessionKey
        )
    }
}
