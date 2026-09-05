//
//  AuthenticationConfigurationTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-05.
//

import XCTest
@testable import AuthenticationKit

final class AuthenticationConfigurationTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
    }

    func testConfigureBaseURL() {
        let baseURL = URL(string: "https://api.example.com")!

        AuthenticationConfiguration.shared.configure(
            baseURL: baseURL
        )

        XCTAssertEqual(
            AuthenticationConfiguration.shared.baseURL,
            baseURL
        )
    }
}
