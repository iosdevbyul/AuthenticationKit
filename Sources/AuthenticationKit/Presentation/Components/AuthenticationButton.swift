//
//  AuthenticationButton.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-02.
//

import SwiftUI

public struct AuthenticationButton: View {

    private let title: String
    private let action: () -> Void
    private let isEnabled: Bool
    private let isLoading: Bool?
    private let theme: AuthenticationTheme

    public init(
        title: String,
        isEnabled: Bool = true,
        isLoading: Bool? = nil,
        theme: AuthenticationTheme = .default,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.theme = theme
        self.action = action
    }

    private var isDisabled: Bool {
        !isEnabled || isLoading == true
    }

    public var body: some View {
        Button {
            print("AuthenticationButton tapped")
            action()
        } label: {
            ZStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(
                        isDisabled
                            ? theme.button.disabled
                            : theme.button.foreground
                    )

                if isLoading == true {
                    AuthenticationLoadingIndicator(
                        color: theme.button.foreground
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
        }
        .background(
            isDisabled
                ? theme.button.disabled.opacity(0.2)
                : theme.button.background
        )
        .cornerRadius(10)
        .disabled(isDisabled)
    }
}

private struct AuthenticationLoadingIndicator: View {

    let color: Color

    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: 2,
                    lineCap: .round
                )
            )
            .frame(width: 20, height: 20)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(
                Animation.linear(duration: 0.8)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}
