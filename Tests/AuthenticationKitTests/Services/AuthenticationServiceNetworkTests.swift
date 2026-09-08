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
    
    func testChangePasswordThroughNetwork() async throws {
        let responseData = """
        {
            "message": "Password changed successfully."
        }
        """.data(using: .utf8)!

        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "https://example.com/auth/change-password")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "Content-Type": "application/json"
            ]
        )

        MockURLProtocol.responseData = responseData

        try await service.changePassword(
            currentPassword: "old-password",
            newPassword: "new-password"
        )

        let request = try XCTUnwrap(MockURLProtocol.request)

        XCTAssertEqual(
            request.url?.path,
            "/auth/change-password"
        )

        XCTAssertEqual(
            request.httpMethod,
            "POST"
        )

        XCTAssertEqual(
            request.value(forHTTPHeaderField: "Content-Type"),
            "application/json"
        )
    }
    private func respond(_ body: String, status: Int = 200) {
        MockURLProtocol.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!, statusCode: status,
            httpVersion: nil, headerFields: ["Content-Type": "application/json"]
        )
        MockURLProtocol.responseData = Data(body.utf8)
    }

    private var sessionJSON: String {
        #"{"user":{"id":"user","email":"user@example.com"},"accessToken":"original-access","refreshToken":"original-refresh"}"#
    }

    func testProtectedRequestUsesStoredBearerToken() async throws {
        respond(sessionJSON)
        _ = try await service.login(email: "user@example.com", password: "Password123")
        respond(#"{"id":"user","email":"user@example.com"}"#)
        let user = try await service.currentUser()
        XCTAssertEqual(user.id, "user")
        XCTAssertEqual(MockURLProtocol.request?.url?.path, "/auth/me")
        XCTAssertEqual(MockURLProtocol.request?.httpMethod, "GET")
        XCTAssertEqual(MockURLProtocol.request?.value(forHTTPHeaderField: "Authorization"), "Bearer original-access")
    }

    func testRefreshReplacesPersistedSessionAndBearerToken() async throws {
        respond(sessionJSON)
        _ = try await service.login(email: "user@example.com", password: "Password123")
        respond(sessionJSON.replacingOccurrences(of: "original-", with: "rotated-"))
        let rotated = try await service.refreshSession()
        XCTAssertEqual(MockURLProtocol.request?.url?.path, "/auth/refresh")
        XCTAssertEqual(service.currentSession, rotated)
        try service.restoreSession()
        XCTAssertEqual(service.currentSession?.refreshToken, "rotated-refresh")
        respond(#"{"id":"user","email":"user@example.com"}"#)
        _ = try await service.currentUser()
        XCTAssertEqual(MockURLProtocol.request?.value(forHTTPHeaderField: "Authorization"), "Bearer rotated-access")
    }

    func testPasswordChangesClearPersistedSessionOnlyOnSuccess() async throws {
        respond(sessionJSON)
        _ = try await service.login(email: "user@example.com", password: "Password123")
        respond("{}", status: 401)
        do {
            try await service.changePassword(currentPassword: "Wrong123", newPassword: "Updated123")
            XCTFail("Expected failure")
        } catch { XCTAssertNotNil(service.currentSession) }
        respond(#"{"message":"Password changed"}"#)
        try await service.changePassword(currentPassword: "Password123", newPassword: "Updated123")
        XCTAssertNil(service.currentSession)
        try service.restoreSession()
        XCTAssertNil(service.currentSession)
    }

    func testResetEndpointEncodesPayloadAndClearsSession() async throws {
        let body = try XCTUnwrap(AuthenticationEndpoint.resetPassword(token: "reset-token", newPassword: "Reset123").body)
        let payload = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: String])
        XCTAssertEqual(payload, ["token": "reset-token", "newPassword": "Reset123"])
        respond(sessionJSON)
        _ = try await service.login(email: "user@example.com", password: "Password123")
        respond(#"{"message":"Password reset"}"#)
        try await service.resetPassword(token: "reset-token", newPassword: "Reset123")
        XCTAssertEqual(MockURLProtocol.request?.url?.path, "/auth/reset-password")
        XCTAssertEqual(MockURLProtocol.request?.httpMethod, "POST")
        try service.restoreSession()
        XCTAssertNil(service.currentSession)
    }

}
