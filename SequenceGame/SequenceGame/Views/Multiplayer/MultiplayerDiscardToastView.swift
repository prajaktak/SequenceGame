//
//  MultiplayerDiscardToastView.swift
//  SequenceGame
//
//  Brief toast shown on all iPhones when any player discards a dead card.
//

import SwiftUI

/// A brief toast banner shown when a player discards a dead card.
///
/// Displayed on all iPhones for a few seconds after the host broadcasts a
/// `DiscardEvent`. Fades in and fades out automatically.
struct MultiplayerDiscardToastView: View {

    /// The discard event to display.
    let event: DiscardEvent

    var body: some View {
        HStack(spacing: GameConstants.handSpacing) {
            Image(systemName: "arrow.uturn.backward.circle.fill")
                .font(.title3)
                .foregroundStyle(ThemeColor.getTeamColor(for: event.teamColor))

            VStack(alignment: .leading, spacing: 2) {
                Text(event.playerName)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(ThemeColor.textOnAccent)
                Text("discarded a dead card")
                    .font(.caption)
                    .foregroundStyle(ThemeColor.textOnAccent.opacity(0.8))
            }

            Spacer()

            CardFaceView(card: event.card)
                .frame(width: 32, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .padding(.horizontal, GameConstants.handSpacing)
        .padding(.vertical, GameConstants.overlayContentSpacing)
        .background(
            RoundedRectangle(cornerRadius: GameConstants.largeCornerRadius)
                .fill(ThemeColor.accentPrimary.opacity(0.92))
        )
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
}

#Preview("MultiplayerDiscardToastView") {
    MultiplayerDiscardToastView(
        event: DiscardEvent(
            playerName: "Alice",
            teamColor: .blue,
            card: Card(cardFace: .ten, suit: .hearts)
        )
    )
    .padding()
    .background(ThemeColor.backgroundGame)
}
