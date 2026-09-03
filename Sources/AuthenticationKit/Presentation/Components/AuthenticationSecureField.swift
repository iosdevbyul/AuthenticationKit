//
//  AuthenticationSecureField.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-03.
//

import SwiftUI

public struct AuthenticationSecureField: View {

    private let title: String
    private let placeholder: String
    @Binding private var text: String
    private let theme: AuthenticationTheme

    @State private var isPasswordVisible = false

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

            HStack(spacing: 8) {
                Group {
                    if isPasswordVisible {
                        TextField(
                            placeholder,
                            text: $text
                        )
                    } else {
                        SecureField(
                            placeholder,
                            text: $text
                        )
                    }
                }
                .foregroundColor(theme.textField.text)

                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(
                        systemName: isPasswordVisible
                            ? "eye.slash"
                            : "eye"
                    )
                    .foregroundColor(theme.secondaryText)
                }
            }
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
