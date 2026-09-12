import SwiftUI
import AuthenticationKit

struct ContentView: View {

    @State private var session: Session?
    @State private var isRestoringSession = true
    @State private var verificationLink: VerificationDestination?
    @State private var invalidVerificationLink = false
    @State private var emailChangeLink: EmailChangeDestination?
    @State private var invalidEmailChangeLink = false
    
    var body: some View {
        Group {
            if isRestoringSession {
                LaunchView()
            } else if let session {
                MainTabView(
                    session: session,
                    onSessionChanged: { newSession in
                        self.session = newSession
                    },
                    onSignedOut: {
                        self.session = nil
                    }
                )
            } else {
                AuthenticationFlowView { session in
                    self.session = session
                }
            }
        }
        .task {
            await restoreSession()
        }
        .onOpenURL { url in
            guard url.scheme?.lowercased() == "waktrainer" else {
                return
            }

            switch url.host {
            case "verify-email":
                guard let link = EmailVerificationLink(url: url) else {
                    invalidVerificationLink = true
                    return
                }

                verificationLink = VerificationDestination(
                    token: link.token
                )

            case "change-email":
                guard let link = EmailChangeLink(url: url) else {
                    invalidEmailChangeLink = true
                    return
                }

                emailChangeLink = EmailChangeDestination(
                    token: link.token
                )

            default:
                return
            }
        }
        .sheet(item: Binding(
            get: { isRestoringSession ? nil : verificationLink },
            set: { verificationLink = $0 }
        )) { destination in
            NavigationStack {
                EmailVerificationScreen(token: destination.token) {
                    session = AuthenticationService.shared.currentSession
                }
                .toolbar {
                    Button("닫기") {
                        verificationLink = nil
                    }
                }
            }
        }
        .sheet(item: Binding(
            get: { isRestoringSession ? nil : emailChangeLink },
            set: { emailChangeLink = $0 }
        )) { destination in
            NavigationStack {
                EmailChangeScreen(token: destination.token) {
                    session = AuthenticationService.shared.currentSession
                }
                .toolbar {
                    Button("닫기") {
                        emailChangeLink = nil
                    }
                }
            }
        }
        .alert("이메일 인증", isPresented: $invalidVerificationLink) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("인증 링크가 유효하지 않거나 만료되었습니다.")
        }
        .alert("이메일 변경", isPresented: $invalidEmailChangeLink) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("이메일 변경 링크가 유효하지 않거나 만료되었습니다.")
        }
    }

    private func restoreSession() async {
        defer {
            isRestoringSession = false
        }

        do {
            try AuthenticationService.shared.restoreSession()

            _ = try await AuthenticationService.shared.currentUser()

            session = AuthenticationService.shared.currentSession
        } catch {
            session = nil
        }
    }
}


// MARK: - Launch

private struct LaunchView: View {

    var body: some View {
        VStack(spacing: 16) {
            Text("WakTrainer")
                .font(.largeTitle.bold())

            ProgressView()
        }
    }
}


// MARK: - Authentication Flow

private struct AuthenticationFlowView: View {

    let onAuthenticated: (Session) -> Void

    var body: some View {
        NavigationStack {
            LoginScreen(
                onAuthenticated: onAuthenticated
            )
        }
    }
}


// MARK: - Login

private struct LoginScreen: View {

    let onAuthenticated: (Session) -> Void

    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack(spacing: 24) {
            LoginView(
                viewModel: viewModel,
                onLoginSuccess: onAuthenticated
            )

            VStack(spacing: 16) {
                NavigationLink {
                    SignUpScreen(
                        onAuthenticated: onAuthenticated
                    )
                } label: {
                    Text("계정이 없으신가요? 회원가입")
                }

                NavigationLink {
                    ForgotPasswordScreen()
                } label: {
                    Text("비밀번호를 잊으셨나요?")
                }
            }
            .padding(.bottom, 32)
        }
    }
}


// MARK: - Sign Up

private struct SignUpScreen: View {

    let onAuthenticated: (Session) -> Void

    @StateObject private var viewModel = SignUpViewModel()

    var body: some View {
        SignUpView(
            viewModel: viewModel,
            onSignUpSuccess: onAuthenticated
        )
    }
}


// MARK: - Forgot Password

private struct ForgotPasswordScreen: View {

    @StateObject private var viewModel = ForgotPasswordViewModel()

    var body: some View {
        VStack(spacing: 20) {
            ForgotPasswordView(
                viewModel: viewModel
            )

            NavigationLink {
                ResetPasswordScreen()
            } label: {
                Text("재설정 토큰 직접 입력")
            }
            .padding(.bottom, 24)
        }
    }
}


// MARK: - Reset Password

private struct ResetPasswordScreen: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ResetPasswordView {
            dismiss()
        }
    }
}


// MARK: - Main

private struct MainTabView: View {

    let session: Session
    let onSessionChanged: (Session) -> Void
    let onSignedOut: () -> Void

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(
                    session: session
                )
            }
            .tabItem {
                Label(
                    "홈",
                    systemImage: "house"
                )
            }

            NavigationStack {
                SettingsView(
                    session: session,
                    onSessionChanged: onSessionChanged,
                    onSignedOut: onSignedOut
                )
            }
            .tabItem {
                Label(
                    "설정",
                    systemImage: "gearshape"
                )
            }
        }
    }
}


// MARK: - Home

private struct HomeView: View {

    let session: Session

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 24
            ) {
                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {
                    Text("WakTrainer")
                        .font(.largeTitle.bold())

                    Text("오늘도 좋은 훈련 되세요.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {
                    Text("로그인 계정")
                        .font(.headline)

                    Text(session.user.email)
                        .foregroundStyle(.secondary)
                    if !session.user.isEmailVerified {
                        Text("이메일 인증 필요 · 설정에서 인증 메일을 재전송할 수 있습니다.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    .regularMaterial,
                    in: RoundedRectangle(
                        cornerRadius: 16
                    )
                )

                Spacer()
            }
            .padding()
        }
        .navigationTitle("홈")
    }
}


// MARK: - Settings

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


// MARK: - Account Settings

private struct AccountSettingsView: View {

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


// MARK: - Change Password

private struct ChangePasswordScreen: View {

    let onPasswordChanged: () -> Void

    @StateObject private var viewModel = ChangePasswordViewModel()

    var body: some View {
        ChangePasswordView(
            viewModel: viewModel
        ) {
            onPasswordChanged()
        }
    }
}


// MARK: - Email Verification

private struct VerificationDestination: Identifiable {
    let id = UUID()
    let token: String
}

private struct EmailVerificationScreen: View {
    @StateObject private var viewModel: EmailVerificationViewModel
    @State private var didHandleLink = false
    let onUserUpdated: () -> Void

    init(token: String? = nil, onUserUpdated: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: EmailVerificationViewModel(token: token))
        self.onUserUpdated = onUserUpdated
    }

    var body: some View {
        EmailVerificationView(viewModel: viewModel)
            .navigationTitle("이메일 인증")
            .onAppear {
                viewModel.onUserUpdated = { _ in onUserUpdated() }
            }
            .task {
                guard !didHandleLink, viewModel.hasVerificationToken else { return }
                didHandleLink = true
                await viewModel.verifyEmail()
            }
    }
}

// MARK: - Email Change

private struct EmailChangeDestination: Identifiable {
    let id = UUID()
    let token: String
}

private struct EmailChangeScreen: View {

    @StateObject private var viewModel: EmailChangeViewModel
    @State private var didHandleLink = false

    let onEmailChanged: () -> Void

    init(
        token: String? = nil,
        onEmailChanged: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: EmailChangeViewModel(
                token: token
            )
        )

        self.onEmailChanged = onEmailChanged
    }

    var body: some View {
        EmailChangeView(
            viewModel: viewModel
        )
        .navigationTitle("이메일 변경")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.onEmailChangeConfirmed = { _ in
                onEmailChanged()
            }
        }
        .task {
            guard !didHandleLink,
                  viewModel.hasConfirmationToken
            else {
                return
            }

            didHandleLink = true
            await viewModel.confirmEmailChange()
        }
    }
}
