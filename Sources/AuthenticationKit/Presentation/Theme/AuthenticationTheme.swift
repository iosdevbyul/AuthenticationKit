//
//  AuthenticationTheme.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-01.
//

import SwiftUI

public struct AuthenticationTheme: Sendable {

    public var background: Color
    public var primary: Color
    public var text: Color
    public var secondaryText: Color
    public var placeholder: Color
    public var border: Color
    public var error: Color
    public var link: Color

    public var button: ButtonTheme
    public var textField: TextFieldTheme

    public struct ButtonTheme: Sendable {
        public var background: Color
        public var foreground: Color
        public var disabled: Color

        public init(
            background: Color,
            foreground: Color,
            disabled: Color
        ) {
            self.background = background
            self.foreground = foreground
            self.disabled = disabled
        }
    }

    public struct TextFieldTheme: Sendable {
        public var background: Color
        public var text: Color
        public var placeholder: Color
        public var border: Color
        public var focusedBorder: Color

        public init(
            background: Color,
            text: Color,
            placeholder: Color,
            border: Color,
            focusedBorder: Color
        ) {
            self.background = background
            self.text = text
            self.placeholder = placeholder
            self.border = border
            self.focusedBorder = focusedBorder
        }
    }

    public init(
        background: Color,
        primary: Color,
        text: Color,
        secondaryText: Color,
        placeholder: Color,
        border: Color,
        error: Color,
        link: Color,
        button: ButtonTheme,
        textField: TextFieldTheme
    ) {
        self.background = background
        self.primary = primary
        self.text = text
        self.secondaryText = secondaryText
        self.placeholder = placeholder
        self.border = border
        self.error = error
        self.link = link
        self.button = button
        self.textField = textField
    }
}

public extension AuthenticationTheme {

    static let `default` = AuthenticationTheme(
        background: .white,
        primary: .blue,
        text: .primary,
        secondaryText: .secondary,
        placeholder: .gray,
        border: .gray.opacity(0.3),
        error: .red,
        link: .blue,
        button: ButtonTheme(
            background: .blue,
            foreground: .white,
            disabled: .gray.opacity(0.5)
        ),
        textField: TextFieldTheme(
            background: .gray.opacity(0.08),
            text: .primary,
            placeholder: .gray,
            border: .gray.opacity(0.3),
            focusedBorder: .blue
        )
    )
}
