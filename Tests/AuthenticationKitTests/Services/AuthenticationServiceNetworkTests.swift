//
//  AuthenticationServiceNetworkTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-07.
//

import XCTest
@testable import AuthenticationKit

final class AuthenticationServiceNetworkTests: XCTestCase {

    private var session: URLSession!
    private var service: AuthenticationService!

    override func setUp() {
        super.setUp()

        MockURLProtocol.reset()

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]

        session = URLSession(configuration: configuration)

        AuthenticationConfiguration.shared.configure(
            baseURL: URL(string: "https://example.com")!
        )

        service = AuthenticationService(
            session: session
        )
    }

    override func tearDown() {
        MockURLProtocol.reset()

        session = nil
        service = nil

        super.tearDown()
    }

    func testLoginThroughNetwork() async throws {
        let responseData = """
        {
            "user": {
                "id": "test-user",
                "email": "test@test.com"
            },
            "accessToken": "access-token",
            "refreshToken": "refresh-token"
        }
        """.data(using: .utf8)!

        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "https://example.com/auth/login")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "Content-Type": "application/json"
            ]
        )

        MockURLProtocol.responseData = responseData

        let session = try await service.login(
            email: "test@test.com",
            password: "password123"
        )

        XCTAssertEqual(
            session.user.id,
            "test-user"
        )

        XCTAssertEqual(
            session.user.email,
            "test@test.com"
        )

        XCTAssertEqual(
            session.accessToken,
            "access-token"
        )

        XCTAssertEqual(
            session.refreshToken,
            "refresh-token"
        )

        XCTAssertTrue(service.isAuthenticated)
        XCTAssertEqual(service.currentSession, session)
    }
}
