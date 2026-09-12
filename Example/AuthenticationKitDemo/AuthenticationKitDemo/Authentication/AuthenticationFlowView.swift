//
//  AuthenticationFlowView.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import SwiftUI
import AuthenticationKit

struct AuthenticationFlowView: View {

    let onAuthenticated: (Session) -> Void

    var body: some View {
        NavigationStack {
            LoginScreen(
                onAuthenticated: onAuthenticated
            )
        }
    }
}
