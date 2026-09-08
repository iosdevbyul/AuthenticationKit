//
//  AuthenticationKitDemoApp.swift
//  AuthenticationKitDemo
//
//  Created by COMATOKI on 2026-09-05.
//

import SwiftUI
import AuthenticationKit

@main
struct AuthenticationKitDemoApp: App {

    init() {
        AuthenticationConfiguration.shared.configure(
            baseURL: URL(string: "https://api.example.com")!
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
