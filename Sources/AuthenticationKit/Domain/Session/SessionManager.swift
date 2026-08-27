//
//  SessionManager.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation

public final class SessionManager: @unchecked Sendable {
    private let tokenStorage: any TokenStorage

    public private(set) var currentSession: Session?

    public var isAuthenticated: Bool {
        currentSession != nil
    }

    public init(tokenStorage: any TokenStorage) {
        self.tokenStorage = tokenStorage
    }

    public func setSession(_ session: Session) throws {
        try tokenStorage.save(session: session)
        currentSession = session
    }

    public func restoreSession() throws {
        currentSession = try tokenStorage.loadSession()
    }

    public func clearSession() throws {
        try tokenStorage.clear()
        currentSession = nil
    }
}
