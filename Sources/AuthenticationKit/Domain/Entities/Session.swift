//
//  Session.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation

public struct Session: Equatable, Sendable {
    public let user: User
    public let accessToken: String
    public let refreshToken: String?

    public init(
        user: User,
        accessToken: String,
        refreshToken: String? = nil
    ) {
        self.user = user
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
