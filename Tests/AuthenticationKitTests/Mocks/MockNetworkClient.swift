//
//  MockNetworkClient.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation
import NetworkKit

final class MockNetworkClient: NetworkClient, @unchecked Sendable {
    var requestedEndpoint: (any Endpoint)?
    var response: Any?

    func request<T: Decodable>(
        endpoint: any Endpoint,
        responseType: T.Type
    ) async throws -> T {
        requestedEndpoint = endpoint

        guard let response = response as? T else {
            throw MockNetworkClientError.invalidResponse
        }

        return response
    }
}

enum MockNetworkClientError: Error {
    case invalidResponse
}
