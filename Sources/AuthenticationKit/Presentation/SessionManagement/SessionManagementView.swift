//
//  SessionManagementView.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import SwiftUI

public struct SessionManagementView: View {

    @ObservedObject private var viewModel: SessionManagementViewModel

    private let theme: AuthenticationTheme

    public init(
        viewModel: SessionManagementViewModel = SessionManagementViewModel(),
        theme: AuthenticationTheme = .default,
        onCurrentSessionRevoked: (() -> Void)? = nil,
        onAllSessionsLoggedOut: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.theme = theme

        viewModel.onCurrentSessionRevoked = onCurrentSessionRevoked
        viewModel.onAllSessionsLoggedOut = onAllSessionsLoggedOut
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                header

                if let errorMessage = viewModel.errorMessage {
                    errorMessageView(errorMessage)
                }

                if viewModel.sessions.isEmpty,
                   !viewModel.isLoading {
                    emptyView
                } else {
                    sessionList
                }

                actionButtons
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .background(theme.background)
        .onAppear {
            Task {
                await viewModel.loadSessions()
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(AuthL10n.string("auth.session.title"))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(theme.text)

            Text(AuthL10n.string("auth.session.subtitle"))
                .font(.subheadline)
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 32)
    }

    private var sessionList: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.sessions) { session in
                sessionRow(session)
            }
        }
    }

    private func sessionRow(
        _ session: ManagedSession
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(alignment: .top) {

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    HStack(spacing: 8) {
                        Text(
                            session.deviceName ?? AuthL10n.string("auth.session.unknown_device")
                        )
                        .font(.headline)
                        .foregroundColor(theme.text)

                        if session.isCurrent {
                            Text(AuthL10n.string("auth.session.current"))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(theme.primary)
                        }
                    }

                    if let startedAt = session.startedAt {
                        Text(
                            AuthL10n.format(\n                                "auth.session.logged_in",\n                                formattedDate(startedAt)\n                            )
                        )
                        .font(.footnote)
                        .foregroundColor(theme.secondaryText)
                    }

                    if let lastRefreshedAt = session.lastRefreshedAt {
                        Text(
                            AuthL10n.format(\n                                "auth.session.last_refreshed",\n                                formattedDate(lastRefreshedAt)\n                            )
                        )
                        .font(.footnote)
                        .foregroundColor(theme.secondaryText)
                    }

                    Text(
                        AuthL10n.format(\n                            "auth.session.expires",\n                            formattedDate(session.expiresAt)\n                        )
                    )
                    .font(.footnote)
                    .foregroundColor(theme.secondaryText)
                }

                Spacer()
            }

            Button {
                Task {
                    await viewModel.revokeSession(
                        session
                    )
                }
            } label: {
                Text(
                    session.isCurrent
                        ? AuthL10n.string("auth.session.logout_current")
                        : AuthL10n.string("auth.session.logout")
                )
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(theme.error)
            }
            .disabled(viewModel.isLoading)
        }
        .padding(16)
        .background(theme.textField.background)
        .overlay(
            RoundedRectangle(
                cornerRadius: 10
            )
            .stroke(
                theme.border,
                lineWidth: 1
            )
        )
        .cornerRadius(10)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {

            AuthenticationButton(
                title: AuthL10n.string("auth.session.logout_others"),
                isEnabled: hasOtherSessions,
                isLoading: viewModel.isLoading,
                theme: theme
            ) {
                Task {
                    await viewModel.logoutOtherSessions()
                }
            }

            Button {
                Task {
                    await viewModel.logoutAllSessions()
                }
            } label: {
                Text(AuthL10n.string("auth.session.logout_all"))
                    .font(.headline)
                    .foregroundColor(theme.error)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: 10
                        )
                        .stroke(
                            theme.error,
                            lineWidth: 1
                        )
                    )
            }
            .disabled(viewModel.isLoading)
        }
    }

    private var emptyView: some View {
        Text(AuthL10n.string("auth.session.empty"))
            .font(.subheadline)
            .foregroundColor(theme.secondaryText)
            .frame(
                maxWidth: .infinity,
                alignment: .center
            )
            .padding(.vertical, 32)
    }

    private func errorMessageView(
        _ message: String
    ) -> some View {
        Text(message)
            .font(.footnote)
            .foregroundColor(theme.error)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
    }

    private var hasOtherSessions: Bool {
        viewModel.sessions.contains {
            !$0.isCurrent
        }
    }

    private func formattedDate(
        _ date: Date
    ) -> String {
        Self.dateFormatter.string(
            from: date
        )
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()

        formatter.locale = AuthL10n.locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return formatter
    }()
}
