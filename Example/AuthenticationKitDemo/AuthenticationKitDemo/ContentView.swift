//
//  ContentView.swift
//  AuthenticationKitDemo
//
//  Created by COMATOKI on 2026-09-05.
//

import SwiftUI
import AuthenticationKit

struct ContentView: View {

    private let repository = DemoAuthenticationRepository()

    var body: some View {
        NavigationView {
            List {
                NavigationLink("Login") {
                    LoginView(
                        viewModel: LoginViewModel(
                            loginUseCase: LoginUseCase(
                                repository: repository,
                                sessionManager: SessionManager(
                                    tokenStorage: DemoTokenStorage()
                                )
                            )
                        )
                    )
                }

                NavigationLink("Sign Up") {
                    SignUpView(
                        viewModel: SignUpViewModel(
                            signUpUseCase: SignUpUseCase(
                                repository: repository,
                                sessionManager: SessionManager(
                                    tokenStorage: DemoTokenStorage()
                                )
                            )
                        )
                    )
                }

                NavigationLink("Forgot Password") {
                    ForgotPasswordView(
                        viewModel: ForgotPasswordViewModel(
                            forgotPasswordUseCase: ForgotPasswordUseCase(
                                repository: repository
                            )
                        )
                    )
                }

                NavigationLink("Change Password") {
                    ChangePasswordView(
                        viewModel: ChangePasswordViewModel(
                            changePasswordUseCase: ChangePasswordUseCase(
                                repository: repository
                            )
                        )
                    )
                }
            }
            .navigationTitle("AuthenticationKit Demo")
        }
    }
}
