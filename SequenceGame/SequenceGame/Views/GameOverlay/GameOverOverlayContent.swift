//
//  GameOverOverlayContent.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 30/10/2025.
//

import SwiftUI

struct GameOverOverlayContent: View {
    let teamColor: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(teamColor)
                .shadow(color: teamColor.opacity(0.35), radius: 6, y: 2)

            Text("Winner!")
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundColor(ThemeColor.textOnAccent)
        }
    }
}

#Preview("GameOverOverlayContent") {
    HexagonOverlay(
        borderColor: ThemeColor.overlayTeamGreen,
        backgroundColor: ThemeColor.accentPrimary
    ) {
        GameOverOverlayContent(teamColor: ThemeColor.overlayTeamGreen)
    }
    .padding(20)
    .background(ThemeColor.backgroundGame)
}
