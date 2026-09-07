//
//  AuthenticationServiceSharedTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-07.
//

import XCTest
@testable import AuthenticationKit

final class AuthenticationServiceSharedTests: XCTestCase {

    override func setUp() {
        super.setUp()

        AuthenticationConfiguration.shared.configure(
            baseURL: URL(string: "https://example.com")!
        )
    }

    func testSharedServiceIsConfigured() {
        let service = AuthenticationService.shared

        XCTAssertNotNil(service)
        XCTAssertFalse(service.isAuthenticated)
        XCTAssertNil(service.currentSession)
    }
}
