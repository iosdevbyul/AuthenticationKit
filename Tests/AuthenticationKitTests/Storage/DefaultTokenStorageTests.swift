//
//  DefaultTokenStorageTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-06.
//

import XCTest
@testable import AuthenticationKit

final class DefaultTokenStorageTests: XCTestCase {

    private var sut: DefaultTokenStorage!

    override func setUp() {
        super.setUp()
        sut = DefaultTokenStorage()
    }

    override func tearDown() {
        try? sut.clear()
        sut = nil
        super.tearDown()
    }

    func testSaveAndLoadSession() throws {
        let session = Session(
            user: User(
                id: "test-user",
                email: "test@test.com"
            ),
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        try sut.save(session: session)

        let loadedSession = try sut.loadSession()

        XCTAssertEqual(
            loadedSession,
            session
        )
    }

    func testLoadSessionWhenNothingIsSaved() throws {
        let session = try sut.loadSession()

        XCTAssertNil(session)
    }

    func testClearSession() throws {
        let session = Session(
            user: User(
                id: "test-user",
                email: "test@test.com"
            ),
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        try sut.save(session: session)
        try sut.clear()

        let loadedSession = try sut.loadSession()

        XCTAssertNil(loadedSession)
    }
}
