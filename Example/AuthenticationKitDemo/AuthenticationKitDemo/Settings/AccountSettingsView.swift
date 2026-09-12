//
//  AccountSettingsView.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import SwiftUI
import AuthenticationKit

struct AccountSettingsView: View {

    let session: Session
    let onSessionChanged: (Session) -> Void
    let onSignedOut: () -> Void

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showLogoutConfirmation = false
    @State private var showWithdrawConfirmation = false

    var body: some View {
        List {
            Section("계정") {
                LabeledContent(
                    "이메일",
                    value: session.user.email
                )
                
                NavigationLink {
                    EmailChangeScreen {
                        if let updated = AuthenticationService.shared.currentSession {
                            onSessionChanged(updated)
                        }
                    }
                } label: {
                    Label(
                        "이메일 변경",
                        systemImage: "envelope.badge"
                    )
                }

                NavigationLink {
                    ChangePasswordScreen(
                        onPasswordChanged: onSignedOut
                    )
                } label: {
                    Label(
                        "비밀번호 변경",
                        systemImage: "lock"
                    )
                }
                
                NavigationLink {
                    SessionManagementView(
                        onCurrentSessionRevoked: {
                            onSignedOut()
                        },
                        onAllSessionsLoggedOut: {
                            onSignedOut()
                        }
                    )
                } label: {
                    Label(
                        "세션 관리",
                        systemImage: "iphone.and.arrow.forward"
                    )
                }
            }

            Section {
                Button {
                    showLogoutConfirmation = true
                } label: {
                    Label(
                        "로그아웃",
                        systemImage: "rectangle.portrait.and.arrow.right"
                    )
                }
            }

            Section {
                Button(
                    role: .destructive
                ) {
                    showWithdrawConfirmation = true
                } label: {
                    Label(
                        "회원탈퇴",
                        systemImage: "person.crop.circle.badge.minus"
                    )
                }
            } footer: {
                Text("회원탈퇴 시 계정과 인증 정보가 삭제됩니다.")
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("계정 관리")
        .navigationBarTitleDisplayMode(.inline)
        .disabled(isLoading)
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .confirmationDialog(
            "로그아웃 하시겠습니까?",
            isPresented: $showLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button(
                "로그아웃",
                role: .destructive
            ) {
                logout()
            }

            Button(
                "취소",
                role: .cancel
            ) {}
        }
        .confirmationDialog(
            "정말 회원탈퇴 하시겠습니까?",
            isPresented: $showWithdrawConfirmation,
            titleVisibility: .visible
        ) {
            Button(
                "회원탈퇴",
                role: .destructive
            ) {
                withdraw()
            }

            Button(
                "취소",
                role: .cancel
            ) {}
        } message: {
            Text("이 작업은 되돌릴 수 없습니다.")
        }
    }

    private func logout() {
        perform {
            try await AuthenticationService.shared.logout()
            onSignedOut()
        }
    }

    private func withdraw() {
        perform {
            try await AuthenticationService.shared.withdraw()
            onSignedOut()
        }
    }

    private func perform(
        _ action: @escaping @MainActor () async throws -> Void
    ) {
        isLoading = true
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
