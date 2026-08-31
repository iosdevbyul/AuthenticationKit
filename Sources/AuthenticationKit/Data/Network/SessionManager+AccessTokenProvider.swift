//
//  SessionManager+AccessTokenProvider.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-31.
//

import NetworkKit

extension SessionManager: AccessTokenProvider {

    public var accessToken: String? {
        currentSession?.accessToken
    }
}
