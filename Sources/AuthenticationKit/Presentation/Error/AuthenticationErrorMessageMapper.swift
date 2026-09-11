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
                return "인증 링크가 유효하지 않거나 만료되었습니다."
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

        return "요청 처리 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
    }

    private static func authenticationMessage(
        _ error: AuthenticationError
    ) -> String {
        switch error {
        case .invalidCredentials:
            return "이메일 또는 비밀번호가 올바르지 않습니다."

        case .invalidInput:
            return "입력한 정보를 다시 확인해주세요."

        case .unsupportedOperation:
            return "현재 지원하지 않는 기능입니다."

        case .withdrawalFailed:
            return "회원탈퇴 처리에 실패했습니다. 잠시 후 다시 시도해주세요."
        }
    }

    private static func networkMessage(
        _ error: NetworkError,
        context: AuthenticationErrorContext
    ) -> String {
        switch error {
        case .invalidURL:
            return "서버 주소가 올바르지 않습니다."

        case .invalidResponse:
            return "서버 응답을 확인할 수 없습니다. 잠시 후 다시 시도해주세요."

        case .decodingFailed:
            return "서버 응답을 처리하지 못했습니다. 잠시 후 다시 시도해주세요."

        case .serverError(let statusCode):
            return serverMessage(
                statusCode: statusCode,
                context: context
            )

        case .unknown(let error):
            if let urlError = error as? URLError {
                return urlErrorMessage(urlError)
            }

            return "네트워크 요청 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        }
    }

    private static func serverMessage(
        statusCode: Int,
        context: AuthenticationErrorContext
    ) -> String {
        if context == .resendVerificationEmail, [404, 409, 429].contains(statusCode) {
            return "가입된 이메일인 경우 인증 메일이 전송됩니다."
        }
        switch statusCode {
        case 400:
            switch context {
            case .verifyEmail:
                return "인증 링크가 유효하지 않거나 만료되었습니다."

            case .resetPassword:
                return "비밀번호 재설정 링크가 유효하지 않거나 만료되었습니다."

            case .forgotPassword:
                return "이메일 주소를 다시 확인해주세요."
            case .confirmEmailChange:
                return "이메일 변경 링크가 유효하지 않거나 만료되었습니다."
            default:
                return "입력한 정보를 다시 확인해주세요."
            }

        case 401:
            switch context {
            case .login:
                return "이메일 또는 비밀번호가 올바르지 않습니다."
            case .changePassword,
                 .requestEmailChange:
                return "현재 비밀번호가 올바르지 않거나 로그인이 만료되었습니다."
            default:
                return "로그인이 만료되었습니다. 다시 로그인해주세요."
            }

        case 403:
            return "요청을 수행할 권한이 없습니다."

        case 404:
            return "요청한 정보를 찾을 수 없습니다."

        case 409:
            switch context {
            case .signUp:
                return "이미 사용 중인 이메일입니다."
            case .requestEmailChange,
                 .confirmEmailChange:
                return "이미 사용 중인 이메일입니다."
            default:
                return "이미 처리된 요청입니다."
            }

        case 422:
            return "입력한 정보를 다시 확인해주세요."

        case 429:
            return "요청이 너무 많습니다. 잠시 후 다시 시도해주세요."

        case 500...599:
            return "서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요."

        default:
            return "요청 처리 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
        }
    }

    private static func urlErrorMessage(
        _ error: URLError
    ) -> String {
        switch error.code {
        case .notConnectedToInternet:
            return "인터넷 연결을 확인해주세요."

        case .timedOut:
            return "요청 시간이 초과되었습니다. 다시 시도해주세요."

        case .cannotConnectToHost,
             .cannotFindHost,
             .dnsLookupFailed:
            return "서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요."

        case .networkConnectionLost:
            return "네트워크 연결이 끊어졌습니다. 다시 시도해주세요."

        default:
            return "네트워크 연결을 확인한 후 다시 시도해주세요."
        }
    }
}
