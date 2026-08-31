//
//  UserDefaultsTokenStorageTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-31.
//

import Foundation
import Testing
@testable import AuthenticationKit

struct UserDefaultsTokenStorageTests {

    @Test
    func saveAndLoadSession() throws {
        let userDefaults = UserDefaults(
            suiteName: "UserDefaultsTokenStorageTests.saveAndLoad"
        )!

        defer {
            userDefaults.removePersistentDomain(
                forName: "UserDefaultsTokenStorageTests.saveAndLoad"
            )
        }

        let storage = UserDefaultsTokenStorage(
            userDefaults: userDefaults
        )

        let session = Session(
            user: User(
                id: "user-1",
                email: "test@test.com"
            ),
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        try storage.save(session: session)

        let loadedSession = try storage.loadSession()

        #expect(loadedSession == session)
    }

    @Test
    func loadSessionReturnsNilWhenNothingIsSaved() throws {
        let userDefaults = UserDefaults(
            suiteName: "UserDefaultsTokenStorageTests.loadEmpty"
        )!

        defer {
            userDefaults.removePersistentDomain(
                forName: "UserDefaultsTokenStorageTests.loadEmpty"
            )
        }

        let storage = UserDefaultsTokenStorage(
            userDefaults: userDefaults
        )

        let session = try storage.loadSession()

        #expect(session == nil)
    }

    @Test
    func clearRemovesSavedSession() throws {
        let userDefaults = UserDefaults(
            suiteName: "UserDefaultsTokenStorageTests.clear"
        )!

        defer {
            userDefaults.removePersistentDomain(
                forName: "UserDefaultsTokenStorageTests.clear"
            )
        }

        let storage = UserDefaultsTokenStorage(
            userDefaults: userDefaults
        )

        let session = Session(
            user: User(
                id: "user-1",
                email: "test@test.com"
            ),
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        try storage.save(session: session)

        #expect(try storage.loadSession() == session)

        try storage.clear()

        #expect(try storage.loadSession() == nil)
    }

    @Test
    func saveSessionWithoutRefreshToken() throws {
        let userDefaults = UserDefaults(
            suiteName: "UserDefaultsTokenStorageTests.noRefreshToken"
        )!

        defer {
            userDefaults.removePersistentDomain(
                forName: "UserDefaultsTokenStorageTests.noRefreshToken"
            )
        }

        let storage = UserDefaultsTokenStorage(
            userDefaults: userDefaults
        )

        let session = Session(
            user: User(
                id: "user-1",
                email: "test@test.com"
            ),
            accessToken: "access-token"
        )

        try storage.save(session: session)

        let loadedSession = try storage.loadSession()

        #expect(loadedSession == session)
        #expect(loadedSession?.refreshToken == nil)
    }
}
