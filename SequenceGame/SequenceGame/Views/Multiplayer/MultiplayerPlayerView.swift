//
//  MultiplayerPlayerView.swift
//  SequenceGame
//
//  iPhone in-game root view for a multiplayer player.
//  Mirrors GameView layout: turn banner → board with rotating seating ring → hand.
//  Board state is driven by a local GameState kept in sync with every
//  MultiplayerGameStateBroadcast received from the iPad host.
//  All moves are sent to the host via MultiplayerClient.
//

import SwiftUI
import UIKit

/// Root iPhone in-game view for local multiplayer.
///
/// Layout matches single-player `GameView`: turn banner → board → hand.
/// The board tap overlay uses a GeometryReader placed **inside the board ZStack**
/// so its tile-size calculation matches `BoardView`'s own inner GeometryReader exactly.
struct MultiplayerPlayerView: View {

    // MARK: - Dependencies

    @ObservedObject var client: MultiplayerClient

    // MARK: - Environment

    @Environment(\.dismiss) var dismiss

    // MARK: - State

    /// Local game state synced from each broadcast, used only for BoardView rendering.
    @StateObject private var localGameState = GameState()

    @State private var showMenuSheet: Bool = false
    @State private var reconnectSecondsRemaining: Int = 120
    @State private var showRestartedBanner: Bool = false

    // MARK: - Computed Properties

    private var seats: [Seat] {
        SeatingLayout.computeSeats(for: localGameState.players.count)
    }

    /// Players anchored so the current player is at index 0 (mirrors GameView anchoring).
    private var anchoredPlayers: [Player] {
        let players = localGameState.players
        let currentIndex = localGameState.currentPlayerIndex
        guard !players.isEmpty, currentIndex < players.count else { return players }
        return Array(players[currentIndex...]) + Array(players[..<currentIndex])
    }

    private var hasSelection: Bool {
        localGameState.selectedCardId != nil
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 3) {
            // Turn Banner
            turnBanner

            // Game Board with seating ring and tap overlay
            // The GeometryReader is placed INSIDE the ZStack so boardTapOverlay
            // calculates tile sizes from the board area, matching BoardView exactly.
            ZStack {
                BoardView(currentPlayer: .constant(localGameState.currentPlayer))
                    .environmentObject(localGameState)
                    .allowsHitTesting(false)

                SeatingRingOverlay(
                    seats: seats,
                    players: anchoredPlayers,
                    currentPlayerIndex: 0,
                    rotatesToCurrentPlayer: true
                )
                .allowsHitTesting(false)
                .opacity(hasSelection ? 0 : 1)
                .animation(.easeInOut(duration: GameConstants.cardSelectionDuration), value: hasSelection)

                // Transparent tap grid — uses board-area geometry so tile targets
                // align with the tiles rendered by BoardView.
                if client.isMyTurn, let cardId = client.selectedCardId {
                    GeometryReader { boardGeometry in
                        boardTapOverlay(cardId: cardId, in: boardGeometry)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Player Hand
            MultiplayerHandView(client: client)
                .frame(height: 100)
                .disabled(!client.isMyTurn)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environmentObject(localGameState)
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
            InGameMenuView(onNewGame: {
                showMenuSheet = false
                client.leaveGame()
                dismiss()
            })
            .environmentObject(localGameState)
        }
        .onChange(of: client.latestBroadcast) { _, broadcast in
            if let broadcast = broadcast {
                syncLocalState(from: broadcast)
                if broadcast.isGameRestarted {
                    showRestartedBanner = true
                }
            }
        }
        .onChange(of: client.isGameEnded) { _, ended in
            if ended { dismiss() }
        }
        .overlay {
            if !client.isConnectedToHost {
                disconnectionOverlay
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        // Game-over overlay.
        .overlay {
            if localGameState.overlayMode == .gameOver,
               let activePlayer = localGameState.currentPlayer {
                let teamColor = ThemeColor.getTeamColor(for: activePlayer.team.color)
                GameOverlayView(
                    playerName: activePlayer.name,
                    teamColor: teamColor,
                    borderColor: ThemeColor.getTeamOverlayColor(for: teamColor),
                    backgroundColor: teamColor,
                    onHelp: {},
                    onClose: {},
                    onNewGame: { client.requestEndGame() },
                    onReplayOverride: { client.requestRestart() },
                    mode: .gameOver
                )
                .allowsHitTesting(true)
                .transition(.scale.combined(with: .opacity))
            }
        }
        // "Host restarted" banner — appears once after the host calls restartGame().
        .overlay {
            if showRestartedBanner {
                HexagonOverlay(
                    borderColor: ThemeColor.accentGolden,
                    backgroundColor: ThemeColor.boardFelt,
                    allowsHitTesting: true
                ) {
                    VStack(spacing: GameConstants.overlayContentSpacing) {
                        Text("Host restarted the game")
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .foregroundStyle(ThemeColor.textOnAccent)
                        Button("OK") {
                            showRestartedBanner = false
                        }
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(ThemeColor.textOnAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(ThemeColor.accentPrimary)
                        .clipShape(Capsule())
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        // Dead-card overlay: shown when it's the player's turn and the selected card is dead.
        .overlay {
            if client.isMyTurn,
               localGameState.overlayMode == .deadCard,
               let deadCardId = localGameState.selectedCardId,
               let activePlayer = localGameState.currentPlayer {
                let teamColor = ThemeColor.getTeamColor(for: activePlayer.team.color)
                GameOverlayView(
                    playerName: activePlayer.name,
                    teamColor: teamColor,
                    borderColor: ThemeColor.getTeamOverlayColor(for: teamColor),
                    backgroundColor: teamColor,
                    onHelp: {},
                    onClose: {},
                    mode: .deadCard
                )
                .allowsHitTesting(true)
                .onTapGesture {
                    client.replaceDeadCard(cardId: deadCardId)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    // MARK: - Disconnection Overlay

    private var disconnectionOverlay: some View {
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

        return HexagonOverlay(
            borderColor: ThemeColor.accentGolden,
            backgroundColor: ThemeColor.boardFelt,
            allowsHitTesting: true
        ) {
            VStack(spacing: GameConstants.overlayContentSpacing) {
                HStack(spacing: 6) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(ThemeColor.accentGolden)
                    Text("Disconnected from host")
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(ThemeColor.textOnAccent)
                }

                Text("Reconnecting… \(reconnectSecondsRemaining)s")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(ThemeColor.textOnAccent.opacity(0.7))
                    .onReceive(timer) { _ in
                        guard !client.isConnectedToHost else { return }
                        if reconnectSecondsRemaining > 0 {
                            reconnectSecondsRemaining -= 1
                        } else {
                            dismiss()
                        }
                    }

                Button {
                    reconnectSecondsRemaining = 120
                    client.reconnect()
                } label: {
                    Text("Reconnect Now")
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(ThemeColor.textOnAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(ThemeColor.accentPrimary)
                        .clipShape(Capsule())
                }
            }
        }
        .onChange(of: client.isConnectedToHost) { _, connected in
            if !connected {
                reconnectSecondsRemaining = 120
                client.reconnect()
            }
        }
    }

    // MARK: - Turn Banner

    private var turnBanner: some View {
        Group {
            if let currentPlayer = localGameState.currentPlayer {
                TurnBannerView(
                    playerName: currentPlayer.name,
                    teamColor: ThemeColor.getTeamColor(for: currentPlayer.team.color)
                )
            } else {
                TurnBannerView(playerName: "Waiting…", teamColor: ThemeColor.accentPrimary)
            }
        }
    }

}

// MARK: - State Sync + Board Tap Overlay

private extension MultiplayerPlayerView {

    /// Transparent grid overlay aligned to BoardView's tile layout.
    ///
    /// `geometry` must come from a GeometryReader placed inside the board ZStack —
    /// the same space that BoardView's own GeometryReader measures — so tile sizes match.
    func boardTapOverlay(cardId: UUID, in geometry: GeometryProxy) -> some View {
        let borderThickness = GameConstants.boardBorderThickness
        let insetV = GameConstants.boardContentInsetTop + GameConstants.boardContentInsetBottom
        let insetH = GameConstants.boardContentInsetLeading + GameConstants.boardContentInsetTrailing
        let availableWidth = geometry.size.width - borderThickness * 2 - insetH
        let availableHeight = geometry.size.height - borderThickness * 2 - insetV
        let calcTileW = availableWidth / CGFloat(GameConstants.boardColumns)
        let calcTileH = availableHeight / CGFloat(GameConstants.boardRows)
        let aspectRatio = GameConstants.cardAspectRatio
        let tileW: CGFloat = calcTileW * aspectRatio <= calcTileH ? calcTileW : calcTileH / aspectRatio
        let tileH: CGFloat = calcTileW * aspectRatio <= calcTileH ? calcTileW * aspectRatio : calcTileH
        let validPositions = client.validPositions

        return VStack(spacing: 0) {
            ForEach(0..<GameConstants.boardRows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<GameConstants.boardColumns, id: \.self) { col in
                        let position = Position(row: row, col: col)
                        let isValid = validPositions.contains(position)
                        Color.clear
                            .contentShape(Rectangle())
                            .frame(width: tileW, height: tileH)
                            .onTapGesture {
                                guard isValid else { return }
                                client.confirmPlacement(position: position, cardId: cardId)
                            }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Sync the local display-only GameState from the latest host broadcast.
    func syncLocalState(from broadcast: MultiplayerGameStateBroadcast) {
        let players: [Player] = broadcast.playerInfoList.map { info in
            let playersOnTeam = broadcast.playerInfoList.filter { $0.teamColor == info.teamColor }.count
            let team = Team(color: info.teamColor, numberOfPlayers: playersOnTeam)
            var player = Player(name: info.name, team: team)
            player.id = info.id
            if info.id == broadcast.receivingPlayerId {
                player.cards = broadcast.myCards
            }
            return player
        }

        localGameState.players = players
        localGameState.currentPlayerIndex = broadcast.currentPlayerIndex
        localGameState.boardTiles = broadcast.boardTiles
        localGameState.detectedSequence = broadcast.detectedSequences
        localGameState.selectedCardId = broadcast.selectedCardId
        localGameState.overlayMode = broadcast.overlayMode
        localGameState.winningTeam = broadcast.winningTeam
    }
}

#Preview("MultiplayerPlayerView") {
    let sessionManager = MultipeerSessionManager(displayName: "Preview")
    let client = MultiplayerClient(sessionManager: sessionManager, localPlayerId: UUID())
    MultiplayerPlayerView(client: client)
}
