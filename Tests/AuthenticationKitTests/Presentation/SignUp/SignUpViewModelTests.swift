//
//  SignUpViewModelTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-04.
//

import Testing
@testable import AuthenticationKit

@MainActor
struct SignUpViewModelTests {

    @Test
    func signUpWithEmptyEmailShowsError() {
        let viewModel = makeViewModel(
            shouldFailSignUp: true
        )

        viewModel.email = ""
        viewModel.password = "1234"
        viewModel.passwordConfirmation = "1234"

        viewModel.signUp()

        #expect(viewModel.errorMessage == "이메일을 입력해주세요.")
        #expect(!viewModel.isLoading)
    }

    @Test
    func signUpWithEmptyPasswordShowsError() {
        let viewModel = makeViewModel(
            shouldFailSignUp: true
        )

        viewModel.email = "test@test.com"
        viewModel.password = ""
        viewModel.passwordConfirmation = "1234"

        viewModel.signUp()

        #expect(viewModel.errorMessage == "비밀번호를 입력해주세요.")
        #expect(!viewModel.isLoading)
    }

    @Test
    func signUpWithEmptyPasswordConfirmationShowsError() {
        let viewModel = makeViewModel(
            shouldFailSignUp: true
        )

        viewModel.email = "test@test.com"
        viewModel.password = "1234"
        viewModel.passwordConfirmation = ""

        viewModel.signUp()

        #expect(
            viewModel.errorMessage
                == "비밀번호를 한 번 더 입력해주세요."
        )
        #expect(!viewModel.isLoading)
    }

    @Test
    func signUpWithMismatchedPasswordsShowsError() {
        let viewModel = makeViewModel(
            shouldFailSignUp: true
        )

        viewModel.email = "test@test.com"
        viewModel.password = "1234"
        viewModel.passwordConfirmation = "5678"

        viewModel.signUp()

        #expect(
            viewModel.errorMessage
                == "비밀번호가 일치하지 않습니다."
        )
        #expect(!viewModel.isLoading)
    }

    @Test
    func signUpWithValidCredentialsStartsLoading() {
        let viewModel = makeViewModel(
            shouldFailSignUp: true
        )

        viewModel.email = "test@test.com"
        viewModel.password = "1234"
        viewModel.passwordConfirmation = "1234"

        viewModel.signUp()

        #expect(viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func signUpSucceedsCallsOnSignUpSuccess() async throws {
        let viewModel = makeViewModel()

        viewModel.email = "test@test.com"
        viewModel.password = "1234"
        viewModel.passwordConfirmation = "1234"

        var didCallSuccess = false
        var receivedSession: Session?

        viewModel.onSignUpSuccess = { session in
            didCallSuccess = true
            receivedSession = session
        }

        viewModel.signUp()

        try await Task.sleep(
            nanoseconds: 100_000_000
        )

        #expect(didCallSuccess)
        #expect(receivedSession?.user.email == "test@test.com")
        #expect(
            receivedSession?.accessToken
                == "mock-access-token-test@test.com"
        )
    }

    @Test
    func signUpSucceedsStopsLoading() async throws {
        let viewModel = makeViewModel()

        viewModel.email = "test@test.com"
        viewModel.password = "1234"
        viewModel.passwordConfirmation = "1234"

        viewModel.signUp()

        try await Task.sleep(
            nanoseconds: 100_000_000
        )

        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func signUpFailsShowsError() async throws {
        let viewModel = makeViewModel(
            shouldFailSignUp: true
        )

        viewModel.email = "test@test.com"
        viewModel.password = "1234"
        viewModel.passwordConfirmation = "1234"

        viewModel.signUp()

        try await Task.sleep(
            nanoseconds: 100_000_000
        )

        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage != nil)
    }

    @Test
    func signUpFailsDoesNotCallOnSignUpSuccess() async throws {
        let viewModel = makeViewModel(
            shouldFailSignUp: true
        )

        viewModel.email = "test@test.com"
        viewModel.password = "1234"
        viewModel.passwordConfirmation = "1234"

        var didCallSuccess = false

        viewModel.onSignUpSuccess = { _ in
            didCallSuccess = true
        }

        viewModel.signUp()

        try await Task.sleep(
            nanoseconds: 100_000_000
        )

        #expect(!didCallSuccess)
    }

    @Test
    func signUpWhileLoadingDoesNotStartAnotherSignUp() {
        let viewModel = makeViewModel(
            shouldFailSignUp: true
        )

        viewModel.email = "test@test.com"
        viewModel.password = "1234"
        viewModel.passwordConfirmation = "1234"

        viewModel.signUp()

        #expect(viewModel.isLoading)

        viewModel.signUp()

        #expect(viewModel.isLoading)
    }

    private func makeViewModel(
        shouldFailSignUp: Bool = false
    ) -> SignUpViewModel {
        let repository = MockAuthenticationRepository(
            shouldFailSignUp: shouldFailSignUp
        )

        let storage = InMemoryTokenStorage()

        let sessionManager = SessionManager(
            tokenStorage: storage
        )

        let useCase = SignUpUseCase(
            repository: repository,
            sessionManager: sessionManager
        )

        return SignUpViewModel(
            signUpUseCase: useCase
        )
    }
}

