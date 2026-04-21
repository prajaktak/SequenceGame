//
//  MultiplayerClient.swift
//  SequenceGame
//
//  iPhone-side client. Decodes MultiplayerGameStateBroadcast messages received
//  from the iPad host and exposes state via @Published properties. Sends
//  PlayerAction messages back to the host peer.
//

import Combine
import Foundation
import MultipeerConnectivity

/// iPhone-side client for local multiplayer.
///
/// Responsibilities:
/// - Decodes `MultiplayerGameStateBroadcast` messages from the iPad host.
/// - Publishes decoded state for iPhone views to observe.
/// - Sends `PlayerAction` messages to the host via `MultipeerSessionManager`.
final class MultiplayerClient: ObservableObject {

    // MARK: - Published State

    /// The most recently received game state broadcast from the host.
    @Published private(set) var latestBroadcast: MultiplayerGameStateBroadcast?

    /// Whether it is currently this iPhone player's turn.
    @Published private(set) var isMyTurn: Bool = false

    /// Whether this device is currently connected to the iPad host.
    @Published private(set) var isConnectedToHost: Bool = true

    // MARK: - Private Properties

    private let sessionManager: MultipeerSessionManager
    // Updated from receivingPlayerId on first broadcast so it matches the host-assigned UUID.
    private var localPlayerId: UUID
    private let encoder: JSONEncoder = JSONEncoder()
    private let decoder: JSONDecoder = JSONDecoder()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(sessionManager: MultipeerSessionManager, localPlayerId: UUID) {
        self.sessionManager = sessionManager
        self.localPlayerId = localPlayerId
        setupDataReceiver(sessionManager: sessionManager)
    }

    // MARK: - Setup

    private func setupDataReceiver(sessionManager: MultipeerSessionManager) {
        // Subscribe directly to the session manager so broadcasts are processed
        // regardless of which view is currently on screen. Relying on the view
        // layer's onReceive breaks after NavigationStack pushes MultiplayerPlayerView.
        sessionManager.$receivedData
            .compactMap { $0 }
            .sink { [weak self] pair in
                self?.handleReceivedData(pair.data)
            }
            .store(in: &cancellables)

        sessionManager.$connectedPeers
            .sink { [weak self] peers in
                self?.isConnectedToHost = !peers.isEmpty
            }
            .store(in: &cancellables)
    }

    // MARK: - Receiving State

    /// Decode and store a raw broadcast received from the host peer.
    ///
    /// Views should forward data by calling this method whenever
    /// `MultipeerSessionManager.receivedData` changes.
    func handleReceivedData(_ data: Data) {
        guard let broadcast = try? decoder.decode(MultiplayerGameStateBroadcast.self, from: data) else { return }
        // Adopt the host-assigned player ID so isMyTurn comparisons work correctly.
        if let receivingId = broadcast.receivingPlayerId {
            localPlayerId = receivingId
        }
        latestBroadcast = broadcast
        isMyTurn = broadcast.currentPlayerId == localPlayerId
    }

    // MARK: - Sending Actions

    /// Send a `PlayerAction` to the host iPad.
    func send(action: PlayerAction) {
        guard let data = try? encoder.encode(action) else { return }
        sessionManager.send(data)
    }

    /// Convenience: tell the host the player selected a card.
    func selectCard(_ cardId: UUID) {
        send(action: .selectCard(cardId: cardId))
    }

    /// Convenience: tell the host the player deselected the current card.
    func deselectCard() {
        send(action: .deselectCard)
    }

    /// Convenience: send a position selection (first tap — highlights on board).
    func selectPosition(_ position: Position) {
        send(action: .selectPosition(position: position))
    }

    /// Convenience: confirm chip placement after the confirmation dialog.
    func confirmPlacement(position: Position, cardId: UUID) {
        send(action: .confirmPlacement(position: position, cardId: cardId))
    }

    /// Convenience: cancel the pending placement.
    func cancelPlacement() {
        send(action: .cancelPlacement)
    }

    /// Convenience: replace a dead card.
    func replaceDeadCard(cardId: UUID) {
        send(action: .replaceDeadCard(cardId: cardId))
    }

    /// Ask the host to restart the game with the same players.
    func requestRestart() {
        send(action: .requestRestart)
    }

    /// Ask the host to end the game and redirect all devices to the main menu.
    ///
    /// Does NOT disconnect — the iPhone waits for the host's `isGameEnded` broadcast
    /// so all devices navigate together.
    func requestEndGame() {
        send(action: .requestEndGame)
    }

    /// Tell the host this player is leaving, then disconnect.
    func leaveGame() {
        send(action: .leaveGame)
        sessionManager.disconnect()
    }

    /// Attempt to reconnect to the iPad host after a disconnection.
    func reconnect() {
        sessionManager.startBrowsing()
    }

    // MARK: - Convenience Accessors

    /// The cards in this player's hand (decoded from the latest broadcast).
    var myCards: [Card] { latestBroadcast?.myCards ?? [] }

    /// Valid positions for the currently selected card.
    var validPositions: [Position] { latestBroadcast?.validPositions ?? [] }

    /// The currently selected card ID on the host.
    var selectedCardId: UUID? { latestBroadcast?.selectedCardId }

    /// Board tiles from the latest broadcast.
    var boardTiles: [[BoardTile]] { latestBroadcast?.boardTiles ?? [] }

    /// Detected sequences from the latest broadcast.
    var detectedSequences: [Sequence] { latestBroadcast?.detectedSequences ?? [] }

    /// Player info list from the latest broadcast.
    var playerInfoList: [PlayerInfo] { latestBroadcast?.playerInfoList ?? [] }

    /// Team scores from the latest broadcast.
    var teamScores: [String: Int] { latestBroadcast?.teamScores ?? [:] }

    /// The current overlay mode from the latest broadcast.
    var overlayMode: GameOverlayMode? { latestBroadcast?.overlayMode }

    /// The winning team from the latest broadcast.
    var winningTeam: TeamColor? { latestBroadcast?.winningTeam }

    /// True when the host has ended the game early (e.g., player left or host quit).
    var isGameEnded: Bool { latestBroadcast?.isGameEnded ?? false }

    /// True in the single broadcast sent right after the host restarts the game.
    var isGameRestarted: Bool { latestBroadcast?.isGameRestarted ?? false }
}
