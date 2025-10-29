//
//  CardSelectedOverlayContent.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 30/10/2025.
//

import SwiftUI

struct CardSelectedOverlayContent: View {
    let teamColor: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "rectangle.portrait.on.rectangle.portrait.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(teamColor)
                .shadow(color: teamColor.opacity(0.35), radius: 6, y: 2)

            Text("Tap a highlighted tile")
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundColor(ThemeColor.textOnAccent)
        }
    }
}

#Preview("CardSelectedOverlayContent") {
    HexagonOverlay(
        borderColor: ThemeColor.overlayTeamGreen,
        backgroundColor: ThemeColor.accentPrimary
    ) {
        CardSelectedOverlayContent(teamColor: ThemeColor.overlayTeamGreen)
    }
    .padding(20)
    .background(ThemeColor.backgroundGame)
}
