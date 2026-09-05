
import SwiftUI
import AuthenticationKit

struct AuthenticationServiceDemoView: View {

    private let service: AuthenticationService

    @State private var statusMessage = "Not authenticated"
    @State private var isLoading = false

    init() {
        let repository = DemoAuthenticationRepository()
        let tokenStorage = DemoTokenStorage()

        self.service = AuthenticationService(
            repository: repository,
            tokenStorage: tokenStorage
        )
    }

    var body: some View {
        List {
            Section("Session") {
                Text(service.isAuthenticated ? "Authenticated" : "Not authenticated")

                if let session = service.currentSession {
                    Text("User: \(session.user.email)")
                    Text("Access Token: \(session.accessToken)")
                }

                Text(statusMessage)
                    .foregroundStyle(.secondary)
            }

            Section("AuthenticationService") {
                Button("Login") {
                    Task {
                        await login()
                    }
                }

                Button("Sign Up") {
                    Task {
                        await signUp()
                    }
                }

                Button("Logout") {
                    Task {
                        await logout()
                    }
                }

                Button("Withdraw") {
                    Task {
                        await withdraw()
                    }
                }

                Button("Forgot Password") {
                    Task {
                        await forgotPassword()
                    }
                }

                Button("Change Password") {
                    Task {
                        await changePassword()
                    }
                }

                Button("Restore Session") {
                    restoreSession()
                }
            }
        }
        .navigationTitle("Service Demo")
        .disabled(isLoading)
    }

    private func login() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let session = try await service.login(
                email: "test@test.com",
                password: "1234"
            )

            statusMessage = "Login succeeded: \(session.user.email)"
        } catch {
            statusMessage = "Login failed: \(error)"
        }
    }

    private func signUp() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let email = "new-\(UUID().uuidString)@test.com"

            let session = try await service.signUp(
                email: email,
                password: "1234"
            )

            statusMessage = "Sign up succeeded: \(session.user.email)"
        } catch {
            statusMessage = "Sign up failed: \(error)"
        }
    }

    private func logout() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await service.logout()
            statusMessage = "Logout succeeded"
        } catch {
            statusMessage = "Logout failed: \(error)"
        }
    }

    private func withdraw() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await service.withdraw()
            statusMessage = "Withdraw succeeded"
        } catch {
            statusMessage = "Withdraw failed: \(error)"
        }
    }

    private func forgotPassword() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await service.forgotPassword(
                email: "test@test.com"
            )

            statusMessage = "Forgot password succeeded"
        } catch {
            statusMessage = "Forgot password failed: \(error)"
        }
    }

    private func changePassword() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await service.changePassword(
                currentPassword: "1234",
                newPassword: "5678"
            )

            statusMessage = "Change password succeeded"
        } catch {
            statusMessage = "Change password failed: \(error)"
        }
    }

    private func restoreSession() {
        do {
            try service.restoreSession()

            if service.isAuthenticated {
                statusMessage = "Session restored"
            } else {
                statusMessage = "No saved session"
            }
        } catch {
            statusMessage = "Restore session failed: \(error)"
        }
    }
}
