//
//  EmailVerificationScreen.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import SwiftUI
import AuthenticationKit

struct EmailVerificationScreen: View {
    @StateObject private var viewModel: EmailVerificationViewModel
    @State private var didHandleLink = false
    let onUserUpdated: () -> Void

    init(token: String? = nil, onUserUpdated: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: EmailVerificationViewModel(token: token))
        self.onUserUpdated = onUserUpdated
    }

    var body: some View {
        EmailVerificationView(viewModel: viewModel)
            .navigationTitle("이메일 인증")
            .onAppear {
                viewModel.onUserUpdated = { _ in onUserUpdated() }
            }
            .task {
                guard !didHandleLink, viewModel.hasVerificationToken else { return }
                didHandleLink = true
                await viewModel.verifyEmail()
            }
    }
}

struct VerificationDestination: Identifiable {
    let id = UUID()
    let token: String
}
