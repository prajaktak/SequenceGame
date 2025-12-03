//
//  SettingsToggleRow.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
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
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(ThemeColor.accentPrimary)
        }
        .padding(.horizontal, GameConstants.horizontalPadding)
        .padding(.vertical, 12)
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
    struct PreviewWrapper: View {
        @State private var isOn = true
        var body: some View {
            SettingsToggleRow(
                icon: "speaker.wave.2.fill",
                title: "Sound Effects",
                subtitle: "Game sounds and notifications",
                isOn: $isOn
            )
            .padding()
        }
    }
    return PreviewWrapper()
}
