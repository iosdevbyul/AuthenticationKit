//
//  SessionManagementViewModel.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import Foundation

@MainActor
public final class SessionManagementViewModel: ObservableObject {

    @Published public private(set) var sessions: [ManagedSession] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?

    public var onCurrentSessionRevoked: (() -> Void)?
    public var onAllSessionsLoggedOut: (() -> Void)?

    private let authenticationService: AuthenticationService

    public init(
        authenticationService: AuthenticationService = .shared
    ) {
        self.authenticationService = authenticationService
    }

    public func loadSessions() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            sessions = try await authenticationService.sessions()
        } catch {
            errorMessage = AuthenticationErrorMessageMapper.message(
                for: error,
                context: .session
            )
        }
    }

    public func revokeSession(
        _ session: ManagedSession
    ) async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await authenticationService.revokeSession(
                session
            )

            sessions.removeAll {
                $0.id == session.id
            }

            if session.isCurrent {
                onCurrentSessionRevoked?()
            }
        } catch {
            errorMessage = AuthenticationErrorMessageMapper.message(
                for: error,
                context: .session
            )
        }
    }

    public func logoutOtherSessions() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await authenticationService.logoutOtherSessions()

            sessions.removeAll {
                !$0.isCurrent
            }
        } catch {
            errorMessage = AuthenticationErrorMessageMapper.message(
                for: error,
                context: .session
            )
        }
    }

    public func logoutAllSessions() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            try await authenticationService.logoutAllSessions()

            sessions.removeAll()
            onAllSessionsLoggedOut?()
        } catch {
            errorMessage = AuthenticationErrorMessageMapper.message(
                for: error,
                context: .session
            )
        }
    }
}
