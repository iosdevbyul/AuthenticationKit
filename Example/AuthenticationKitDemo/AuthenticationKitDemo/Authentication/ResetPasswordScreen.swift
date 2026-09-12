//
//  ResetPasswordScreen.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import SwiftUI
import AuthenticationKit

struct ResetPasswordScreen: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ResetPasswordView {
            dismiss()
        }
    }
}
