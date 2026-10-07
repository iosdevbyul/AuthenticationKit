//
//  AuthenticationErrorMessageMapper.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-09.
//

import Foundation
import NetworkKit

enum AuthenticationErrorContext {
    case login
    case signUp
    case forgotPassword
    case resetPassword
    case changePassword
    case verifyEmail
    case resendVerificationEmail
    case session
    case withdrawal
    case requestEmailChange
    case confirmEmailChange
}

enum AuthenticationErrorMessageMapper {

    static func message(
        for error: Error,
        context: AuthenticationErrorContext
    ) -> String {

        if let authenticationError = error as? AuthenticationError {
            if context == .verifyEmail, authenticationError == .invalidInput {
                return AuthL10n.string("error.verification_link.invalid")
            }
            return authenticationMessage(authenticationError)
        }

        if let networkError = error as? NetworkError {
            return networkMessage(
                networkError,
                context: context
            )
        }

        if let urlError = error as? URLError {
            return urlErrorMessage(urlError)
        }

        return AuthL10n.string("error.generic")
    }

    private static func authenticationMessage(
        _ error: AuthenticationError
    ) -> String {
        switch error {
        case .invalidCredentials:
            return AuthL10n.string("error.invalid_credentials")

        case .invalidInput:
            return AuthL10n.string("error.invalid_input")

        case .unsupportedOperation:
            return AuthL10n.string("error.unsupported")

        case .withdrawalFailed:
            return AuthL10n.string("error.withdrawal_failed")
        }
    }

    private static func networkMessage(
        _ error: NetworkError,
        context: AuthenticationErrorContext
    ) -> String {
        switch error {
        case .invalidURL:
            return AuthL10n.string("error.invalid_url")

        case .invalidResponse:
            return AuthL10n.string("error.invalid_response")

        case .decodingFailed:
            return AuthL10n.string("error.decoding_failed")

        case .serverError(let statusCode):
            return serverMessage(
                statusCode: statusCode,
                context: context
            )

        case .unknown(let error):
            if let urlError = error as? URLError {
                return urlErrorMessage(urlError)
            }

            return AuthL10n.string("error.network_generic")
        }
    }

    private static func serverMessage(
        statusCode: Int,
        context: AuthenticationErrorContext
    ) -> String {
        if context == .resendVerificationEmail, [404, 409, 429].contains(statusCode) {
            return AuthL10n.string("error.verification_privacy")
        }
        switch statusCode {
        case 400:
            switch context {
            case .verifyEmail:
                return AuthL10n.string("error.verification_link.invalid")

            case .resetPassword:
                return AuthL10n.string("error.reset_link.invalid")

            case .forgotPassword:
                return AuthL10n.string("validation.email.invalid")
            case .confirmEmailChange:
                return AuthL10n.string("error.email_change_link.invalid")
            default:
                return AuthL10n.string("error.invalid_input")
            }

        case 401:
            switch context {
            case .login:
                return AuthL10n.string("error.invalid_credentials")
            case .changePassword,
                 .requestEmailChange:
                return AuthL10n.string("error.session_or_password")
            default:
                return AuthL10n.string("error.session_expired")
            }

        case 403:
            return AuthL10n.string("error.forbidden")

        case 404:
            return AuthL10n.string("error.not_found")

        case 409:
            switch context {
            case .signUp:
                return AuthL10n.string("error.email_in_use")
            case .requestEmailChange,
                 .confirmEmailChange:
                return AuthL10n.string("error.email_in_use")
            default:
                return AuthL10n.string("error.already_processed")
            }

        case 422:
            return AuthL10n.string("error.invalid_input")

        case 429:
            return AuthL10n.string("error.too_many_requests")

        case 500...599:
            return AuthL10n.string("error.server")

        default:
            return AuthL10n.string("error.generic")
        }
    }

    private static func urlErrorMessage(
        _ error: URLError
    ) -> String {
        switch error.code {
        case .notConnectedToInternet:
            return AuthL10n.string("error.no_internet")

        case .timedOut:
            return AuthL10n.string("error.timeout")

        case .cannotConnectToHost,
             .cannotFindHost,
             .dnsLookupFailed:
            return AuthL10n.string("error.cannot_connect")

        case .networkConnectionLost:
            return AuthL10n.string("error.connection_lost")

        default:
            return AuthL10n.string("error.check_network")
        }
    }
}
