//
//  PausedOverlayContent.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 30/10/2025.
//

import SwiftUI

struct PausedOverlayContent: View {
    let teamColor: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "pause.circle.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(teamColor)
                .shadow(color: teamColor.opacity(0.35), radius: 6, y: 2)

            Text("Game paused")
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundColor(ThemeColor.textOnAccent)
        }
    }
}

#Preview("PausedOverlayContent") {
    HexagonOverlay(
        borderColor: ThemeColor.overlayTeamBlue,
        backgroundColor: ThemeColor.accentSecondary
    ) {
        PausedOverlayContent(teamColor: ThemeColor.overlayTeamBlue)
    }
    .padding(20)
    .background(ThemeColor.backgroundGame)
}
