//
//  DemoTokenStorage.swift
//  AuthenticationKitDemo
//
//  Created by COMATOKI on 2026-09-05.
//

import AuthenticationKit

final class DemoTokenStorage: TokenStorage, @unchecked Sendable {

    private var session: Session?

    func save(session: Session) throws {
        self.session = session
    }

    func loadSession() throws -> Session? {
        session
    }

    func clear() throws {
        session = nil
    }
}
