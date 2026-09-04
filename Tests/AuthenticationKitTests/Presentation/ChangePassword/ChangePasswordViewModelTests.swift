//
//  ChangePasswordViewModelTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-04.
//

import Testing
@testable import AuthenticationKit

@MainActor
struct ChangePasswordViewModelTests {

    @Test
    func emptyCurrentPasswordShowsError() {
        let viewModel = makeViewModel()

        viewModel.currentPassword = ""
        viewModel.newPassword = "new-password"
        viewModel.passwordConfirmation = "new-password"

        viewModel.changePassword()

        #expect(viewModel.errorMessage == "현재 비밀번호를 입력해주세요.")
        #expect(viewModel.isLoading == false)
    }

    @Test
    func emptyNewPasswordShowsError() {
        let viewModel = makeViewModel()

        viewModel.currentPassword = "current-password"
        viewModel.newPassword = ""
        viewModel.passwordConfirmation = "new-password"

        viewModel.changePassword()

        #expect(viewModel.errorMessage == "새 비밀번호를 입력해주세요.")
        #expect(viewModel.isLoading == false)
    }

    @Test
    func emptyPasswordConfirmationShowsError() {
        let viewModel = makeViewModel()

        viewModel.currentPassword = "current-password"
        viewModel.newPassword = "new-password"
        viewModel.passwordConfirmation = ""

        viewModel.changePassword()

        #expect(viewModel.errorMessage == "새 비밀번호를 한 번 더 입력해주세요.")
        #expect(viewModel.isLoading == false)
    }

    @Test
    func mismatchedPasswordsShowsError() {
        let viewModel = makeViewModel()

        viewModel.currentPassword = "current-password"
        viewModel.newPassword = "new-password"
        viewModel.passwordConfirmation = "different-password"

        viewModel.changePassword()

        #expect(viewModel.errorMessage == "비밀번호가 일치하지 않습니다.")
        #expect(viewModel.isLoading == false)
    }

    @Test
    func validPasswordsStartsLoading() {
        let viewModel = makeViewModel()

        viewModel.currentPassword = "current-password"
        viewModel.newPassword = "new-password"
        viewModel.passwordConfirmation = "new-password"

        viewModel.changePassword()

        #expect(viewModel.isLoading == true)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func successCallsOnChangePasswordSuccess() async throws {
        let viewModel = makeViewModel()

        var didSucceed = false

        viewModel.onChangePasswordSuccess = {
            didSucceed = true
        }

        setValidPasswords(for: viewModel)

        viewModel.changePassword()

        try await waitForTask()

        #expect(didSucceed == true)
    }

    @Test
    func successStopsLoading() async throws {
        let viewModel = makeViewModel()

        setValidPasswords(for: viewModel)

        viewModel.changePassword()

        try await waitForTask()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func failureShowsError() async throws {
        let viewModel = makeViewModel(
            shouldFailChangePassword: true
        )

        setValidPasswords(for: viewModel)

        viewModel.changePassword()

        try await waitForTask()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
    }

    @Test
    func failureDoesNotCallOnChangePasswordSuccess() async throws {
        let viewModel = makeViewModel(
            shouldFailChangePassword: true
        )

        var didSucceed = false

        viewModel.onChangePasswordSuccess = {
            didSucceed = true
        }

        setValidPasswords(for: viewModel)

        viewModel.changePassword()

        try await waitForTask()

        #expect(didSucceed == false)
    }

    @Test
    func whileLoadingDoesNotStartSecondRequest() async throws {
        let viewModel = makeViewModel()

        var successCount = 0

        viewModel.onChangePasswordSuccess = {
            successCount += 1
        }

        setValidPasswords(for: viewModel)

        viewModel.changePassword()
        viewModel.changePassword()

        try await waitForTask()

        #expect(successCount == 1)
    }

    private func makeViewModel(
        shouldFailChangePassword: Bool = false
    ) -> ChangePasswordViewModel {
        let repository = MockAuthenticationRepository(
            shouldFailChangePassword: shouldFailChangePassword
        )

        let useCase = ChangePasswordUseCase(
            repository: repository
        )

        return ChangePasswordViewModel(
            changePasswordUseCase: useCase
        )
    }

    private func setValidPasswords(
        for viewModel: ChangePasswordViewModel
    ) {
        viewModel.currentPassword = "current-password"
        viewModel.newPassword = "new-password"
        viewModel.passwordConfirmation = "new-password"
    }

    private func waitForTask() async throws {
        try await Task.sleep(
            nanoseconds: 100_000_000
        )
    }
}
