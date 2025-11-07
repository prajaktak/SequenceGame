//
//  TwoEyedJackOverlayContent.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 30/10/2025.
//

import SwiftUI

struct TwoEyedJackOverlayContent: View {
    let teamColor: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Image(systemName: "circlebadge.2.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(teamColor)
                    .shadow(color: teamColor.opacity(0.35), radius: 6, y: 2)
            }

            Text("Place your chip on any open tile")
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundColor(ThemeColor.textOnAccent)
        }
    }
}

#Preview("JackPlaceAnywhereOverlayContent") {
    HexagonOverlay(
        borderColor: ThemeColor.overlayTeamBlue,
        backgroundColor: ThemeColor.accentSecondary
    ) {
        TwoEyedJackOverlayContent(teamColor: ThemeColor.overlayTeamBlue)
    }
    .padding(20)
    .background(ThemeColor.backgroundGame)
}
