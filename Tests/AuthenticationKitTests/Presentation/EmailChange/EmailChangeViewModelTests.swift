//
//  EmailChangeViewModelTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import Testing
@testable import AuthenticationKit

@MainActor
struct EmailChangeViewModelTests {

    @Test
    func requestEmailChangeRequiresCurrentPassword() async {
        let repository = MockAuthenticationRepository()
        let service = AuthenticationService(
            repository: repository,
            tokenStorage: MockTokenStorage()
        )

        let viewModel = EmailChangeViewModel(
            authenticationService: service
        )

        viewModel.newEmail = "new@test.com"

        await viewModel.requestEmailChange()

        #expect(
            viewModel.errorMessage == "현재 비밀번호를 입력해주세요."
        )

        #expect(
            repository.requestEmailChangeCurrentPassword == nil
        )
    }

    @Test
    func requestEmailChangeRequiresNewEmail() async {
        let repository = MockAuthenticationRepository()
        let service = AuthenticationService(
            repository: repository,
            tokenStorage: MockTokenStorage()
        )

        let viewModel = EmailChangeViewModel(
            authenticationService: service
        )

        viewModel.currentPassword = "1234"

        await viewModel.requestEmailChange()

        #expect(
            viewModel.errorMessage == "새 이메일을 입력해주세요."
        )

        #expect(
            repository.requestEmailChangeNewEmail == nil
        )
    }

    @Test
    func requestEmailChangeRejectsInvalidEmail() async {
        let repository = MockAuthenticationRepository()
        let service = AuthenticationService(
            repository: repository,
            tokenStorage: MockTokenStorage()
        )

        let viewModel = EmailChangeViewModel(
            authenticationService: service
        )

        viewModel.currentPassword = "1234"
        viewModel.newEmail = "invalid-email"

        await viewModel.requestEmailChange()

        #expect(
            viewModel.errorMessage == "이메일 주소를 다시 확인해주세요."
        )

        #expect(
            repository.requestEmailChangeNewEmail == nil
        )
    }

    @Test
    func requestEmailChangeUsesExactEmailWithoutNormalization() async {
        let repository = MockAuthenticationRepository()
        let service = AuthenticationService(
            repository: repository,
            tokenStorage: MockTokenStorage()
        )

        let viewModel = EmailChangeViewModel(
            authenticationService: service
        )

        viewModel.currentPassword = "1234"
        viewModel.newEmail = "New@Test.COM"

        await viewModel.requestEmailChange()

        #expect(
            repository.requestEmailChangeCurrentPassword == "1234"
        )

        #expect(
            repository.requestEmailChangeNewEmail == "New@Test.COM"
        )

        #expect(
            viewModel.message == "새 이메일로 인증 안내를 발송했습니다."
        )

        #expect(
            viewModel.errorMessage == nil
        )
    }

    @Test
    func confirmEmailChangeWithoutTokenDoesNothing() async {
        let repository = MockAuthenticationRepository()
        let service = AuthenticationService(
            repository: repository,
            tokenStorage: MockTokenStorage()
        )

        let viewModel = EmailChangeViewModel(
            authenticationService: service
        )

        await viewModel.confirmEmailChange()

        #expect(
            repository.confirmEmailChangeToken == nil
        )

        #expect(
            viewModel.didConfirmEmailChange == false
        )
    }

    @Test
    func confirmEmailChangeSuccessUpdatesStateAndCallsCallback() async throws {
        let updatedUser = User(
            id: "mock-user-id",
            email: "new@test.com",
            isEmailVerified: true
        )

        let repository = MockAuthenticationRepository(
            currentUserResponse: updatedUser
        )

        let tokenStorage = MockTokenStorage()

        let service = AuthenticationService(
            repository: repository,
            tokenStorage: tokenStorage
        )

        _ = try await service.login(
            email: "test@test.com",
            password: "1234"
        )

        let viewModel = EmailChangeViewModel(
            token: "email-change-token",
            authenticationService: service
        )

        var callbackUser: User?

        viewModel.onEmailChangeConfirmed = { user in
            callbackUser = user
        }

        await viewModel.confirmEmailChange()

        #expect(
            repository.confirmEmailChangeToken == "email-change-token"
        )

        #expect(
            viewModel.didConfirmEmailChange
        )

        #expect(
            viewModel.hasConfirmationToken == false
        )

        #expect(
            viewModel.message == "이메일이 변경되었습니다."
        )

        #expect(
            viewModel.errorMessage == nil
        )

        #expect(
            callbackUser?.email == "new@test.com"
        )

        #expect(
            callbackUser?.isEmailVerified == true
        )
    }

    @Test
    func confirmEmailChangeCannotRunTwiceAfterSuccess() async throws {
        let updatedUser = User(
            id: "mock-user-id",
            email: "new@test.com",
            isEmailVerified: true
        )

        let repository = MockAuthenticationRepository(
            currentUserResponse: updatedUser
        )

        let service = AuthenticationService(
            repository: repository,
            tokenStorage: MockTokenStorage()
        )

        _ = try await service.login(
            email: "test@test.com",
            password: "1234"
        )

        let viewModel = EmailChangeViewModel(
            token: "email-change-token",
            authenticationService: service
        )

        await viewModel.confirmEmailChange()

        #expect(
            viewModel.didConfirmEmailChange
        )

        await viewModel.confirmEmailChange()

        #expect(
            repository.confirmEmailChangeToken == "email-change-token"
        )
    }
}
