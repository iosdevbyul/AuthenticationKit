//
//  ChangePasswordScreen.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import SwiftUI
import AuthenticationKit

struct ChangePasswordScreen: View {

    let onPasswordChanged: () -> Void

    @StateObject private var viewModel = ChangePasswordViewModel()

    var body: some View {
        ChangePasswordView(
            viewModel: viewModel
        ) {
            onPasswordChanged()
        }
    }
}
