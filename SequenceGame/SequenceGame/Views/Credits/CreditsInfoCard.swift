//
//  CreditsInfoCard.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct CreditsInfoCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: GameConstants.iconSizeLarge))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ThemeColor.accentPrimary, ThemeColor.accentSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: GameConstants.buttonCornerRadius)
                        .fill(ThemeColor.accentPrimary.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
                Text(value)
                    .font(.headline)
                    .foregroundStyle(ThemeColor.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(ThemeColor.textPrimary.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.horizontal, GameConstants.horizontalPadding)
        .padding(.vertical, 14)
        .background(ThemeColor.backgroundMenu)
        .clipShape(RoundedRectangle(cornerRadius: GameConstants.mediumCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GameConstants.mediumCornerRadius)
                .stroke(ThemeColor.border, lineWidth: GameConstants.universalBorderWidth)
        )
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    CreditsInfoCard(
        icon: "app.badge",
        title: "Version",
        value: "1.0",
        subtitle: "Initial Release"
    )
    .padding()
}
