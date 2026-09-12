//
//  SettingsView.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

private struct SettingsView: View {

    let session: Session
    let onSessionChanged: (Session) -> Void
    let onSignedOut: () -> Void

    @State private var message: String?
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        List {
            Section("프로필") {
                LabeledContent(
                    "이메일",
                    value: session.user.email
                )
            }

            Section {
                NavigationLink {
                    AccountSettingsView(
                        session: session,
                        onSessionChanged: onSessionChanged,
                        onSignedOut: onSignedOut
                    )
                } label: {
                    Label(
                        "계정 관리",
                        systemImage: "person.crop.circle"
                    )
                }
            }

            if !session.user.isEmailVerified {
                Section("이메일 인증 필요") {
                    NavigationLink {
                        EmailVerificationScreen {
                            if let updated = AuthenticationService.shared.currentSession {
                                onSessionChanged(updated)
                            }
                        }
                    } label: {
                        Label("이메일 인증 / 메일 재전송", systemImage: "envelope")
                    }
                }
            }

            Section("세션") {
                Button {
                    currentUser()
                } label: {
                    Label(
                        "현재 사용자 확인",
                        systemImage: "person.text.rectangle"
                    )
                }

                Button {
                    refreshSession()
                } label: {
                    Label(
                        "세션 갱신",
                        systemImage: "arrow.clockwise"
                    )
                }
            }

            if let message {
                Section {
                    Text(message)
                        .foregroundStyle(.secondary)
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("설정")
        .disabled(isLoading)
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
    }

    private func currentUser() {
        perform {
            let user = try await AuthenticationService.shared.currentUser()

            if let updated = AuthenticationService.shared.currentSession {
                onSessionChanged(updated)
            }
            message = "현재 사용자: \(user.email)"
        }
    }

    private func refreshSession() {
        perform {
            let newSession = try await AuthenticationService.shared.refreshSession()

            onSessionChanged(newSession)
            message = "세션을 갱신했습니다."
        }
    }

    private func perform(
        _ action: @escaping @MainActor () async throws -> Void
    ) {
        isLoading = true
        message = nil
        errorMessage = nil

        Task { @MainActor in
            defer {
                isLoading = false
            }

            do {
                try await action()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
