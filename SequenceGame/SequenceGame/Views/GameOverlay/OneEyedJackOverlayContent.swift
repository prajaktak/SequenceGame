//
//  OneEyedJackOverlayContent.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 30/10/2025.
//

import SwiftUI

struct OneEyedJackOverlayContent: View {
    let teamColor: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "circle.badge.minus.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(teamColor)
                .shadow(color: teamColor.opacity(0.35), radius: 6, y: 2)

            Text("Select an opponent chip to remove")
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundColor(ThemeColor.textOnAccent)
        }
    }
}

#Preview("OneEyedJackOverlayContent") {
    HexagonOverlay(
        borderColor: ThemeColor.overlayTeamRed,
        backgroundColor: ThemeColor.accentTertiary
    ) {
        OneEyedJackOverlayContent(teamColor: ThemeColor.overlayTeamRed)
    }
    .padding(20)
    .background(ThemeColor.backgroundGame)
}
