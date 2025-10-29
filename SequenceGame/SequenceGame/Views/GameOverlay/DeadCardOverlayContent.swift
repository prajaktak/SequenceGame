//
//  DeadCardOverlayContent.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 30/10/2025.
//

import SwiftUI

struct DeadCardOverlayContent: View {
    let teamColor: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(teamColor)
                .shadow(color: teamColor.opacity(0.35), radius: 6, y: 2)

            Text("This card is dead")
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundColor(ThemeColor.textOnAccent)

            HStack(spacing: 6) {
                Image(systemName: "hand.point.up.left.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ThemeColor.textOnAccent)

                (
                    Text("Tap ") +
                    Text("here").fontWeight(.bold).underline() +
                    Text(" to replace")
                )
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(ThemeColor.textOnAccent)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(ThemeColor.textOnAccent.opacity(0.12))
            .clipShape(Capsule())
        }
    }
}

#Preview("DeadCardOverlayContent") {
    HexagonOverlay(
        borderColor: ThemeColor.overlayTeamBlue,
        backgroundColor: ThemeColor.accentSecondary
    ) {
        DeadCardOverlayContent(teamColor: ThemeColor.overlayTeamBlue)
    }
    .padding(20)
    .background(ThemeColor.backgroundGame)
}
