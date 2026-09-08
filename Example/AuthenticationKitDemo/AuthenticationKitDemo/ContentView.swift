import SwiftUI
import AuthenticationKit

struct ContentView: View {
    @StateObject private var loginModel = LoginViewModel()
    @StateObject private var signUpModel = SignUpViewModel()
    @StateObject private var forgotPasswordModel = ForgotPasswordViewModel()
    @StateObject private var changePasswordModel = ChangePasswordViewModel()
    @State private var session: Session?
    @State private var message: String?
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            List {
                Section("Session") {
                    Text(session?.user.email ?? "Not signed in")
                        .accessibilityIdentifier("sessionEmail")
                    if let message { Text(message).accessibilityIdentifier("sessionMessage") }
                    if let errorMessage { Text(errorMessage).foregroundStyle(.red) }
                }
                NavigationLink("Login") {
                    LoginView(viewModel: loginModel) { session in
                        self.session = session
                        message = "Login succeeded"
                    }
                    .overlay(alignment: .bottom) {
                        if message == "Login succeeded" { Text("Login succeeded") }
                    }
                }
                NavigationLink("Sign Up") {
                    SignUpView(viewModel: signUpModel) { session in
                        self.session = session
                        message = "Sign up succeeded"
                    }
                    .overlay(alignment: .bottom) {
                        if message == "Sign up succeeded" { Text("Sign up succeeded") }
                    }
                }
                NavigationLink("Forgot Password") { ForgotPasswordView(viewModel: forgotPasswordModel) }
                NavigationLink("Reset Password") {
                    ResetPasswordView { session = nil; message = "Password reset; please log in" }
                }
                NavigationLink("Change Password") {
                    ChangePasswordView(viewModel: changePasswordModel) { session = nil; message = "Password changed; please log in" }
                }
                Button("Current User") {
                    perform {
                        let user = try await AuthenticationService.shared.currentUser()
                        message = "Current user: \(user.email)"
                    }
                }
                Button("Refresh Session") {
                    perform {
                        session = try await AuthenticationService.shared.refreshSession()
                        message = "Session refreshed"
                    }
                }
                Button("Logout") {
                    perform {
                        try await AuthenticationService.shared.logout()
                        session = nil
                        message = "Logged out"
                    }
                }
                Button("Withdraw", role: .destructive) {
                    perform {
                        try await AuthenticationService.shared.withdraw()
                        session = nil
                        message = "Account withdrawn"
                    }
                }
            }
            .disabled(isLoading)
            .navigationTitle("AuthenticationKit Demo")
            .task {
                do {
                    try AuthenticationService.shared.restoreSession()
                    session = AuthenticationService.shared.currentSession
                } catch { errorMessage = error.localizedDescription }
            }
        }
    }

    private func perform(_ action: @escaping @MainActor () async throws -> Void) {
        isLoading = true
        errorMessage = nil
        Task { @MainActor in
            defer { isLoading = false }
            do { try await action() }
            catch { errorMessage = error.localizedDescription }
        }
    }
}
