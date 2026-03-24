//
//  MultiplayerModelsTests.swift
//  SequenceGameTests
//

import Foundation
import Testing
@testable import SequenceGame

// MARK: - PlayerAction Tests

struct PlayerActionEncodingTests {

    @Test("PlayerAction selectCard encodes and decodes correctly")
    func testSelectCard_encodeDecode_preservesCardId() throws {
        let cardId = UUID()
        let action = PlayerAction.selectCard(cardId: cardId)
        let encoded = try JSONEncoder().encode(action)
        let decoded = try JSONDecoder().decode(PlayerAction.self, from: encoded)
        #expect(decoded == action)
    }

    @Test("PlayerAction deselectCard encodes and decodes correctly")
    func testDeselectCard_encodeDecode_roundTrips() throws {
        let action = PlayerAction.deselectCard
        let encoded = try JSONEncoder().encode(action)
        let decoded = try JSONDecoder().decode(PlayerAction.self, from: encoded)
        #expect(decoded == action)
    }

    @Test("PlayerAction selectPosition encodes and decodes correctly")
    func testSelectPosition_encodeDecode_preservesPosition() throws {
        let position = Position(row: 3, col: 5)
        let action = PlayerAction.selectPosition(position: position)
        let encoded = try JSONEncoder().encode(action)
        let decoded = try JSONDecoder().decode(PlayerAction.self, from: encoded)
        #expect(decoded == action)
    }

    @Test("PlayerAction confirmPlacement encodes and decodes correctly")
    func testConfirmPlacement_encodeDecode_preservesPositionAndCardId() throws {
        let position = Position(row: 7, col: 2)
        let cardId = UUID()
        let action = PlayerAction.confirmPlacement(position: position, cardId: cardId)
        let encoded = try JSONEncoder().encode(action)
        let decoded = try JSONDecoder().decode(PlayerAction.self, from: encoded)
        #expect(decoded == action)
    }

    @Test("PlayerAction cancelPlacement encodes and decodes correctly")
    func testCancelPlacement_encodeDecode_roundTrips() throws {
        let action = PlayerAction.cancelPlacement
        let encoded = try JSONEncoder().encode(action)
        let decoded = try JSONDecoder().decode(PlayerAction.self, from: encoded)
        #expect(decoded == action)
    }

    @Test("PlayerAction replaceDeadCard encodes and decodes correctly")
    func testReplaceDeadCard_encodeDecode_preservesCardId() throws {
        let cardId = UUID()
        let action = PlayerAction.replaceDeadCard(cardId: cardId)
        let encoded = try JSONEncoder().encode(action)
        let decoded = try JSONDecoder().decode(PlayerAction.self, from: encoded)
        #expect(decoded == action)
    }
}

// MARK: - MultiplayerRole Tests

struct MultiplayerRoleTests {

    @Test("MultiplayerRole host encodes and decodes correctly")
    func testHost_encodeDecode_roundTrips() throws {
        let role = MultiplayerRole.host
        let encoded = try JSONEncoder().encode(role)
        let decoded = try JSONDecoder().decode(MultiplayerRole.self, from: encoded)
        #expect(decoded == role)
    }

    @Test("MultiplayerRole player encodes and decodes correctly")
    func testPlayer_encodeDecode_preservesPeerIdAndPlayerId() throws {
        let playerId = UUID()
        let role = MultiplayerRole.player(peerId: "iPhone-1", playerId: playerId)
        let encoded = try JSONEncoder().encode(role)
        let decoded = try JSONDecoder().decode(MultiplayerRole.self, from: encoded)
        #expect(decoded == role)
    }
}

// MARK: - DiscardEvent Tests

struct DiscardEventTests {

    @Test("DiscardEvent encodes and decodes correctly")
    func testDiscardEvent_encodeDecode_preservesAllFields() throws {
        let card = Card(cardFace: .queen, suit: .clubs)
        let event = DiscardEvent(playerName: "Alice", teamColor: .blue, card: card)
        let encoded = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(DiscardEvent.self, from: encoded)
        #expect(decoded == event)
    }

    @Test("DiscardEvent preserves player name")
    func testDiscardEvent_playerName_isPreserved() throws {
        let card = Card(cardFace: .ace, suit: .hearts)
        let event = DiscardEvent(playerName: "Bob", teamColor: .red, card: card)
        let encoded = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(DiscardEvent.self, from: encoded)
        #expect(decoded.playerName == "Bob")
    }

    @Test("DiscardEvent preserves team color")
    func testDiscardEvent_teamColor_isPreserved() throws {
        let card = Card(cardFace: .king, suit: .spades)
        let event = DiscardEvent(playerName: "Carol", teamColor: .green, card: card)
        let encoded = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(DiscardEvent.self, from: encoded)
        #expect(decoded.teamColor == .green)
    }
}

// MARK: - PlayerInfo Tests

struct PlayerInfoTests {

    @Test("PlayerInfo encodes and decodes correctly")
    func testPlayerInfo_encodeDecode_preservesAllFields() throws {
        let playerId = UUID()
        let info = PlayerInfo(
            id: playerId,
            name: "Dave",
            teamColor: .blue,
            cardCount: 5,
            peerId: "peer-abc"
        )
        let encoded = try JSONEncoder().encode(info)
        let decoded = try JSONDecoder().decode(PlayerInfo.self, from: encoded)
        #expect(decoded == info)
    }

    @Test("PlayerInfo with nil peerId encodes and decodes correctly")
    func testPlayerInfo_nilPeerId_roundTrips() throws {
        let info = PlayerInfo(
            id: UUID(),
            name: "Eve",
            teamColor: .red,
            cardCount: 3,
            peerId: nil
        )
        let encoded = try JSONEncoder().encode(info)
        let decoded = try JSONDecoder().decode(PlayerInfo.self, from: encoded)
        #expect(decoded.peerId == nil)
    }

    @Test("PlayerInfo card count is preserved")
    func testPlayerInfo_cardCount_isPreserved() throws {
        let info = PlayerInfo(id: UUID(), name: "Frank", teamColor: .green, cardCount: 7, peerId: nil)
        let encoded = try JSONEncoder().encode(info)
        let decoded = try JSONDecoder().decode(PlayerInfo.self, from: encoded)
        #expect(decoded.cardCount == 7)
    }
}

// MARK: - MultiplayerSession Tests

struct MultiplayerSessionTests {

    @Test("MultiplayerSession assigns peer to player")
    func testAssign_newPeer_isAssigned() {
        var session = MultiplayerSession()
        let playerId = UUID()
        session.assign(peerId: "peer-1", to: playerId)
        #expect(session.playerId(for: "peer-1") == playerId)
    }

    @Test("MultiplayerSession reassigns peer to new player")
    func testAssign_existingPeer_overwritesPreviousAssignment() {
        var session = MultiplayerSession()
        let firstPlayerId = UUID()
        let secondPlayerId = UUID()
        session.assign(peerId: "peer-1", to: firstPlayerId)
        session.assign(peerId: "peer-1", to: secondPlayerId)
        #expect(session.playerId(for: "peer-1") == secondPlayerId)
    }

    @Test("MultiplayerSession removes peer on disconnect")
    func testRemovePeer_assignedPeer_isRemovedFromSession() {
        var session = MultiplayerSession()
        session.assign(peerId: "peer-2", to: UUID())
        session.removePeer("peer-2")
        #expect(session.playerId(for: "peer-2") == nil)
    }

    @Test("MultiplayerSession isAssigned returns true for known peer")
    func testIsAssigned_assignedPeer_returnsTrue() {
        var session = MultiplayerSession()
        session.assign(peerId: "peer-3", to: UUID())
        #expect(session.isAssigned("peer-3") == true)
    }

    @Test("MultiplayerSession isAssigned returns false for unknown peer")
    func testIsAssigned_unknownPeer_returnsFalse() {
        let session = MultiplayerSession()
        #expect(session.isAssigned("unknown") == false)
    }

    @Test("MultiplayerSession peerId lookup finds peer for player")
    func testPeerId_assignedPlayerId_returnsPeerId() {
        var session = MultiplayerSession()
        let playerId = UUID()
        session.assign(peerId: "peer-4", to: playerId)
        #expect(session.peerId(for: playerId) == "peer-4")
    }

    @Test("MultiplayerSession peerId lookup returns nil for unknown player")
    func testPeerId_unknownPlayerId_returnsNil() {
        let session = MultiplayerSession()
        #expect(session.peerId(for: UUID()) == nil)
    }
}

// MARK: - MultiplayerGameStateBroadcast Tests

struct MultiplayerGameStateBroadcastTests {

    private func makeBroadcast(
        currentPlayerIndex: Int = 0,
        currentPlayerId: UUID = UUID(),
        currentPlayerPeerId: String? = "peer-1",
        overlayMode: GameOverlayMode = .turnStart,
        boardTiles: [[BoardTile]] = [],
        detectedSequences: [Sequence] = [],
        teamScores: [String: Int] = ["blue": 0, "red": 0],
        playerInfoList: [PlayerInfo] = [],
        receivingPlayerId: UUID = UUID(),
        myCards: [Card] = [],
        validPositions: [Position] = [],
        selectedCardId: UUID? = nil,
        pendingPosition: Position? = nil,
        lastDiscardEvent: DiscardEvent? = nil,
        winningTeam: TeamColor? = nil
    ) -> MultiplayerGameStateBroadcast {
        MultiplayerGameStateBroadcast(
            currentPlayerIndex: currentPlayerIndex,
            currentPlayerId: currentPlayerId,
            currentPlayerPeerId: currentPlayerPeerId,
            overlayMode: overlayMode,
            boardTiles: boardTiles,
            detectedSequences: detectedSequences,
            teamScores: teamScores,
            playerInfoList: playerInfoList,
            receivingPlayerId: receivingPlayerId,
            myCards: myCards,
            validPositions: validPositions,
            selectedCardId: selectedCardId,
            pendingPosition: pendingPosition,
            lastDiscardEvent: lastDiscardEvent,
            winningTeam: winningTeam
        )
    }

    @Test("MultiplayerGameStateBroadcast encodes and decodes correctly")
    func testBroadcast_encodeDecode_roundTrips() throws {
        let broadcast = makeBroadcast()
        let encoded = try JSONEncoder().encode(broadcast)
        let decoded = try JSONDecoder().decode(MultiplayerGameStateBroadcast.self, from: encoded)
        #expect(decoded == broadcast)
    }

    @Test("MultiplayerGameStateBroadcast preserves currentPlayerIndex")
    func testBroadcast_currentPlayerIndex_isPreserved() throws {
        let broadcast = makeBroadcast(currentPlayerIndex: 3)
        let encoded = try JSONEncoder().encode(broadcast)
        let decoded = try JSONDecoder().decode(MultiplayerGameStateBroadcast.self, from: encoded)
        #expect(decoded.currentPlayerIndex == 3)
    }

    @Test("MultiplayerGameStateBroadcast preserves myCards")
    func testBroadcast_myCards_arePreserved() throws {
        let cards = [Card(cardFace: .ace, suit: .hearts), Card(cardFace: .king, suit: .spades)]
        let broadcast = makeBroadcast(myCards: cards)
        let encoded = try JSONEncoder().encode(broadcast)
        let decoded = try JSONDecoder().decode(MultiplayerGameStateBroadcast.self, from: encoded)
        #expect(decoded.myCards == cards)
    }

    @Test("MultiplayerGameStateBroadcast preserves validPositions")
    func testBroadcast_validPositions_arePreserved() throws {
        let positions = [Position(row: 1, col: 2), Position(row: 5, col: 8)]
        let broadcast = makeBroadcast(validPositions: positions)
        let encoded = try JSONEncoder().encode(broadcast)
        let decoded = try JSONDecoder().decode(MultiplayerGameStateBroadcast.self, from: encoded)
        #expect(decoded.validPositions == positions)
    }

    @Test("MultiplayerGameStateBroadcast preserves pendingPosition")
    func testBroadcast_pendingPosition_isPreserved() throws {
        let position = Position(row: 4, col: 6)
        let broadcast = makeBroadcast(pendingPosition: position)
        let encoded = try JSONEncoder().encode(broadcast)
        let decoded = try JSONDecoder().decode(MultiplayerGameStateBroadcast.self, from: encoded)
        #expect(decoded.pendingPosition == position)
    }

    @Test("MultiplayerGameStateBroadcast preserves nil pendingPosition")
    func testBroadcast_nilPendingPosition_isPreserved() throws {
        let broadcast = makeBroadcast(pendingPosition: nil)
        let encoded = try JSONEncoder().encode(broadcast)
        let decoded = try JSONDecoder().decode(MultiplayerGameStateBroadcast.self, from: encoded)
        #expect(decoded.pendingPosition == nil)
    }

    @Test("MultiplayerGameStateBroadcast preserves lastDiscardEvent")
    func testBroadcast_lastDiscardEvent_isPreserved() throws {
        let card = Card(cardFace: .two, suit: .diamonds)
        let event = DiscardEvent(playerName: "Grace", teamColor: .blue, card: card)
        let broadcast = makeBroadcast(lastDiscardEvent: event)
        let encoded = try JSONEncoder().encode(broadcast)
        let decoded = try JSONDecoder().decode(MultiplayerGameStateBroadcast.self, from: encoded)
        #expect(decoded.lastDiscardEvent == event)
    }

    @Test("MultiplayerGameStateBroadcast preserves winning team")
    func testBroadcast_winningTeam_isPreserved() throws {
        let broadcast = makeBroadcast(winningTeam: .red)
        let encoded = try JSONEncoder().encode(broadcast)
        let decoded = try JSONDecoder().decode(MultiplayerGameStateBroadcast.self, from: encoded)
        #expect(decoded.winningTeam == .red)
    }

    @Test("MultiplayerGameStateBroadcast preserves team scores")
    func testBroadcast_teamScores_arePreserved() throws {
        let scores = ["blue": 2, "red": 1, "green": 0]
        let broadcast = makeBroadcast(teamScores: scores)
        let encoded = try JSONEncoder().encode(broadcast)
        let decoded = try JSONDecoder().decode(MultiplayerGameStateBroadcast.self, from: encoded)
        #expect(decoded.teamScores == scores)
    }
}
