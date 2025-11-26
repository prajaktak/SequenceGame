//
//  MenuButtonView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 29/10/2025.
//

import SwiftUI

struct MenuButtonView<Destination: View>: View {
    let title: String
    let subtitle: String
    let iconSystemName: String
    let gradient: [Color]
    let destination: Destination
    let isEnabled: Bool

    init(title: String,
         subtitle: String,
         iconSystemName: String,
         gradient: [Color],
         isEnabled: Bool = true,
         @ViewBuilder destination: () -> Destination) {
        self.title = title
        self.subtitle = subtitle
        self.iconSystemName = iconSystemName
        self.gradient = gradient
        self.isEnabled = isEnabled
        self.destination = destination()
    }

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                Image(systemName: iconSystemName)
                    .font(.system(size: GameConstants.UISizing.iconSizeLarge))
                    .foregroundStyle(ThemeColor.textOnAccent)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.headline, design: .rounded).weight(.heavy))
                    Text(subtitle)
                        .font(.system(.subheadline, design: .rounded))
                        .opacity(0.9)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .opacity(0.7)
            }
            .foregroundStyle(ThemeColor.textOnAccent)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: GameConstants.UISizing.secondaryButtonHeight)
            .background(
                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.largeCornerRadius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: GameConstants.UISizing.largeCornerRadius).stroke(ThemeColor.border, lineWidth: GameConstants.UISizing.universalBorderWidth))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            .opacity(isEnabled ? 1.0 : 0.5)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(title)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
        .disabled(!isEnabled)
    }
}

#Preview("MenuButtonView") {
    NavigationStack {
        MenuButtonView(
            title: "New Game",
            subtitle: "Start a fresh game",
            iconSystemName: "play.circle.fill",
            gradient: [ThemeColor.accentPrimary, ThemeColor.accentSecondary]
        ) {
            Text("Destination")
        }
        .padding()
        .background(ThemeColor.backgroundMenu)
    }
}
