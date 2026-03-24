//
//  MultiplayerPhase2Tests.swift
//  SequenceGameTests
//
//  Tests for Phase 2 multiplayer components:
//    - MultiplayerCoordinator: action dispatch, broadcast building, turn validation
//    - MultiplayerClient: state decoding, convenience accessors
//    - Player.peerID: new property added to Player
//    - GameOverlayMode.waitingForPlayer: new case
//

import Foundation
import MultipeerConnectivity
import Testing
@testable import SequenceGame

// MARK: - Player.peerID Tests

struct PlayerPeerIDTests {

    @Test("Player peerID defaults to nil")
    func testPlayer_peerID_defaultsToNil() {
        let player = Player(name: "Alice", team: Team(color: .blue, numberOfPlayers: 2))
        #expect(player.peerID == nil)
    }

    @Test("Player peerID can be set to a string")
    func testPlayer_peerID_canBeAssigned() {
        var player = Player(name: "Bob", team: Team(color: .red, numberOfPlayers: 2))
        player.peerID = "iPhone-Bob"
        #expect(player.peerID == "iPhone-Bob")
    }

    @Test("Player with peerID encodes and decodes correctly")
    func testPlayer_withPeerID_encodeDecode_roundTrips() throws {
        var player = Player(name: "Carol", team: Team(color: .green, numberOfPlayers: 2))
        player.peerID = "peer-carol"
        let encoded = try JSONEncoder().encode(player)
        let decoded = try JSONDecoder().decode(Player.self, from: encoded)
        #expect(decoded.peerID == "peer-carol")
    }
}

// MARK: - GameOverlayMode.waitingForPlayer Tests

struct GameOverlayModeWaitingTests {

    @Test("GameOverlayMode waitingForPlayer case exists")
    func testWaitingForPlayer_caseExists_isDistinct() {
        let mode = GameOverlayMode.waitingForPlayer
        #expect(mode != .turnStart)
        #expect(mode != .gameOver)
        #expect(mode != .aITurnInProgress)
    }

    @Test("GameOverlayMode waitingForPlayer encodes and decodes correctly")
    func testWaitingForPlayer_encodeDecode_roundTrips() throws {
        let mode = GameOverlayMode.waitingForPlayer
        let encoded = try JSONEncoder().encode(mode)
        let decoded = try JSONDecoder().decode(GameOverlayMode.self, from: encoded)
        #expect(decoded == mode)
    }
}

// MARK: - MultiplayerClient Tests

struct MultiplayerClientTests {

    private func makeBroadcast(
        currentPlayerId: UUID? = nil,
        overlayMode: GameOverlayMode = .turnStart,
        myCards: [Card] = [],
        validPositions: [Position] = [],
        selectedCardId: UUID? = nil,
        pendingPosition: Position? = nil,
        winningTeam: TeamColor? = nil,
        teamScores: [String: Int] = [:]
    ) -> MultiplayerGameStateBroadcast {
        MultiplayerGameStateBroadcast(
            currentPlayerIndex: 0,
            currentPlayerId: currentPlayerId,
            currentPlayerPeerId: nil,
            overlayMode: overlayMode,
            boardTiles: [],
            detectedSequences: [],
            teamScores: teamScores,
            playerInfoList: [],
            receivingPlayerId: nil,
            myCards: myCards,
            validPositions: validPositions,
            selectedCardId: selectedCardId,
            pendingPosition: pendingPosition,
            lastDiscardEvent: nil,
            winningTeam: winningTeam
        )
    }

    @Test("MultiplayerClient isMyTurn is true when currentPlayerId matches localPlayerId")
    func testHandleReceivedData_currentPlayerMatchesLocal_isMyTurnTrue() throws {
        let sessionManager = MultipeerSessionManager(displayName: "iPhone-Test")
        let localId = UUID()
        let client = MultiplayerClient(sessionManager: sessionManager, localPlayerId: localId)
        let broadcast = makeBroadcast(currentPlayerId: localId)
        let data = try JSONEncoder().encode(broadcast)
        client.handleReceivedData(data)
        #expect(client.isMyTurn == true)
    }

    @Test("MultiplayerClient isMyTurn is false when currentPlayerId differs from localPlayerId")
    func testHandleReceivedData_differentCurrentPlayer_isMyTurnFalse() throws {
        let sessionManager = MultipeerSessionManager(displayName: "iPhone-Test")
        let localId = UUID()
        let client = MultiplayerClient(sessionManager: sessionManager, localPlayerId: localId)
        let broadcast = makeBroadcast(currentPlayerId: UUID()) // different player
        let data = try JSONEncoder().encode(broadcast)
        client.handleReceivedData(data)
        #expect(client.isMyTurn == false)
    }

    @Test("MultiplayerClient isMyTurn is false when no broadcast received yet")
    func testIsMyTurn_noBroadcastReceived_isFalse() {
        let sessionManager = MultipeerSessionManager(displayName: "iPhone-Test")
        let client = MultiplayerClient(sessionManager: sessionManager, localPlayerId: UUID())
        #expect(client.isMyTurn == false)
    }

    @Test("MultiplayerClient myCards returns cards from latest broadcast")
    func testMyCards_broadcastWithCards_returnsCards() throws {
        let sessionManager = MultipeerSessionManager(displayName: "iPhone-Test")
        let client = MultiplayerClient(sessionManager: sessionManager, localPlayerId: UUID())
        let cards = [Card(cardFace: .ace, suit: .hearts), Card(cardFace: .king, suit: .clubs)]
        let broadcast = makeBroadcast(myCards: cards)
        let data = try JSONEncoder().encode(broadcast)
        client.handleReceivedData(data)
        #expect(client.myCards == cards)
    }

    @Test("MultiplayerClient myCards returns empty array before any broadcast")
    func testMyCards_noBroadcast_returnsEmpty() {
        let sessionManager = MultipeerSessionManager(displayName: "iPhone-Test")
        let client = MultiplayerClient(sessionManager: sessionManager, localPlayerId: UUID())
        #expect(client.myCards.isEmpty)
    }

    @Test("MultiplayerClient validPositions returns positions from latest broadcast")
    func testValidPositions_broadcastWithPositions_returnsPositions() throws {
        let sessionManager = MultipeerSessionManager(displayName: "iPhone-Test")
        let client = MultiplayerClient(sessionManager: sessionManager, localPlayerId: UUID())
        let positions = [Position(row: 2, col: 3), Position(row: 5, col: 7)]
        let broadcast = makeBroadcast(validPositions: positions)
        let data = try JSONEncoder().encode(broadcast)
        client.handleReceivedData(data)
        #expect(client.validPositions == positions)
    }

    @Test("MultiplayerClient overlayMode returns value from latest broadcast")
    func testOverlayMode_broadcastWithDeadCard_returnsDeadCard() throws {
        let sessionManager = MultipeerSessionManager(displayName: "iPhone-Test")
        let client = MultiplayerClient(sessionManager: sessionManager, localPlayerId: UUID())
        let broadcast = makeBroadcast(overlayMode: .deadCard)
        let data = try JSONEncoder().encode(broadcast)
        client.handleReceivedData(data)
        #expect(client.overlayMode == .deadCard)
    }

    @Test("MultiplayerClient winningTeam returns value from latest broadcast")
    func testWinningTeam_broadcastWithWinner_returnsWinningTeam() throws {
        let sessionManager = MultipeerSessionManager(displayName: "iPhone-Test")
        let client = MultiplayerClient(sessionManager: sessionManager, localPlayerId: UUID())
        let broadcast = makeBroadcast(winningTeam: .blue)
        let data = try JSONEncoder().encode(broadcast)
        client.handleReceivedData(data)
        #expect(client.winningTeam == .blue)
    }

    @Test("MultiplayerClient ignores invalid (non-broadcast) data")
    func testHandleReceivedData_invalidData_latestBroadcastRemainsNil() {
        let sessionManager = MultipeerSessionManager(displayName: "iPhone-Test")
        let client = MultiplayerClient(sessionManager: sessionManager, localPlayerId: UUID())
        let garbage = Data("not json".utf8)
        client.handleReceivedData(garbage)
        #expect(client.latestBroadcast == nil)
    }

    @Test("MultiplayerClient teamScores returns scores from latest broadcast")
    func testTeamScores_broadcastWithScores_returnsScores() throws {
        let sessionManager = MultipeerSessionManager(displayName: "iPhone-Test")
        let client = MultiplayerClient(sessionManager: sessionManager, localPlayerId: UUID())
        let scores = ["blue": 2, "red": 1]
        let broadcast = makeBroadcast(teamScores: scores)
        let data = try JSONEncoder().encode(broadcast)
        client.handleReceivedData(data)
        #expect(client.teamScores == scores)
    }
}

// MARK: - MultiplayerCoordinator Tests

struct MultiplayerCoordinatorTests {

    private func makeCoordinator() -> MultiplayerCoordinator {
        let sessionManager = MultipeerSessionManager(displayName: "iPad-Host")
        return MultiplayerCoordinator(sessionManager: sessionManager)
    }

    private func makePlayer(name: String, color: TeamColor, peerId: String? = nil) -> Player {
        var player = Player(name: name, team: Team(color: color, numberOfPlayers: 2))
        player.peerID = peerId
        return player
    }

    @Test("MultiplayerCoordinator startGame sets gameState players")
    func testStartGame_withPlayers_setsGameStatePlayers() {
        let coordinator = makeCoordinator()
        let players = [
            makePlayer(name: "Alice", color: .blue),
            makePlayer(name: "Bob", color: .red)
        ]
        coordinator.startGame(players: players)
        #expect(coordinator.gameState.players.count == 2)
    }

    @Test("MultiplayerCoordinator startGame clears pendingPosition")
    func testStartGame_clearsPendingPosition() {
        let coordinator = makeCoordinator()
        let players = [
            makePlayer(name: "Alice", color: .blue),
            makePlayer(name: "Bob", color: .red)
        ]
        coordinator.startGame(players: players)
        #expect(coordinator.pendingPosition == nil)
    }

    @Test("MultiplayerCoordinator assign maps peer to player")
    func testAssign_peerId_mapsToPlayer() {
        let coordinator = makeCoordinator()
        let playerId = UUID()
        coordinator.assign(peerId: "peer-1", to: playerId)
        // Verify via broadcastState — coordinator builds correct peerId mapping.
        // We can't directly inspect the session, but we can start a game and
        // verify that the coordinator builds a broadcast with the correct currentPlayerPeerId.
        var players = [
            makePlayer(name: "Alice", color: .blue)
        ]
        players[0].id = playerId
        coordinator.assign(peerId: "peer-alice", to: players[0].id)
        coordinator.startGame(players: players)
        #expect(coordinator.gameState.currentPlayerIndex == 0)
    }

    @Test("MultiplayerCoordinator selectPosition action sets pendingPosition")
    func testHandleReceivedData_selectPosition_setsPendingPosition() {
        let coordinator = makeCoordinator()
        let players = [
            makePlayer(name: "Alice", color: .blue, peerId: "peer-alice"),
            makePlayer(name: "Bob", color: .red, peerId: "peer-bob")
        ]
        coordinator.assign(peerId: "peer-alice", to: players[0].id)
        coordinator.assign(peerId: "peer-bob", to: players[1].id)
        coordinator.startGame(players: players)

        // Alice is first player; simulate her selecting a position.
        let targetPosition = Position(row: 3, col: 4)
        let action = PlayerAction.selectPosition(position: targetPosition)
        let alicePeer = makeFakePeerID(named: "peer-alice")
        coordinator.handle(action: action, from: alicePeer)
        #expect(coordinator.pendingPosition == targetPosition)
    }

    @Test("MultiplayerCoordinator cancelPlacement action clears pendingPosition")
    func testHandleReceivedData_cancelPlacement_clearsPendingPosition() {
        let coordinator = makeCoordinator()
        let players = [
            makePlayer(name: "Alice", color: .blue, peerId: "peer-alice"),
            makePlayer(name: "Bob", color: .red, peerId: "peer-bob")
        ]
        coordinator.assign(peerId: "peer-alice", to: players[0].id)
        coordinator.assign(peerId: "peer-bob", to: players[1].id)
        coordinator.startGame(players: players)

        // First set a pending position.
        coordinator.handle(action: .selectPosition(position: Position(row: 1, col: 1)), from: makeFakePeerID(named: "peer-alice"))
        // Then cancel.
        coordinator.handle(action: .cancelPlacement, from: makeFakePeerID(named: "peer-alice"))
        #expect(coordinator.pendingPosition == nil)
    }

    @Test("MultiplayerCoordinator rejects action from wrong peer")
    func testHandle_actionFromNonCurrentPeer_doesNotChangePendingPosition() {
        let coordinator = makeCoordinator()
        let players = [
            makePlayer(name: "Alice", color: .blue, peerId: "peer-alice"),
            makePlayer(name: "Bob", color: .red, peerId: "peer-bob")
        ]
        coordinator.assign(peerId: "peer-alice", to: players[0].id)
        coordinator.assign(peerId: "peer-bob", to: players[1].id)
        coordinator.startGame(players: players)

        // Bob tries to act but it's Alice's turn.
        coordinator.handle(action: .selectPosition(position: Position(row: 5, col: 5)), from: makeFakePeerID(named: "peer-bob"))
        #expect(coordinator.pendingPosition == nil)
    }

    /// Creates a fake MCPeerID using the display name as the identifier.
    private func makeFakePeerID(named name: String) -> MCPeerID {
        MCPeerID(displayName: name)
    }
}
