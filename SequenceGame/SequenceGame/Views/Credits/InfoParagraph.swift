//
//  InfoParagraph.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct InfoParagraph: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(ThemeColor.textPrimary)
            
            Text(content)
                .font(.subheadline)
                .foregroundStyle(ThemeColor.textPrimary.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, GameConstants.horizontalPadding)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
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
    InfoParagraph(
        title: "What is Sequence?",
        content: "Sequence is a strategy board game for two or more players. Players compete to form rows of five chips on the board using their cards."
    )
    .padding()
}
