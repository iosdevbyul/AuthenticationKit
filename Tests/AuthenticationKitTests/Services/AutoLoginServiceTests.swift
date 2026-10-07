import Testing
@testable import AuthenticationKit

struct AutoLoginServiceTests {

    @Test
    func disabledAutoLoginDoesNotRestoreStoredSession() throws {
        let storage = InMemoryTokenStorage()
        let preference =
            TestAutoLoginPreference(
                isEnabled: false
            )
        let session = makeSession()

        try storage.save(session: session)

        let service = AuthenticationService(
            repository:
                MockAuthenticationRepository(),
            tokenStorage: storage,
            autoLoginPreference: preference
        )

        try service.restoreSession()

        #expect(!service.isAuthenticated)
        #expect(try storage.loadSession() == nil)
    }

    @Test
    func enabledAutoLoginRestoresStoredSession() throws {
        let storage = InMemoryTokenStorage()
        let preference =
            TestAutoLoginPreference(
                isEnabled: true
            )
        let session = makeSession()

        try storage.save(session: session)

        let service = AuthenticationService(
            repository:
                MockAuthenticationRepository(),
            tokenStorage: storage,
            autoLoginPreference: preference
        )

        try service.restoreSession()

        #expect(service.currentSession == session)
        #expect(service.isAuthenticated)
    }

    private func makeSession() -> Session {
        Session(
            user: User(
                id: "user-1",
                email: "test@test.com"
            ),
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )
    }
}

private final class TestAutoLoginPreference:
    AutoLoginPreference,
    @unchecked Sendable {

    private(set) var isEnabled: Bool

    init(
        isEnabled: Bool
    ) {
        self.isEnabled = isEnabled
    }

    func setEnabled(
        _ isEnabled: Bool
    ) {
        self.isEnabled = isEnabled
    }
}
