//
//  AuthenticationTextField.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-02.
//

import SwiftUI

public struct AuthenticationTextField: View {

    private let title: String
    private let placeholder: String
    @Binding private var text: String
    private let theme: AuthenticationTheme

    public init(
        title: String,
        placeholder: String = "",
        text: Binding<String>,
        theme: AuthenticationTheme = .default
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.theme = theme
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(theme.text)

            TextField(placeholder, text: $text)
                .foregroundColor(theme.textField.text)
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(theme.textField.background)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            theme.textField.border,
                            lineWidth: 1
                        )
                )
        }
    }
}
