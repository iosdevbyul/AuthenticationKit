//
//  EmailChangeScreen.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import SwiftUI
import AuthenticationKit

struct EmailChangeScreen: View {

    @StateObject private var viewModel: EmailChangeViewModel
    @State private var didHandleLink = false

    let onEmailChanged: () -> Void

    init(
        token: String? = nil,
        onEmailChanged: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: EmailChangeViewModel(
                token: token
            )
        )

        self.onEmailChanged = onEmailChanged
    }

    var body: some View {
        EmailChangeView(
            viewModel: viewModel
        )
        .navigationTitle("이메일 변경")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.onEmailChangeConfirmed = { _ in
                onEmailChanged()
            }
        }
        .task {
            guard !didHandleLink,
                  viewModel.hasConfirmationToken
            else {
                return
            }

            didHandleLink = true
            await viewModel.confirmEmailChange()
        }
    }
}

struct EmailChangeDestination: Identifiable {
    let id = UUID()
    let token: String
}
