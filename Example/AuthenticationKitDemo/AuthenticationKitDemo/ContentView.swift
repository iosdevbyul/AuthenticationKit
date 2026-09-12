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
