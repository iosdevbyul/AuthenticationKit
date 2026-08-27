//
//  TokenStorage.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation

public protocol TokenStorage: Sendable {
    func save(session: Session) throws
    func loadSession() throws -> Session?
    func clear() throws
}
