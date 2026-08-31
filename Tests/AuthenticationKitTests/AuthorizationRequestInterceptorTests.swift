//
//  AuthorizationRequestInterceptorTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-01.
//

import Foundation
import Testing
@testable import NetworkKit

struct AuthorizationRequestInterceptorTests {

    @Test
    func addsAuthorizationHeaderWithAccessToken() async throws {
        let provider = MockAccessTokenProvider(
            accessToken: "test-access-token"
        )

        let interceptor = AuthorizationRequestInterceptor(
            tokenProvider: provider
        )

        let request = URLRequest(
            url: URL(string: "https://example.com")!
        )

        let interceptedRequest = try await interceptor.intercept(
            request
        )

        #expect(
            interceptedRequest.value(
                forHTTPHeaderField: "Authorization"
            ) == "Bearer test-access-token"
        )
    }

    @Test
    func doesNotAddAuthorizationHeaderWhenAccessTokenIsNil() async throws {
        let provider = MockAccessTokenProvider(
            accessToken: nil
        )

        let interceptor = AuthorizationRequestInterceptor(
            tokenProvider: provider
        )

        let request = URLRequest(
            url: URL(string: "https://example.com")!
        )

        let interceptedRequest = try await interceptor.intercept(
            request
        )

        #expect(
            interceptedRequest.value(
                forHTTPHeaderField: "Authorization"
            ) == nil
        )
    }
}

private final class MockAccessTokenProvider:
    AccessTokenProvider,
    @unchecked Sendable {

    let accessToken: String?

    init(accessToken: String?) {
        self.accessToken = accessToken
    }
}
