//
//  MultiplayerBoardHostView.swift
//  SequenceGame
//
//  iPad in-game screen for multiplayer host mode.
//  Mirrors GameView exactly (minus hand): turn banner → board with static seating ring.
//  The seating ring shows all players; current player is highlighted but the ring does not rotate.
//  Team scores are shown above the turn banner.
//

import SwiftUI
import UIKit

/// iPad in-game view for local multiplayer.
///
/// Mirrors `GameView` structure exactly, minus the hand section.
/// Shows team scores above the turn banner, a full board, and a static seating ring
/// where the current player is highlighted but the ring does not rotate.
struct MultiplayerBoardHostView: View {

    // MARK: - Dependencies

    @ObservedObject var coordinator: MultiplayerCoordinator
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var showMenuSheet: Bool = false
    @State private var showGameOverOverlay: Bool = false
    @State private var disconnectionSecondsRemaining: Int = 120

    // MARK: - Computed Properties

    private var seats: [Seat] {
        SeatingLayout.computeSeats(for: coordinator.gameState.players.count)
    }

    /// Players anchored so the current player is at index 0.
    private var anchoredPlayers: [Player] {
        let players = coordinator.gameState.players
        let currentIndex = coordinator.gameState.currentPlayerIndex
        guard !players.isEmpty, currentIndex < players.count else { return players }
        return Array(players[currentIndex...]) + Array(players[..<currentIndex])
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Team Scores + Turn Banner in a compact horizontal bar
                topBar

                // Game Board with static seating ring
                ZStack {
                    BoardView(currentPlayer: .constant(coordinator.gameState.currentPlayer))
                        .allowsHitTesting(false)

                    SeatingRingOverlay(
                        seats: seats,
                        players: anchoredPlayers,
                        currentPlayerIndex: 0,
                        rotatesToCurrentPlayer: false
                    )
                    .allowsHitTesting(false)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .toolbarBackground(ThemeColor.boardFelt, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Menu") { showMenuSheet = true }
                    .foregroundStyle(ThemeColor.textOnAccent)
            }
        }
        .sheet(isPresented: $showMenuSheet) {
            InGameMenuView(
                onNewGame: {
                    showMenuSheet = false
                    coordinator.endGame()
                },
                onRestart: {
                    coordinator.restartGame()
                }
            )
            .environmentObject(coordinator.gameState)
        }
        .overlay {
            if coordinator.disconnectedPlayerName != nil {
                disconnectionBanner
            }
        }
        .overlay {
            if showGameOverOverlay, let currentPlayer = coordinator.gameState.currentPlayer {
                let teamColor = ThemeColor.getTeamColor(for: currentPlayer.team.color)
                GameOverlayView(
                    playerName: currentPlayer.name,
                    teamColor: teamColor,
                    borderColor: ThemeColor.getTeamOverlayColor(for: teamColor),
                    backgroundColor: teamColor,
                    onHelp: {},
                    onClose: { showGameOverOverlay = false },
                    onNewGame: { showGameOverOverlay = false; coordinator.endGame() },
                    onReplayOverride: { showGameOverOverlay = false; coordinator.restartGame() },
                    mode: .gameOver
                )
                .allowsHitTesting(true)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: coordinator.gameState.overlayMode) { _, mode in
            showGameOverOverlay = (mode == .gameOver)
        }
        .onChange(of: coordinator.isGameEnded) { _, ended in
            if ended { dismiss() }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .environmentObject(coordinator.gameState)
    }

    // MARK: - Disconnection Banner

    private var disconnectionBanner: some View {
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        let playerName = coordinator.disconnectedPlayerName ?? "A player"

        return HexagonOverlay(
            borderColor: ThemeColor.accentGolden,
            backgroundColor: ThemeColor.boardFelt,
            allowsHitTesting: coordinator.showEndGameButton
        ) {
            VStack(spacing: GameConstants.overlayContentSpacing) {
                HStack(spacing: 6) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(ThemeColor.accentGolden)
                    Text("\(playerName) disconnected")
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(ThemeColor.textOnAccent)
                }

                if coordinator.showEndGameButton {
                    Button {
                        coordinator.endGame()
                    } label: {
                        Text("End Game")
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .foregroundStyle(ThemeColor.textOnAccent)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(ThemeColor.accentTertiary)
                            .clipShape(Capsule())
                    }
                } else {
                    Text("Waiting… \(disconnectionSecondsRemaining)s")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(ThemeColor.textOnAccent.opacity(0.7))
                        .onReceive(timer) { _ in
                            if disconnectionSecondsRemaining > 0 {
                                disconnectionSecondsRemaining -= 1
                            }
                        }
                }
            }
        }
        .onChange(of: coordinator.disconnectedPlayerName) { _, name in
            if name != nil {
                disconnectionSecondsRemaining = 120
            }
        }
    }

    // MARK: - Subviews

    /// Compact single-row bar combining team scores on the left and the turn banner on the right.
    private var topBar: some View {
        let scores = Dictionary(
            grouping: coordinator.gameState.detectedSequence,
            by: { $0.teamColor }
        ).mapValues { $0.count }

        let uniqueTeamColors = Array(Set(coordinator.gameState.players.map { $0.team.color }))
            .sorted { $0.stringValue < $1.stringValue }

        return HStack {
            HStack(spacing: 6) {
                ForEach(uniqueTeamColors, id: \.self) { teamColor in
                    let count = scores[teamColor] ?? 0
                    Text("\(teamColor.accessibilityName): \(count)")
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(ThemeColor.textOnAccent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(ThemeColor.getTeamColor(for: teamColor))
                        .clipShape(Capsule())
                }
            }

            Spacer()

            if let currentPlayer = coordinator.gameState.currentPlayer {
                TurnBannerView(
                    playerName: currentPlayer.name,
                    teamColor: ThemeColor.getTeamColor(for: currentPlayer.team.color)
                )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
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
