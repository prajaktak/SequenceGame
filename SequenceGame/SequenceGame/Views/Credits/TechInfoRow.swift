//
//  TechInfoRow.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct TechInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(ThemeColor.textPrimary)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
        .padding(.vertical, 10)
        .background(ThemeColor.backgroundMenu)
        .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.smallCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GameConstants.UISizing.smallCornerRadius)
                .stroke(ThemeColor.border, lineWidth: GameConstants.UISizing.universalBorderWidth)
        )
    }
}

#Preview {
    TechInfoRow(label: "Platform", value: "iOS")
        .padding()
}
