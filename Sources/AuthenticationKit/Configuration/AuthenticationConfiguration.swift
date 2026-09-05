//
//  AuthenticationConfiguration.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-05.
//

import Foundation

public final class AuthenticationConfiguration: @unchecked Sendable {

    public static let shared = AuthenticationConfiguration()

    private(set) public var baseURL: URL?

    private init() {}

    public func configure(baseURL: URL) {
        self.baseURL = baseURL
    }
}
