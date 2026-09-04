//
//  ForgotPasswordViewModelTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-04.
//

import Testing
@testable import AuthenticationKit

@MainActor
struct ForgotPasswordViewModelTests {

    @Test
    func emptyEmailShowsError() {
        let viewModel = makeViewModel()

        viewModel.email = ""

        viewModel.forgotPassword()

        #expect(viewModel.errorMessage == "이메일을 입력해주세요.")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isSuccess == false)
    }

    @Test
    func validEmailStartsLoading() {
        let viewModel = makeViewModel()

        viewModel.email = "test@test.com"

        viewModel.forgotPassword()

        #expect(viewModel.isLoading == true)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isSuccess == false)
    }

    @Test
    func successCallsOnForgotPasswordSuccess() async throws {
        let viewModel = makeViewModel()

        var didSucceed = false

        viewModel.onForgotPasswordSuccess = {
            didSucceed = true
        }

        viewModel.email = "test@test.com"

        viewModel.forgotPassword()

        try await waitForTask()

        #expect(didSucceed == true)
    }

    @Test
    func successStopsLoading() async throws {
        let viewModel = makeViewModel()

        viewModel.email = "test@test.com"

        viewModel.forgotPassword()

        try await waitForTask()

        #expect(viewModel.isLoading == false)
    }

    @Test
    func successSetsIsSuccess() async throws {
        let viewModel = makeViewModel()

        viewModel.email = "test@test.com"

        viewModel.forgotPassword()

        try await waitForTask()

        #expect(viewModel.isSuccess == true)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func failureShowsError() async throws {
        let viewModel = makeViewModel(
            shouldFailForgotPassword: true
        )

        viewModel.email = "test@test.com"

        viewModel.forgotPassword()

        try await waitForTask()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.isSuccess == false)
        #expect(viewModel.errorMessage != nil)
    }

    @Test
    func failureDoesNotCallOnForgotPasswordSuccess() async throws {
        let viewModel = makeViewModel(
            shouldFailForgotPassword: true
        )

        var didSucceed = false

        viewModel.onForgotPasswordSuccess = {
            didSucceed = true
        }

        viewModel.email = "test@test.com"

        viewModel.forgotPassword()

        try await waitForTask()

        #expect(didSucceed == false)
    }

    @Test
    func whileLoadingDoesNotStartSecondRequest() async throws {
        let viewModel = makeViewModel()

        var successCount = 0

        viewModel.onForgotPasswordSuccess = {
            successCount += 1
        }

        viewModel.email = "test@test.com"

        viewModel.forgotPassword()
        viewModel.forgotPassword()

        try await waitForTask()

        #expect(successCount == 1)
    }

    private func makeViewModel(
        shouldFailForgotPassword: Bool = false
    ) -> ForgotPasswordViewModel {
        let repository = MockAuthenticationRepository(
            shouldFailForgotPassword: shouldFailForgotPassword
        )

        let useCase = ForgotPasswordUseCase(
            repository: repository
        )

        return ForgotPasswordViewModel(
            forgotPasswordUseCase: useCase
        )
    }

    private func waitForTask() async throws {
        try await Task.sleep(
            nanoseconds: 100_000_000
        )
    }
}
