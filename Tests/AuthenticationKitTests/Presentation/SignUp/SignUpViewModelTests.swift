//
//  SignUpViewModelTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-04.
//

import Foundation
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
        viewModel.password = "Password123"
        viewModel.passwordConfirmation = "Password123"

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
        viewModel.passwordConfirmation = "Password123"

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
        viewModel.password = "Password123"
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
        viewModel.password = "Password123"
        viewModel.passwordConfirmation = "Different123"

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
        viewModel.password = "Password123"
        viewModel.passwordConfirmation = "Password123"

        viewModel.signUp()

        #expect(viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func signUpSucceedsCallsOnSignUpSuccess() async throws {
        let viewModel = makeViewModel()

        viewModel.email = "test@test.com"
        viewModel.password = "Password123"
        viewModel.passwordConfirmation = "Password123"

        var didCallSuccess = false
        var receivedSession: Session?

        viewModel.onSignUpSuccess = { session in
            didCallSuccess = true
            receivedSession = session
        }

        viewModel.signUp()

        try await waitForCompletion(viewModel)

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
        viewModel.password = "Password123"
        viewModel.passwordConfirmation = "Password123"

        viewModel.signUp()

        try await waitForCompletion(viewModel)

        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func signUpFailsShowsError() async throws {
        let viewModel = makeViewModel(
            shouldFailSignUp: true
        )

        viewModel.email = "test@test.com"
        viewModel.password = "Password123"
        viewModel.passwordConfirmation = "Password123"

        viewModel.signUp()

        try await waitForCompletion(viewModel)

        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage != nil)
    }

    @Test
    func signUpFailsDoesNotCallOnSignUpSuccess() async throws {
        let viewModel = makeViewModel(
            shouldFailSignUp: true
        )

        viewModel.email = "test@test.com"
        viewModel.password = "Password123"
        viewModel.passwordConfirmation = "Password123"

        var didCallSuccess = false

        viewModel.onSignUpSuccess = { _ in
            didCallSuccess = true
        }

        viewModel.signUp()

        try await waitForCompletion(viewModel)

        #expect(!didCallSuccess)
    }

    @Test
    func signUpWhileLoadingDoesNotStartAnotherSignUp() {
        let viewModel = makeViewModel(
            shouldFailSignUp: true
        )

        viewModel.email = "test@test.com"
        viewModel.password = "Password123"
        viewModel.passwordConfirmation = "Password123"

        viewModel.signUp()

        #expect(viewModel.isLoading)

        viewModel.signUp()

        #expect(viewModel.isLoading)
    }

    private func waitForCompletion(_ model: SignUpViewModel) async throws {
        let deadline = Date().addingTimeInterval(3)
        while model.isLoading, Date() < deadline {
            try await Task.sleep(nanoseconds: 1_000_000)
        }
        #expect(!model.isLoading)
    }

    private func makeViewModel(
        shouldFailSignUp: Bool = false
    ) -> SignUpViewModel {
        let repository = MockAuthenticationRepository(
            shouldFailSignUp: shouldFailSignUp
        )
        let storage = InMemoryTokenStorage()

        let authenticationService = AuthenticationService(
            repository: repository,
            tokenStorage: storage
        )

        return SignUpViewModel(
            authenticationService: authenticationService
        )
    }
}

