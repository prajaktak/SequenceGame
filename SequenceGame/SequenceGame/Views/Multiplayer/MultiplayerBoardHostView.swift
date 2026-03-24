//
//  MultiplayerBoardHostView.swift
//  SequenceGame
//
//  iPad in-game screen for multiplayer host mode.
//  Shows the full game board, turn banner, and seating ring.
//  Highlights the pending position when an iPhone player has tapped a tile
//  but hasn't confirmed yet.
//  Shows a waitingForPlayer overlay when it's an iPhone player's turn.
//

import SwiftUI

/// iPad in-game view for local multiplayer.
///
/// Wraps the existing `BoardView` and `TurnBannerView`.
/// Receives live state from `MultiplayerCoordinator` (which owns `GameState`).
/// Does not show a hand — the iPad is a board-only display in multiplayer.
struct MultiplayerBoardHostView: View {

    // MARK: - Dependencies

    @ObservedObject var coordinator: MultiplayerCoordinator

    // MARK: - Body

    var body: some View {
        ZStack {
            ThemeColor.backgroundGame.ignoresSafeArea()

            VStack(spacing: 0) {
                turnBanner
                boardArea
            }
        }
        .environmentObject(coordinator.gameState)
    }

    // MARK: - Subviews

    private var turnBanner: some View {
        Group {
            if let currentPlayer = coordinator.gameState.currentPlayer {
                TurnBannerView(
                    playerName: currentPlayer.name,
                    teamColor: ThemeColor.getTeamColor(for: currentPlayer.team.color)
                )
            }
        }
    }

    private var boardArea: some View {
        GeometryReader { geometry in
            ZStack {
                // Full game board — driven by coordinator.gameState via @EnvironmentObject.
                BoardView(
                    currentPlayer: .constant(coordinator.gameState.currentPlayer)
                )

                // Pending position highlight — shown while iPhone player has selected
                // a position but hasn't confirmed.
                if let pending = coordinator.pendingPosition {
                    pendingHighlight(for: pending, in: geometry)
                }

                // Waiting overlay — shown when an iPhone player must act.
                if coordinator.gameState.overlayMode == .waitingForPlayer {
                    waitingOverlay
                }
            }
        }
        .padding(GameConstants.boardPadding)
    }

    /// A semi-transparent pulsing highlight drawn over the pending tile.
    private func pendingHighlight(for position: Position, in geometry: GeometryProxy) -> some View {
        let columns = GameConstants.boardColumns
        let rows = GameConstants.boardRows
        let tileWidth = (geometry.size.width - GameConstants.boardPadding * 2) / CGFloat(columns)
        let tileHeight = (geometry.size.height - GameConstants.boardPadding * 2) / CGFloat(rows)
        let offsetX = tileWidth * CGFloat(position.col) + tileWidth / 2
        let offsetY = tileHeight * CGFloat(position.row) + tileHeight / 2

        return Circle()
            .fill(ThemeColor.accentPrimary.opacity(0.35))
            .frame(width: tileWidth * 0.85, height: tileHeight * 0.85)
            .position(x: offsetX, y: offsetY)
    }

    private var waitingOverlay: some View {
        ZStack {
            Color.black.opacity(0.15)
            VStack(spacing: GameConstants.overlayContentSpacing) {
                ProgressView()
                    .tint(ThemeColor.textOnAccent)
                    .scaleEffect(1.5)
                Text("Waiting for player…")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(ThemeColor.textOnAccent)
            }
            .padding(GameConstants.largeSpacing)
            .background(ThemeColor.accentPrimary.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: GameConstants.largeCornerRadius))
        }
    }
}

#Preview("MultiplayerBoardHostView") {
    let sessionManager = MultipeerSessionManager(displayName: "iPad Preview")
    let coordinator = MultiplayerCoordinator(sessionManager: sessionManager)
    let players = [
        Player(name: "Alice", team: Team(color: .blue, numberOfPlayers: 2)),
        Player(name: "Bob", team: Team(color: .red, numberOfPlayers: 2))
    ]
    coordinator.startGame(players: players)
    return MultiplayerBoardHostView(coordinator: coordinator)
}
