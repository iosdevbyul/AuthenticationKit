//
//  SessionManagementDTOs.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import Foundation

struct SessionListResponseDTO: Decodable {
    let sessions: [ManagedSessionResponseDTO]
}

struct ManagedSessionResponseDTO: Decodable {
    let id: String
    let createdAt: Date?
    let startedAt: Date?
    let expiresAt: Date
    let lastRefreshedAt: Date?
    let isCurrent: Bool
    let deviceName: String?

    func toDomain() -> ManagedSession {
        ManagedSession(
            id: id,
            createdAt: createdAt,
            startedAt: startedAt,
            expiresAt: expiresAt,
            lastRefreshedAt: lastRefreshedAt,
            isCurrent: isCurrent,
            deviceName: deviceName
        )
    }
}
