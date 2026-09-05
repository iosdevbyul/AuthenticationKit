//
//  AuthenticationServiceTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-05.
//

import Testing
@testable import AuthenticationKit

struct AuthenticationServiceTests {

    @Test
    func loginSuccessUpdatesSession() async throws {
        let repository = MockAuthenticationRepository()
        let tokenStorage = MockTokenStorage()

        let service = AuthenticationService(
            repository: repository,
            tokenStorage: tokenStorage
        )

        let session = try await service.login(
            email: "test@test.com",
            password: "1234"
        )

        #expect(session.user.email == "test@test.com")
        #expect(service.isAuthenticated)
        #expect(service.currentSession == session)
        #expect(tokenStorage.savedSession == session)
    }

    @Test
    func signUpSuccessUpdatesSession() async throws {
        let repository = MockAuthenticationRepository()
        let tokenStorage = MockTokenStorage()

        let service = AuthenticationService(
            repository: repository,
            tokenStorage: tokenStorage
        )

        let session = try await service.signUp(
            email: "new@test.com",
            password: "1234"
        )

        #expect(session.user.email == "new@test.com")
        #expect(service.isAuthenticated)
        #expect(service.currentSession == session)
        #expect(tokenStorage.savedSession == session)
    }

    @Test
    func logoutSuccessClearsSession() async throws {
        let repository = MockAuthenticationRepository()
        let tokenStorage = MockTokenStorage()

        let service = AuthenticationService(
            repository: repository,
            tokenStorage: tokenStorage
        )

        _ = try await service.login(
            email: "test@test.com",
            password: "1234"
        )

        #expect(service.isAuthenticated)

        try await service.logout()

        #expect(!service.isAuthenticated)
        #expect(service.currentSession == nil)
        #expect(tokenStorage.savedSession == nil)
    }

    @Test
    func withdrawSuccessClearsSession() async throws {
        let repository = MockAuthenticationRepository()
        let tokenStorage = MockTokenStorage()

        let service = AuthenticationService(
            repository: repository,
            tokenStorage: tokenStorage
        )

        _ = try await service.login(
            email: "test@test.com",
            password: "1234"
        )

        #expect(service.isAuthenticated)

        try await service.withdraw()

        #expect(!service.isAuthenticated)
        #expect(service.currentSession == nil)
        #expect(tokenStorage.savedSession == nil)
    }

    @Test
    func forgotPasswordSuccessCompletes() async throws {
        let repository = MockAuthenticationRepository()
        let tokenStorage = MockTokenStorage()

        let service = AuthenticationService(
            repository: repository,
            tokenStorage: tokenStorage
        )

        try await service.forgotPassword(
            email: "test@test.com"
        )
    }

    @Test
    func changePasswordSuccessCompletes() async throws {
        let repository = MockAuthenticationRepository()
        let tokenStorage = MockTokenStorage()

        let service = AuthenticationService(
            repository: repository,
            tokenStorage: tokenStorage
        )

        try await service.changePassword(
            currentPassword: "1234",
            newPassword: "5678"
        )
    }

    @Test
    func loginFailureDoesNotCreateSession() async throws {
        let repository = MockAuthenticationRepository()
        let tokenStorage = MockTokenStorage()

        let service = AuthenticationService(
            repository: repository,
            tokenStorage: tokenStorage
        )

        do {
            _ = try await service.login(
                email: "wrong@test.com",
                password: "wrong"
            )

            Issue.record("Expected login to throw an error.")
        } catch {
            #expect(!service.isAuthenticated)
            #expect(service.currentSession == nil)
            #expect(tokenStorage.savedSession == nil)
        }
    }

    @Test
    func signUpFailureDoesNotCreateSession() async throws {
        let repository = MockAuthenticationRepository(
            shouldFailSignUp: true
        )
        let tokenStorage = MockTokenStorage()

        let service = AuthenticationService(
            repository: repository,
            tokenStorage: tokenStorage
        )

        do {
            _ = try await service.signUp(
                email: "test@test.com",
                password: "1234"
            )

            Issue.record("Expected sign up to throw an error.")
        } catch {
            #expect(!service.isAuthenticated)
            #expect(service.currentSession == nil)
            #expect(tokenStorage.savedSession == nil)
        }
    }

    @Test
    func withdrawFailureKeepsExistingSession() async throws {
        let repository = MockAuthenticationRepository()
        let tokenStorage = MockTokenStorage()

        let service = AuthenticationService(
            repository: repository,
            tokenStorage: tokenStorage
        )

        let session = try await service.login(
            email: "test@test.com",
            password: "1234"
        )

        let failingRepository = MockAuthenticationRepository(
            shouldFailWithdrawal: true
        )

        let failingService = AuthenticationService(
            repository: failingRepository,
            tokenStorage: tokenStorage
        )

        try tokenStorage.save(session: session)
        try failingService.restoreSession()

        do {
            try await failingService.withdraw()

            Issue.record("Expected withdraw to throw an error.")
        } catch {
            #expect(failingService.isAuthenticated)
            #expect(failingService.currentSession == session)
            #expect(tokenStorage.savedSession == session)
        }
    }

    @Test
    func restoreSessionRestoresSavedSession() throws {
        let repository = MockAuthenticationRepository()
        let tokenStorage = MockTokenStorage()

        let service = AuthenticationService(
            repository: repository,
            tokenStorage: tokenStorage
        )

        let session = Session(
            user: User(
                id: "user-id",
                email: "test@test.com"
            ),
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )

        try tokenStorage.save(session: session)
        try service.restoreSession()

        #expect(service.isAuthenticated)
        #expect(service.currentSession == session)
    }
}
