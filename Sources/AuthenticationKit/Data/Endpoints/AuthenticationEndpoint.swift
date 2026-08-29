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
    
    case signUp(
        email: String,
        password: String
    )
    
    case logout
    
    case withdraw
    
    case forgotPassword(email: String)
}

extension AuthenticationEndpoint: Endpoint {

    public var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .signUp:
            return "/auth/signup"
        case .logout:
            return "/auth/logout"
        case .withdraw:
            return "/auth/withdraw"
        case .forgotPassword:
            return "/auth/forgot-password"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .login, .signUp, .logout, .forgotPassword:
            return .post
        case .withdraw:
            return .delete
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
            
        case let .signUp(email, password):
            let body = SignUpRequestDTO(
                email: email,
                password: password
            )

            return try? JSONEncoder().encode(body)
            
        case .logout, .withdraw:
            return nil
            
        case let .forgotPassword(email):
            let body = ForgotPasswordRequestDTO(
                email: email
            )

            return try? JSONEncoder().encode(body)
        }
    }
}
