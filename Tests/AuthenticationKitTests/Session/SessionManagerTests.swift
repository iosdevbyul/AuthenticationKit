//
//  SessionManagerTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Testing
@testable import AuthenticationKit

struct SessionManagerTests {

    @Test
    func setSessionStoresAndExposesSession() throws {
        let storage = InMemoryTokenStorage()
        let manager = SessionManager(tokenStorage: storage)

        let user = User(
            id: "user-1",
            email: "test@test.com"
        )

        let session = Session(
            user: user,
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        try manager.setSession(session)

        #expect(manager.currentSession == session)
        #expect(manager.isAuthenticated)
    }

    @Test
    func restoreSessionLoadsStoredSession() throws {
        let storage = InMemoryTokenStorage()

        let user = User(
            id: "user-1",
            email: "test@test.com"
        )

        let session = Session(
            user: user,
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        try storage.save(session: session)

        let manager = SessionManager(tokenStorage: storage)

        try manager.restoreSession()

        #expect(manager.currentSession == session)
        #expect(manager.isAuthenticated)
    }

    @Test
    func clearSessionRemovesSession() throws {
        let storage = InMemoryTokenStorage()
        let manager = SessionManager(tokenStorage: storage)

        let session = Session(
            user: User(
                id: "user-1",
                email: "test@test.com"
            ),
            accessToken: "access-token"
        )

        try manager.setSession(session)
        try manager.clearSession()

        #expect(manager.currentSession == nil)
        #expect(!manager.isAuthenticated)
    }
    
    @Test
        func sessionManagerProvidesAccessTokenFromCurrentSession() throws {
            let tokenStorage = MockTokenStorage()

            let sessionManager = SessionManager(
                tokenStorage: tokenStorage
            )

            let session = Session(
                user: User(
                    id: "user-1",
                    email: "test@test.com"
                ),
                accessToken: "access-token",
                refreshToken: "refresh-token"
            )

            try sessionManager.setSession(session)

            #expect(sessionManager.accessToken == "access-token")
        }

        @Test
        func sessionManagerProvidesNilAccessTokenWithoutSession() {
            let tokenStorage = MockTokenStorage()

            let sessionManager = SessionManager(
                tokenStorage: tokenStorage
            )

            #expect(sessionManager.accessToken == nil)
        }

        @Test
        func sessionManagerProvidesNilAccessTokenAfterClearSession() throws {
            let tokenStorage = MockTokenStorage()

            let sessionManager = SessionManager(
                tokenStorage: tokenStorage
            )

            let session = Session(
                user: User(
                    id: "user-1",
                    email: "test@test.com"
                ),
                accessToken: "access-token",
                refreshToken: "refresh-token"
            )

            try sessionManager.setSession(session)
            try sessionManager.clearSession()

            #expect(sessionManager.accessToken == nil)
        }
}
