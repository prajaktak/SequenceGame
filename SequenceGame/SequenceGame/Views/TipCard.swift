//
//  TipCard.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct TipCard: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: GameConstants.UISizing.iconSizeLarge))
                .foregroundStyle(ThemeColor.accentSecondary)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(ThemeColor.accentSecondary.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(ThemeColor.textPrimary)
                Text(content)
                    .font(.subheadline)
                    .foregroundStyle(ThemeColor.textPrimary.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
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

#Preview {
    TipCard(
        icon: "hand.thumbsup.fill",
        title: "Block Opponents",
        content: "Watch for opponent sequences and block them strategically."
    )
    .padding()
}
