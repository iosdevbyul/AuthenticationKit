//
//  SessionManager.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation

public final class SessionManager: @unchecked Sendable {
    private let tokenStorage: any TokenStorage

    private let lock = NSLock()
    private var session: Session?

    public var currentSession: Session? {
        lock.lock()
        defer { lock.unlock() }
        return session
    }

    public var isAuthenticated: Bool {
        currentSession != nil
    }

    public init(tokenStorage: any TokenStorage) {
        self.tokenStorage = tokenStorage
    }

    public func setSession(_ session: Session) throws {
        lock.lock()
        defer { lock.unlock() }
        try tokenStorage.save(session: session)
        self.session = session
    }

    /// Update only the session whose request supplied this user, without rotating tokens
    /// or restoring a session that was signed out while the request was in flight.
    public func updateUser(_ user: User, for expectedSession: Session) throws {
        lock.lock()
        defer { lock.unlock() }
        guard session == expectedSession, user.id == expectedSession.user.id else { return }
        let updated = Session(user: user, accessToken: expectedSession.accessToken,
                              refreshToken: expectedSession.refreshToken)
        try tokenStorage.save(session: updated)
        session = updated
    }

    public func restoreSession() throws {
        lock.lock()
        defer { lock.unlock() }
        session = try tokenStorage.loadSession()
    }

    public func clearSession() throws {
        lock.lock()
        defer { lock.unlock() }
        try tokenStorage.clear()
        session = nil
    }
}
