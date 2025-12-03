//
//  SettingsOptionButton.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct SettingsOptionButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: GameConstants.iconSizeLarge))
                    .foregroundStyle(
                        isSelected ? ThemeColor.accentPrimary : ThemeColor.textPrimary.opacity(0.5)
                    )
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                isSelected ?
                                ThemeColor.accentPrimary.opacity(0.15) :
                                ThemeColor.accentPrimary.opacity(0.05)
                            )
                    )
                
                Text(title)
                    .font(.headline)
                    .foregroundStyle(ThemeColor.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(ThemeColor.accentPrimary)
                }
            }
            .padding(.horizontal, GameConstants.horizontalPadding)
            .padding(.vertical, 12)
            .background(ThemeColor.backgroundMenu)
            .clipShape(RoundedRectangle(cornerRadius: GameConstants.mediumCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GameConstants.mediumCornerRadius)
                    .stroke(
                        isSelected ? ThemeColor.accentPrimary : ThemeColor.border,
                        lineWidth: isSelected ? GameConstants.handCardBorderWidth : GameConstants.universalBorderWidth
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
    SettingsOptionButton(
        icon: "sun.max.fill",
        title: "Light",
        isSelected: true
    ) {
        // Preview action
    }
    .padding()
}
