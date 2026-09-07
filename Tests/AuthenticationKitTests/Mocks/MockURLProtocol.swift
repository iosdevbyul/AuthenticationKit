//
//  MockURLProtocol.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-07.
//

import Foundation

final class MockURLProtocol: URLProtocol {

    nonisolated(unsafe) static var response: HTTPURLResponse?
    nonisolated(unsafe) static var responseData: Data?
    nonisolated(unsafe) static var error: Error?
    nonisolated(unsafe) static var request: URLRequest?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(
        for request: URLRequest
    ) -> URLRequest {
        request
    }

    static func reset() {
        response = nil
        responseData = nil
        error = nil
        request = nil
    }

    override func startLoading() {
        Self.request = request

        if let error = Self.error {
            client?.urlProtocol(
                self,
                didFailWithError: error
            )
            return
        }

        guard let response = Self.response else {
            return
        }

        client?.urlProtocol(
            self,
            didReceive: response,
            cacheStoragePolicy: .notAllowed
        )

        if let data = Self.responseData {
            client?.urlProtocol(
                self,
                didLoad: data
            )
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
