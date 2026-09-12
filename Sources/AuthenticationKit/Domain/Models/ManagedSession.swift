//
//  ManagedSession.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import Foundation

public struct ManagedSession: Sendable, Equatable, Identifiable {

    public let id: String
    public let createdAt: Date?
    public let startedAt: Date?
    public let expiresAt: Date
    public let lastRefreshedAt: Date?
    public let isCurrent: Bool
    public let deviceName: String?

    public init(
        id: String,
        createdAt: Date?,
        startedAt: Date?,
        expiresAt: Date,
        lastRefreshedAt: Date?,
        isCurrent: Bool,
        deviceName: String?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.startedAt = startedAt
        self.expiresAt = expiresAt
        self.lastRefreshedAt = lastRefreshedAt
        self.isCurrent = isCurrent
        self.deviceName = deviceName
    }
}
