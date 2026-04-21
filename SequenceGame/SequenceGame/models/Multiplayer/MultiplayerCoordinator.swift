//
//  MultiplayerCoordinator.swift
//  SequenceGame
//
//  iPad-side coordinator. Owns GameState, receives PlayerAction messages from
//  iPhones via MultipeerSessionManager, validates turn ownership, dispatches to
//  GameState, and broadcasts MultiplayerGameStateBroadcast after every change.
//

import Combine
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

    /// Name of the player who most recently disconnected, if any.
    @Published private(set) var disconnectedPlayerName: String?

    /// True after the 2-minute disconnection grace period expires with no reconnection.
    @Published private(set) var showEndGameButton: Bool = false

    /// True once `endGame()` has been called; views observe this to navigate back to main menu.
    @Published private(set) var isGameEnded: Bool = false

    // MARK: - Private Properties

    private let sessionManager: MultipeerSessionManager
    private var session: MultiplayerSession = MultiplayerSession()
    private let encoder: JSONEncoder = JSONEncoder()
    private let decoder: JSONDecoder = JSONDecoder()
    private var cancellables = Set<AnyCancellable>()
    private var disconnectedPeerId: String?
    private var disconnectionTimer: DispatchWorkItem?

    // MARK: - Init

    init(sessionManager: MultipeerSessionManager) {
        self.sessionManager = sessionManager
        setupDataReceiver()
    }

    // MARK: - Setup

    private func setupDataReceiver() {
        sessionManager.$receivedData
            .compactMap { $0 }
            .sink { [weak self] pair in
                self?.handleReceivedData(pair.data, from: pair.from)
            }
            .store(in: &cancellables)

        sessionManager.$lastDisconnectedPeer
            .compactMap { $0 }
            .sink { [weak self] peer in
                self?.handlePeerDisconnected(peer)
            }
            .store(in: &cancellables)

        sessionManager.$connectedPeers
            .sink { [weak self] peers in
                self?.handleConnectedPeersChanged(peers)
            }
            .store(in: &cancellables)
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
        case .leaveGame, .requestRestart:
            // These are always allowed regardless of whose turn it is.
            break
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

        case .leaveGame:
            endGame()

        case .requestRestart:
            restartGame()

        case .requestEndGame:
            endGame()
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

    /// Send the current state to a single peer (e.g., after they first connect or reconnect).
    func sendState(to peer: MCPeerID) {
        let peerId = peer.displayName
        let recipientPlayerId = session.playerId(for: peerId)
        let broadcast = buildBroadcast(for: recipientPlayerId)
        if let data = try? encoder.encode(broadcast) {
            sessionManager.send(data, to: peer)
        }
    }

    /// Broadcast a game-ended signal to all connected peers so they navigate back to the main menu.
    private func broadcastGameEnded() {
        let connectedPeers = sessionManager.connectedPeers
        for peer in connectedPeers {
            let peerId = peer.displayName
            let recipientPlayerId = session.playerId(for: peerId)
            let broadcast = buildBroadcast(for: recipientPlayerId, isGameEnded: true)
            if let data = try? encoder.encode(broadcast) {
                sessionManager.send(data, to: peer)
            }
        }
    }

    // MARK: - Game Control

    /// Restart the game with the same players and broadcast the new board to all iPhones.
    func restartGame() {
        try? gameState.restartGame()
        pendingPosition = nil
        broadcastRestart()
    }

    /// Broadcast a restart signal so iPhones show the "Host restarted" banner and sync the new board.
    private func broadcastRestart() {
        for peer in sessionManager.connectedPeers {
            let peerId = peer.displayName
            let recipientPlayerId = session.playerId(for: peerId)
            let broadcast = buildBroadcast(for: recipientPlayerId, isGameRestarted: true)
            if let data = try? encoder.encode(broadcast) {
                sessionManager.send(data, to: peer)
            }
        }
    }

    // MARK: - Game End

    /// End the game for all connected players and disconnect.
    ///
    /// `isGameEnded` is set immediately so the host navigates away at once.
    /// The actual session disconnect is delayed 0.5 s to give connected peers
    /// time to receive the `isGameEnded` broadcast before the link closes.
    func endGame() {
        disconnectionTimer?.cancel()
        disconnectionTimer = nil
        broadcastGameEnded()
        isGameEnded = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.sessionManager.disconnect()
        }
    }

    // MARK: - Disconnection Handling

    private func handlePeerDisconnected(_ peer: MCPeerID) {
        let peerId = peer.displayName
        disconnectedPeerId = peerId
        if let playerId = session.playerId(for: peerId),
           let player = gameState.players.first(where: { $0.id == playerId }) {
            disconnectedPlayerName = player.name
        } else {
            disconnectedPlayerName = peer.displayName
        }
        showEndGameButton = false
        // Re-advertise so the peer can reconnect.
        sessionManager.startAdvertising()
        // After 2 minutes with no reconnection, show the "End Game" button.
        disconnectionTimer?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.showEndGameButton = true
        }
        disconnectionTimer = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 120, execute: work)
    }

    private func handleConnectedPeersChanged(_ peers: [MCPeerID]) {
        guard let disconnectedId = disconnectedPeerId else { return }
        guard peers.map({ $0.displayName }).contains(disconnectedId) else { return }
        // Peer reconnected — cancel the timer and clear the banner.
        disconnectionTimer?.cancel()
        disconnectionTimer = nil
        disconnectedPlayerName = nil
        showEndGameButton = false
        disconnectedPeerId = nil
        // Re-send state so the reconnected peer catches up.
        if let peer = peers.first(where: { $0.displayName == disconnectedId }) {
            sendState(to: peer)
        }
    }

    // MARK: - Private Helpers

    private func isCurrentTurnPeer(_ peerId: String) -> Bool {
        guard let currentPlayer = gameState.currentPlayer else { return false }
        return session.peerId(for: currentPlayer.id) == peerId
    }

    private func buildBroadcast(for recipientPlayerId: UUID?, isGameEnded: Bool = false, isGameRestarted: Bool = false) -> MultiplayerGameStateBroadcast {
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
            winningTeam: gameState.winningTeam,
            isGameEnded: isGameEnded,
            isGameRestarted: isGameRestarted
        )
    }
}
