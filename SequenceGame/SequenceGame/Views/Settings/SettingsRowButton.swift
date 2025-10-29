//
//  SettingsRowButton.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct SettingsRowButton: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: GameConstants.UISizing.iconSizeLarge))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ThemeColor.accentPrimary, ThemeColor.accentSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ThemeColor.accentPrimary.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(ThemeColor.textPrimary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(ThemeColor.textPrimary.opacity(0.3))
        }
        .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
        .padding(.vertical, 12)
        .background(ThemeColor.backgroundMenu)
        .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius)
                .stroke(ThemeColor.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    SettingsRowButton(
        icon: "info.circle.fill",
        title: "About",
        subtitle: "App information"
    )
    .padding()
}
