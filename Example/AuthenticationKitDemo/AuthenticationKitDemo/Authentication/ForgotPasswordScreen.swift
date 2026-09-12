//
//  ForgotPasswordScreen.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import SwiftUI
import AuthenticationKit

struct ForgotPasswordScreen: View {

    @StateObject private var viewModel = ForgotPasswordViewModel()

    var body: some View {
        VStack(spacing: 20) {
            ForgotPasswordView(
                viewModel: viewModel
            )

            NavigationLink {
                ResetPasswordScreen()
            } label: {
                Text("재설정 토큰 직접 입력")
            }
            .padding(.bottom, 24)
        }
    }
}
