//
//  MultiplayerCoordinator.swift
//  SequenceGame
//
//  iPad-side coordinator. Owns GameState, receives PlayerAction messages from
//  iPhones via MultipeerSessionManager, validates turn ownership, dispatches to
//  GameState, and broadcasts MultiplayerGameStateBroadcast after every change.
//

import Foundation
import MultipeerConnectivity

/// iPad-side coordinator for local multiplayer.
///
/// Responsibilities:
/// - Receives encoded `PlayerAction` data from connected iPhones.
/// - Validates that the action comes from the peer whose turn it is.
/// - Dispatches valid actions to `GameState`.
/// - Builds and broadcasts `MultiplayerGameStateBroadcast` to all peers after every state change.
/// - Manages a `pendingPosition` that is highlighted on the board before the player confirms.
final class MultiplayerCoordinator: ObservableObject {

    // MARK: - Published State

    /// The authoritative game state owned by the host (iPad).
    @Published private(set) var gameState: GameState = GameState()

    /// Position highlighted on the board pending player confirmation.
    /// Set when an iPhone sends `.selectPosition`; cleared on confirm or cancel.
    @Published private(set) var pendingPosition: Position?

    // MARK: - Private Properties

    private let sessionManager: MultipeerSessionManager
    private var session: MultiplayerSession = MultiplayerSession()
    private let encoder: JSONEncoder = JSONEncoder()
    private let decoder: JSONDecoder = JSONDecoder()

    // MARK: - Init

    init(sessionManager: MultipeerSessionManager) {
        self.sessionManager = sessionManager
        setupDataReceiver()
    }

    // MARK: - Setup

    private func setupDataReceiver() {
        // Observe receivedData via polling in handle method — called by view layer.
        // Views should forward received data by calling handleReceivedData(_:from:).
    }

    // MARK: - Session Management

    /// Assign a connected peer to a player slot.
    func assign(peerId: String, to playerId: UUID) {
        session.assign(peerId: peerId, to: playerId)
    }

    /// Start the game with the given players and broadcast initial state.
    func startGame(players: [Player]) {
        gameState.startGame(with: players)
        pendingPosition = nil
        broadcastState()
    }

    // MARK: - Action Handling

    /// Decode and handle a raw data message received from an iPhone peer.
    func handleReceivedData(_ data: Data, from peer: MCPeerID) {
        guard let action = try? decoder.decode(PlayerAction.self, from: data) else { return }
        handle(action: action, from: peer)
    }

    /// Process a `PlayerAction` from the given peer.
    ///
    /// Guards that the action originates from the peer whose turn it currently is.
    func handle(action: PlayerAction, from peer: MCPeerID) {
        let peerId = peer.displayName

        // Validate turn ownership for actions that require it.
        switch action {
        case .deselectCard, .cancelPlacement:
            // These are always allowed for the current turn peer.
            guard isCurrentTurnPeer(peerId) else { return }
        case .selectCard, .selectPosition, .confirmPlacement, .replaceDeadCard:
            guard isCurrentTurnPeer(peerId) else { return }
        }

        switch action {
        case .selectCard(let cardId):
            gameState.selectCard(cardId)
            pendingPosition = nil
            broadcastState()

        case .deselectCard:
            gameState.selectedCardId = nil
            gameState.overlayMode = .turnStart
            pendingPosition = nil
            broadcastState()

        case .selectPosition(let position):
            // Highlight on board but don't commit yet.
            pendingPosition = position
            broadcastState()

        case .confirmPlacement(let position, let cardId):
            pendingPosition = nil
            gameState.performPlay(atPos: position, using: cardId)
            broadcastState()

        case .cancelPlacement:
            pendingPosition = nil
            broadcastState()

        case .replaceDeadCard(let cardId):
            gameState.replaceDeadCard(cardId)
            pendingPosition = nil
            broadcastState()
        }
    }

    // MARK: - Broadcasting

    /// Build a state snapshot for `recipientPlayerId` and broadcast to all connected peers.
    func broadcastState() {
        let connectedPeers = sessionManager.connectedPeers
        guard !connectedPeers.isEmpty else { return }

        for peer in connectedPeers {
            let peerId = peer.displayName
            let recipientPlayerId = session.playerId(for: peerId)
            let broadcast = buildBroadcast(for: recipientPlayerId)
            if let data = try? encoder.encode(broadcast) {
                sessionManager.send(data, to: peer)
            }
        }
    }

    /// Send the current state to a single peer (e.g., after they first connect).
    func sendState(to peer: MCPeerID) {
        let peerId = peer.displayName
        let recipientPlayerId = session.playerId(for: peerId)
        let broadcast = buildBroadcast(for: recipientPlayerId)
        if let data = try? encoder.encode(broadcast) {
            sessionManager.send(data, to: peer)
        }
    }

    // MARK: - Private Helpers

    private func isCurrentTurnPeer(_ peerId: String) -> Bool {
        guard let currentPlayer = gameState.currentPlayer else { return false }
        return session.peerId(for: currentPlayer.id) == peerId
    }

    private func buildBroadcast(for recipientPlayerId: UUID?) -> MultiplayerGameStateBroadcast {
        let players = gameState.players
        let currentPlayer = gameState.currentPlayer
        let currentPeerId = currentPlayer.flatMap { session.peerId(for: $0.id) }

        let playerInfoList = players.map { player in
            PlayerInfo(
                id: player.id,
                name: player.name,
                teamColor: player.team.color,
                cardCount: player.cards.count,
                peerId: session.peerId(for: player.id)
            )
        }

        // Only send the recipient's own cards.
        let myCards: [Card]
        if let recipientId = recipientPlayerId,
           let player = players.first(where: { $0.id == recipientId }) {
            myCards = player.cards
        } else {
            myCards = []
        }

        let teamScores = Dictionary(
            uniqueKeysWithValues: Dictionary(
                grouping: gameState.detectedSequence,
                by: { $0.teamColor }
            ).map { teamColor, sequences in
                (teamColor.stringValue, sequences.count)
            }
        )

        return MultiplayerGameStateBroadcast(
            currentPlayerIndex: gameState.currentPlayerIndex,
            currentPlayerId: currentPlayer?.id,
            currentPlayerPeerId: currentPeerId,
            overlayMode: gameState.overlayMode,
            boardTiles: gameState.boardTiles,
            detectedSequences: gameState.detectedSequence,
            teamScores: teamScores,
            playerInfoList: playerInfoList,
            receivingPlayerId: recipientPlayerId,
            myCards: myCards,
            validPositions: gameState.validPositionsForSelectedCard,
            selectedCardId: gameState.selectedCardId,
            pendingPosition: pendingPosition,
            lastDiscardEvent: nil,
            winningTeam: gameState.winningTeam
        )
    }
}
