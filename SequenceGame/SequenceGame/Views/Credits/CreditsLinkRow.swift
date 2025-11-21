//
//  CreditsLinkRow.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct CreditsLinkRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    var action: (() -> Void)?
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: GameConstants.UISizing.iconSizeLarge))
                    .foregroundStyle(iconColor)
                    .frame(width: 50, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(iconColor.opacity(0.1))
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
            .padding(.vertical, 14)
            .background(ThemeColor.backgroundMenu)
            .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius)
                    .stroke(ThemeColor.border, lineWidth: GameConstants.UISizing.universalBorderWidth)
            )
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    CreditsLinkRow(
        icon: "safari.fill",
        title: "Official Rules",
        subtitle: "Visit JAX Games website",
        iconColor: ThemeColor.accentPrimary
    )
    .padding()
}
