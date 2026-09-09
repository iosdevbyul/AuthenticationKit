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
        guard
            let baseURLString = Bundle.main.object(
                forInfoDictionaryKey: "API_BASE_URL"
            ) as? String,
            let baseURL = URL(string: baseURLString)
        else {
            fatalError("API_BASE_URL is missing or invalid.")
        }

        AuthenticationConfiguration.shared.configure(
            baseURL: baseURL
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
