//
//  InMemoryTokenStorage.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation

public final class InMemoryTokenStorage: TokenStorage, @unchecked Sendable {
    private var session: Session?

    public init() {}

    public func save(session: Session) throws {
        self.session = session
    }

    public func loadSession() throws -> Session? {
        session
    }

    public func clear() throws {
        session = nil
    }
}
