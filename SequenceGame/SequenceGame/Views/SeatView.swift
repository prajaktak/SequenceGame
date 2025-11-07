//
//  SeatView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 29/10/2025.
//

import SwiftUI

struct SeatView: View {
    let name: String
    let teamColor: Color
    let handCount: Int
    let isCurrent: Bool

    var body: some View {
        let size: CGFloat = isCurrent ? 44 : 36
        ZStack {
            // Fill uses the team color, slightly more opaque for the active player
            Circle()
                .fill(teamColor.opacity(isCurrent ? 0.90 : 0.70))

            // Subtle border consistent with Theme border color
            Circle()
                .stroke(ThemeColor.border.opacity(isCurrent ? 0.85 : 0.6),
                        lineWidth: isCurrent ? 2 : 1)

            // Initials + hand count with text color that contrasts on accent
            VStack(spacing: 2) {
                Text(String(name.prefix(2)).uppercased())
                    .font(.caption).bold()
                    .foregroundColor(ThemeColor.textOnAccent)
                Text("\(handCount)")
                    .font(.caption2)
                    .foregroundColor(ThemeColor.textOnAccent.opacity(0.95))
            }
            .padding(4)
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(isCurrent ? 0.30 : 0.18),
                radius: isCurrent ? 6 : 3, y: 2)
        .scaleEffect(isCurrent ? 1.04 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isCurrent)
        .accessibilityLabel("\(name), \(handCount) cards")
    }
}
#Preview("Seat – Current Player") {
    SeatView(
           name: "Prajakta",
           teamColor: ThemeColor.teamGreen,
           handCount: 6,
           isCurrent: true
       )
       .padding(12)
       .background(ThemeColor.backgroundGame)
}
#Preview("Seat – Other Player") {
    SeatView(
           name: "Alex",
           teamColor: ThemeColor.teamBlue,
           handCount: 5,
           isCurrent: false
       )
       .padding(12)
       .background(ThemeColor.backgroundGame)  
}
