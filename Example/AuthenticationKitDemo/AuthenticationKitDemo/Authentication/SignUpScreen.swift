//
//  SignUpScreen.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

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
