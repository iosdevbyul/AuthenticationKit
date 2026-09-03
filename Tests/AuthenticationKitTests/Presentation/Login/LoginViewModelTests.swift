//
//  LoginViewModelTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-04.
//

import Testing
@testable import AuthenticationKit

@MainActor
struct LoginViewModelTests {

    @Test
    func loginWithEmptyEmailShowsError() {
        let viewModel = makeViewModel()

        viewModel.email = ""
        viewModel.password = "1234"

        viewModel.login()

        #expect(
            viewModel.errorMessage
                == "이메일과 비밀번호를 입력해주세요."
        )
        #expect(!viewModel.isLoading)
    }

    @Test
    func loginWithEmptyPasswordShowsError() {
        let viewModel = makeViewModel()

        viewModel.email = "test@test.com"
        viewModel.password = ""

        viewModel.login()

        #expect(
            viewModel.errorMessage
                == "이메일과 비밀번호를 입력해주세요."
        )
        #expect(!viewModel.isLoading)
    }

    @Test
    func loginWithValidCredentialsStartsLoading() {
        let viewModel = makeViewModel()

        viewModel.email = "test@test.com"
        viewModel.password = "1234"

        viewModel.login()

        #expect(viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func loginSucceedsCallsOnLoginSuccess() async throws {
        let viewModel = makeViewModel()

        viewModel.email = "test@test.com"
        viewModel.password = "1234"

        let expectation = AsyncStream<Void>.Continuation.self

        var didCallSuccess = false
        var receivedSession: Session?

        viewModel.onLoginSuccess = { session in
            didCallSuccess = true
            receivedSession = session
        }

        viewModel.login()

        try await Task.sleep(
            nanoseconds: 100_000_000
        )

        #expect(didCallSuccess)
        #expect(receivedSession?.user.email == "test@test.com")
        #expect(receivedSession?.accessToken == "mock-access-token")

        _ = expectation
    }

    @Test
    func loginSucceedsStopsLoading() async throws {
        let viewModel = makeViewModel()

        viewModel.email = "test@test.com"
        viewModel.password = "1234"

        viewModel.login()

        try await Task.sleep(
            nanoseconds: 100_000_000
        )

        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func loginFailsShowsError() async throws {
        let viewModel = makeViewModel()

        viewModel.email = "test@test.com"
        viewModel.password = "wrong-password"

        viewModel.login()

        try await Task.sleep(
            nanoseconds: 100_000_000
        )

        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage != nil)
    }

    @Test
    func loginFailsDoesNotCallOnLoginSuccess() async throws {
        let viewModel = makeViewModel()

        viewModel.email = "test@test.com"
        viewModel.password = "wrong-password"

        var didCallSuccess = false

        viewModel.onLoginSuccess = { _ in
            didCallSuccess = true
        }

        viewModel.login()

        try await Task.sleep(
            nanoseconds: 100_000_000
        )

        #expect(!didCallSuccess)
    }

    @Test
    func loginWhileLoadingDoesNotStartAnotherLogin() {
        let viewModel = makeViewModel()

        viewModel.email = "test@test.com"
        viewModel.password = "1234"

        viewModel.login()

        #expect(viewModel.isLoading)

        viewModel.login()

        #expect(viewModel.isLoading)
    }

    private func makeViewModel() -> LoginViewModel {
        let repository = MockAuthenticationRepository()
        let storage = InMemoryTokenStorage()

        let sessionManager = SessionManager(
            tokenStorage: storage
        )

        let useCase = LoginUseCase(
            repository: repository,
            sessionManager: sessionManager
        )

        return LoginViewModel(
            loginUseCase: useCase
        )
    }
}
