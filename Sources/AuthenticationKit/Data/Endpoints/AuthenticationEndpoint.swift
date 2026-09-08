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
    
    case currentUser
    case refresh(refreshToken: String)
    case resetPassword(token: String, newPassword: String)

    case logout
    
    case withdraw
    
    case forgotPassword(email: String)
    
    case changePassword(
        currentPassword: String,
        newPassword: String
    )
}

extension AuthenticationEndpoint: Endpoint {

    public var path: String {
        switch self {
        case .currentUser:
            return "/auth/me"
        case .refresh:
            return "/auth/refresh"
        case .resetPassword:
            return "/auth/reset-password"
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
        case .changePassword:
            return "/auth/change-password"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .login, .signUp, .logout, .forgotPassword, .changePassword, .refresh, .resetPassword:
            return .post
        case .currentUser:
            return .get
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
            
        case let .refresh(refreshToken):
            return try? JSONEncoder().encode(RefreshTokenRequestDTO(refreshToken: refreshToken))
        case let .resetPassword(token, newPassword):
            return try? JSONEncoder().encode(ResetPasswordRequestDTO(token: token, newPassword: newPassword))
        case .logout, .withdraw, .currentUser:
            return nil
            
        case let .forgotPassword(email):
            let body = ForgotPasswordRequestDTO(
                email: email
            )

            return try? JSONEncoder().encode(body)
            
        case let .changePassword(currentPassword, newPassword):
            let body = ChangePasswordRequestDTO(
                currentPassword: currentPassword,
                newPassword: newPassword
            )
            return try? JSONEncoder().encode(body)
        }
    }
}
