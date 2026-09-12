//
//  EmailChangeLinkTests.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-12.
//

import Foundation
import Testing
@testable import AuthenticationKit

struct EmailChangeLinkTests {

    @Test
    func validEmailChangeLinkParsesToken() throws {
        let url = try #require(
            URL(
                string: "waktrainer://change-email?token=abc"
            )
        )

        let link = try #require(
            EmailChangeLink(
                url: url
            )
        )

        #expect(
            link.token == "abc"
        )
    }

    @Test
    func invalidEmailChangeLinksAreRejected() throws {
        let invalidURLs = [
            "https://change-email?token=abc",
            "other://change-email?token=abc",
            "waktrainer://verify-email?token=abc",
            "waktrainer://change-email",
            "waktrainer://change-email?token=",
            "waktrainer://change-email?token=a&token=b",
            "waktrainer://change-email/extra?token=a",
            "waktrainer://user@change-email?token=a",
            "waktrainer://change-email:1234?token=a"
        ]

        for rawURL in invalidURLs {
            let url = try #require(
                URL(
                    string: rawURL
                )
            )

            #expect(
                EmailChangeLink(
                    url: url
                ) == nil
            )
        }
    }

    @Test
    func customSchemeIsSupported() throws {
        let url = try #require(
            URL(
                string: "myapp://change-email?token=abc"
            )
        )

        let link = try #require(
            EmailChangeLink(
                url: url,
                scheme: "myapp"
            )
        )

        #expect(
            link.token == "abc"
        )
    }

    @Test
    func customSchemeRejectsDefaultScheme() throws {
        let url = try #require(
            URL(
                string: "waktrainer://change-email?token=abc"
            )
        )

        #expect(
            EmailChangeLink(
                url: url,
                scheme: "myapp"
            ) == nil
        )
    }
}
