//
//  AuthenticationError.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation

public enum AuthenticationError: Error, Equatable, Sendable {
    case invalidCredentials
    case invalidInput
}
