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
        theme: AuthenticationTheme = .default
    ) {
        self.viewModel = viewModel
        self.theme = theme
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
            Text("로그인 세션")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(theme.text)

            Text("현재 로그인되어 있는 기기와 세션을 관리할 수 있습니다.")
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
                            session.deviceName ?? "알 수 없는 기기"
                        )
                        .font(.headline)
                        .foregroundColor(theme.text)

                        if session.isCurrent {
                            Text("현재 세션")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(theme.primary)
                        }
                    }

                    if let startedAt = session.startedAt {
                        Text(
                            "로그인 \(formattedDate(startedAt))"
                        )
                        .font(.footnote)
                        .foregroundColor(theme.secondaryText)
                    }

                    if let lastRefreshedAt = session.lastRefreshedAt {
                        Text(
                            "최근 갱신 \(formattedDate(lastRefreshedAt))"
                        )
                        .font(.footnote)
                        .foregroundColor(theme.secondaryText)
                    }

                    Text(
                        "만료 \(formattedDate(session.expiresAt))"
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
                        ? "이 세션에서 로그아웃"
                        : "세션 로그아웃"
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
                title: "다른 세션 모두 로그아웃",
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
                Text("모든 세션 로그아웃")
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
        Text("활성화된 세션이 없습니다.")
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

        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return formatter
    }()
}
