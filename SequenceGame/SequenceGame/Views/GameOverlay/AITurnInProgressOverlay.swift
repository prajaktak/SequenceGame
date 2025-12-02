//
//  AITurnInProgressOverlay.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 02/12/2025.
//
import SwiftUI

struct AITurnInProgressOverlay: View {
    let teamColor: Color
    let text: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "pause.circle.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(teamColor)
                .shadow(color: teamColor.opacity(0.35), radius: 6, y: 2)

            Text(text)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundColor(ThemeColor.textOnAccent)
        }
    }
}
#Preview("AIPlayerTurnInProgressOverlay") {
    HexagonOverlay(
        borderColor: ThemeColor.overlayTeamGreen,
        backgroundColor: ThemeColor.accentPrimary
    ) {
        AITurnInProgressOverlay(teamColor: ThemeColor.overlayTeamGreen, text: "Ai Player is Thinking...")
    }
    .padding(20)
    .background(ThemeColor.backgroundGame)
}
