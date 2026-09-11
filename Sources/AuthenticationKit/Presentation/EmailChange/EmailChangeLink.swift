//
//  EmailChangeLink.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-11.
//

import Foundation

public struct EmailChangeLink: Equatable, Sendable {
    public let token: String

    public init?(url: URL, scheme: String = "waktrainer") {
        guard url.scheme?.lowercased() == scheme.lowercased(),
              url.host == "change-email",
              url.path.isEmpty || url.path == "/",
              url.user == nil,
              url.password == nil,
              url.port == nil,
              let components = URLComponents(
                  url: url,
                  resolvingAgainstBaseURL: false
              )
        else {
            return nil
        }

        let tokens = (components.queryItems ?? [])
            .filter { $0.name == "token" }

        guard tokens.count == 1,
              let token = tokens.first?.value,
              !token.isEmpty
        else {
            return nil
        }

        self.token = token
    }
}
