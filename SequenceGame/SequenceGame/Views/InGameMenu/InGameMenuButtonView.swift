//
//  InGameMenuButtonView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 24/11/2025.
//

import SwiftUI

/// A styled button for the in-game menu with icon, title, and subtitle.
///
/// Used in `InGameMenuView` for primary actions like Resume, Restart, and New Game.
/// Features a colored background, icon, title text, and descriptive subtitle.
struct InGameMenuButtonView: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action,
               label: {
            HStack(spacing: GameConstants.verticalSpacing) {
                Image(systemName: icon)
                    .font(.system(size: GameConstants.iconSizeLarge))
                    .foregroundStyle(ThemeColor.textOnAccent)
                
                VStack(alignment: .leading, spacing: GameConstants.iconSizeSmall / 4) {
                    Text(title)
                        .font(.system(.headline, design: .rounded).weight(.heavy))
                    Text(subtitle)
                        .font(.system(.subheadline, design: .rounded))
                        .opacity(0.9)
                }
                .foregroundStyle(ThemeColor.textOnAccent)
                
                Spacer()
            }
            .padding(.horizontal, GameConstants.boardTopPadding)
            .frame(maxWidth: .infinity, minHeight: GameConstants.secondaryButtonHeight)
            .background(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: GameConstants.largeCornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.1), radius: GameConstants.iconSizeSmall / 4, x: 0, y: 2)
        })
        .buttonStyle(.plain)
        .accessibilityIdentifier(title)
        .accessibilityLabel(title)
        .accessibilityHint(subtitle)
    }
}

#Preview {
    InGameMenuButtonView(
        title: "Resume",
        subtitle: "Continue playing",
        icon: "play.circle.fill",
        gradient: [ ThemeColor.accentPrimary, ThemeColor.accentSecondary ]
    ) {
        print("Button tapped")
    }
    .padding()
    .background(ThemeColor.backgroundMenu)
}
