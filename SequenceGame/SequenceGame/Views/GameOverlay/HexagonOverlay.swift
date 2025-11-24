//
//  HexagonOverlay.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 29/10/2025.
//

import SwiftUI

struct HexagonOverlay<Content: View>: View {
    let content: Content
    let borderColor: Color
    let backgroundColor: Color
    let allowsHitTesting: Bool
    
    init(borderColor: Color, backgroundColor: Color, allowsHitTesting: Bool = false, @ViewBuilder content: () -> Content) {
        self.borderColor = borderColor
        self.content = content()
        self.backgroundColor = backgroundColor
        self.allowsHitTesting = allowsHitTesting
    }
    
    var body: some View {
        content
            .frame(width: 300, height: 100)
            .padding(16)
            .background(backgroundColor.opacity(0.80))
            .clipShape(Hexagon())
            .overlay(Hexagon().stroke(borderColor, lineWidth: GameConstants.UISizing.emphasizedBorderWidth))
            .shadow(color: borderColor.opacity(0.5), radius: 12, y: 4)
            .allowsHitTesting(allowsHitTesting)
    }
}
#Preview("HexagonOverlay team green") {
    HexagonOverlay(borderColor: ThemeColor.overlayTeamGreen, backgroundColor: ThemeColor.accentPrimary ) {
        Text("Sample Content")
            .foregroundColor(ThemeColor.textOnAccent)
            .font(.caption)
    }
    .padding(20)
    .background(ThemeColor.backgroundGame)
}
#Preview("HexagonOverlay team blue") {
    HexagonOverlay(borderColor: ThemeColor.overlayTeamBlue, backgroundColor: ThemeColor.accentSecondary) {
        Text("Sample Content")
            .foregroundColor(ThemeColor.textOnAccent)
            .font(.caption)
    }
    .padding(20)
    .background(ThemeColor.backgroundGame)
}
#Preview("HexagonOverlay team red") {
    HexagonOverlay(borderColor: ThemeColor.overlayTeamRed, backgroundColor: ThemeColor.accentTertiary) {
        Text("Sample Content")
            .foregroundColor(ThemeColor.textOnAccent)
            .font(.caption)
    }
    .padding(20)
    .background(ThemeColor.backgroundGame)
}
