//
//  SettingsDifficultyButton.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct SettingsDifficultyButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: GameConstants.UISizing.iconSizeLarge))
                    .foregroundStyle(
                        isSelected ? ThemeColor.accentPrimary : ThemeColor.textPrimary.opacity(0.5)
                    )
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: GameConstants.UISizing.buttonCornerRadius)
                            .fill(
                                isSelected ?
                                ThemeColor.accentPrimary.opacity(0.15) :
                                ThemeColor.accentPrimary.opacity(0.05)
                            )
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
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(ThemeColor.accentPrimary)
                }
            }
            .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
            .padding(.vertical, 12)
            .background(ThemeColor.backgroundMenu)
            .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius)
                    .stroke(
                        isSelected ? ThemeColor.accentPrimary : ThemeColor.border,
                        lineWidth: isSelected ? GameConstants.UISizing.handCardBorderWidth : GameConstants.UISizing.universalBorderWidth
                    )
            )
            .shadow(
                color: isSelected ? ThemeColor.accentPrimary.opacity(0.2) : .black.opacity(0.03),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: 2
            )
        }
    }
}

#Preview {
    SettingsDifficultyButton(
        icon: "2.circle.fill",
        title: "Medium",
        subtitle: "Balanced gameplay",
        isSelected: true
    ) {
        // Preview action
    }
    .padding()
}
