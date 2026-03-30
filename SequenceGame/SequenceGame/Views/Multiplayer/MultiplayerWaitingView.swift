//
//  MultiplayerWaitingView.swift
//  SequenceGame
//
//  Full-screen overlay shown on an iPhone when it's another player's turn.
//

import SwiftUI

/// Full-screen view shown when it's not this iPhone player's turn.
struct MultiplayerWaitingView: View {

    /// Name of the player whose turn it currently is.
    let currentPlayerName: String

    /// Team color of the current player (for accent color).
    let currentPlayerTeamColor: TeamColor

    var body: some View {
        ZStack {
            ThemeColor.backgroundGame
                .ignoresSafeArea()

            VStack(spacing: GameConstants.largeSpacing) {
                ProgressView()
                    .scaleEffect(2)
                    .tint(ThemeColor.getTeamColor(for: currentPlayerTeamColor))
                    .padding(.bottom, GameConstants.verticalSpacing)

                Text("Waiting for")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))

                Text(currentPlayerName)
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .foregroundStyle(ThemeColor.getTeamColor(for: currentPlayerTeamColor))

                Text("to take their turn…")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(ThemeColor.textPrimary.opacity(0.6))
            }
            .multilineTextAlignment(.center)
            .padding(GameConstants.horizontalPadding)
        }
    }
}

#Preview("MultiplayerWaitingView") {
    MultiplayerWaitingView(currentPlayerName: "Alice", currentPlayerTeamColor: .blue)
}
