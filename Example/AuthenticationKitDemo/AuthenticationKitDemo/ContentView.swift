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
                    LoginView()
                }

                NavigationLink("Sign Up") {
                    SignUpView()
                }

                NavigationLink("Forgot Password") {
                    ForgotPasswordView()
                }

                NavigationLink("Change Password") {
                    ChangePasswordView()
                }
            }
            .navigationTitle("AuthenticationKit Demo")
        }
    }
}
