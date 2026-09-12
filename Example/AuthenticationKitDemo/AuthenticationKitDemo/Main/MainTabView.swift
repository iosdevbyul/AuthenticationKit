//
//  MainTabView.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import SwiftUI
import AuthenticationKit

struct MainTabView: View {

    let session: Session
    let onSessionChanged: (Session) -> Void
    let onSignedOut: () -> Void

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(
                    session: session
                )
            }
            .tabItem {
                Label(
                    "홈",
                    systemImage: "house"
                )
            }

            NavigationStack {
                SettingsView(
                    session: session,
                    onSessionChanged: onSessionChanged,
                    onSignedOut: onSignedOut
                )
            }
            .tabItem {
                Label(
                    "설정",
                    systemImage: "gearshape"
                )
            }
        }
    }
}
