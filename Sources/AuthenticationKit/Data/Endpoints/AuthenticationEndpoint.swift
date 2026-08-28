//
//  AuthenticationEndpoint.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation
import NetworkKit

public enum AuthenticationEndpoint {
    case login(
        email: String,
        password: String
    )
}

extension AuthenticationEndpoint: Endpoint {

    public var path: String {
        switch self {
        case .login:
            return "/auth/login"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        }
    }

    public var headers: [String: String] {
        [
            "Content-Type": "application/json"
        ]
    }

    public var queryItems: [URLQueryItem] {
        []
    }

    public var body: Data? {
        switch self {
        case let .login(email, password):
            let body = LoginRequestDTO(
                email: email,
                password: password
            )

            return try? JSONEncoder().encode(body)
        }
    }
}
