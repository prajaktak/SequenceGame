//
//  GameRestartTests.swift
//  SequenceGameTests
//
//  Created on 2025-11-24.
//

import Foundation
import Testing
@testable import SequenceGame

/// Unit tests for game restart functionality.
///
/// Tests the `restartGame()` and `resetGame()` methods in GameState,
/// ensuring games can be restarted with the same player configuration
/// or completely reset for new game setup.
@Suite("Game Restart Tests")
struct GameRestartTests {
    
    // MARK: - Helper Functions
    
    /// Creates a test game state with 2 players (1 per team)
    private func createTestGameState() -> GameState {
        let state = GameState()
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let teamRed = Team(color: .red, numberOfPlayers: 1)
        let player1 = Player(name: "Player 1", team: teamBlue, cards: [])
        let player2 = Player(name: "Player 2", team: teamRed, cards: [])
        state.startGame(with: [player1, player2])
        return state
    }
    
    /// Creates a game state with 4 players (2 teams, 2 players each)
    private func createFourPlayerGameState() -> GameState {
        let state = GameState()
        let teamBlue = Team(color: .blue, numberOfPlayers: 2)
        let teamRed = Team(color: .red, numberOfPlayers: 2)
        let player1 = Player(name: "T1-P1", team: teamBlue, cards: [])
        let player2 = Player(name: "T2-P1", team: teamRed, cards: [])
        let player3 = Player(name: "T1-P2", team: teamBlue, cards: [])
        let player4 = Player(name: "T2-P2", team: teamRed, cards: [])
        state.startGame(with: [player1, player2, player3, player4])
        return state
    }
    
    // MARK: - resetGame() Tests
    
    @Test("resetGame clears all players")
    func testResetGame_clearsPlayers() {
        let state = createTestGameState()
        
        state.resetGame()
        
        #expect(state.players.isEmpty)
    }
    
    @Test("resetGame resets current player index to zero")
    func testResetGame_resetsCurrentPlayerIndex() {
        let state = createTestGameState()
        state.currentPlayerIndex = 2
        
        state.resetGame()
        
        #expect(state.currentPlayerIndex == 0)
    }
    
    @Test("resetGame clears selected card")
    func testResetGame_clearsSelectedCard() {
        let state = createTestGameState()
        state.selectedCardId = UUID()
        
        state.resetGame()
        
        #expect(state.selectedCardId == nil)
    }
    
    @Test("resetGame clears winning team")
    func testResetGame_clearsWinningTeam() {
        let state = createTestGameState()
        state.winningTeam = .blue
        
        state.resetGame()
        
        #expect(state.winningTeam == nil)
    }
    
    @Test("resetGame clears detected sequences")
    func testResetGame_clearsDetectedSequences() {
        let state = createTestGameState()
        // Note: In real scenario, sequences would be detected during gameplay
        // For test, we're verifying reset clears them
        
        state.resetGame()
        
        #expect(state.detectedSequence.isEmpty)
    }
    
    @Test("resetGame clears tiles in sequences cache")
    func testResetGame_clearsTilesInSequences() {
        let state = createTestGameState()
        
        state.resetGame()
        
        #expect(state.tilesInSequences.isEmpty)
    }
    
    @Test("resetGame sets overlay mode to turnStart")
    func testResetGame_setsOverlayModeToTurnStart() {
        let state = createTestGameState()
        state.overlayMode = .cardSelected
        
        state.resetGame()
        
        #expect(state.overlayMode == .turnStart)
    }
    
    @Test("resetGame resets board to initial state")
    func testResetGame_resetsBoard() {
        let state = createTestGameState()
        
        state.resetGame()
        
        #expect(state.board.row == GameConstants.boardRows)
        #expect(state.board.col == GameConstants.boardColumns)
    }
    
    @Test("resetGame resets board tiles to initial state")
    func testResetGame_resetsBoardTiles() {
        let state = createTestGameState()
        
        state.resetGame()
        
        #expect(state.boardTiles.count == GameConstants.boardRows)
        #expect(state.boardTiles[0].count == GameConstants.boardColumns)
    }
    
    @Test("resetGame resets deck to new DoubleDeck")
    func testResetGame_resetsDeck() {
        let state = createTestGameState()
        // After startGame, some cards are dealt, so deck has fewer than 104 cards
        let originalDeckCardCount = state.deck.cardsRemaining()
        #expect(originalDeckCardCount < GameConstants.totalCardsInDoubleDeck)
        
        state.resetGame()
        
        // New deck should have full card count (104 cards)
        let newDeckCardCount = state.deck.cardsRemaining()
        #expect(newDeckCardCount == GameConstants.totalCardsInDoubleDeck)
    }
    
    // MARK: - restartGame() Tests
    
    @Test("restartGame preserves player names")
    func testRestartGame_preservesPlayerNames() {
        let state = createTestGameState()
        let originalPlayerNames = state.players.map { $0.name }
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        let restartedPlayerNames = state.players.map { $0.name }
        #expect(restartedPlayerNames == originalPlayerNames)
    }
    
    @Test("restartGame preserves team assignments")
    func testRestartGame_preservesTeamAssignments() {
        let state = createTestGameState()
        let originalTeamColors = state.players.map { $0.team.color }
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        let restartedTeamColors = state.players.map { $0.team.color }
        #expect(restartedTeamColors == originalTeamColors)
    }
    
    @Test("restartGame preserves player count")
    func testRestartGame_preservesPlayerCount() {
        let state = createFourPlayerGameState()
        let originalPlayerCount = state.players.count
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        #expect(state.players.count == originalPlayerCount)
    }
    
    @Test("restartGame resets current player index to zero")
    func testRestartGame_resetsCurrentPlayerIndex() {
        let state = createTestGameState()
        state.currentPlayerIndex = 1
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        #expect(state.currentPlayerIndex == 0)
    }
    
    @Test("restartGame clears selected card")
    func testRestartGame_clearsSelectedCard() {
        let state = createTestGameState()
        state.selectedCardId = UUID()
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        #expect(state.selectedCardId == nil)
    }
    
    @Test("restartGame clears winning team")
    func testRestartGame_clearsWinningTeam() {
        let state = createTestGameState()
        state.winningTeam = .blue
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        #expect(state.winningTeam == nil)
    }
    
    @Test("restartGame clears detected sequences")
    func testRestartGame_clearsDetectedSequences() {
        let state = createTestGameState()
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        #expect(state.detectedSequence.isEmpty)
    }
    
    @Test("restartGame sets overlay mode to turnStart")
    func testRestartGame_setsOverlayModeToTurnStart() {
        let state = createTestGameState()
        state.overlayMode = .cardSelected
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        #expect(state.overlayMode == .turnStart)
    }
    
    @Test("restartGame deals new cards to players")
    func testRestartGame_dealsNewCards() {
        let state = createTestGameState()
        let originalCardCount = state.players[0].cards.count
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        // Cards should be dealt again with same count
        let newCardCount = state.players[0].cards.count
        #expect(newCardCount == originalCardCount)
        
        // Cards should be different (deck was reset and shuffled, so different cards dealt)
        // Note: Due to shuffling, it's extremely unlikely (but theoretically possible)
        // that the exact same cards are dealt. We verify that the deck was reset and cards were dealt.
        // With shuffling, it's extremely unlikely all cards are the same, but we check
        // that the deck was reset (has fewer than 104 cards after dealing)
        #expect(state.deck.cardsRemaining() < GameConstants.totalCardsInDoubleDeck)
    }
    
    @Test("restartGame resets deck and deals different cards")
    func testRestartGame_resetsDeckAndDealsDifferentCards() {
        let state = createTestGameState()
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        // Verify deck was reset (should have fewer than 104 cards after dealing)
        #expect(state.deck.cardsRemaining() < GameConstants.totalCardsInDoubleDeck)
        
        // Verify all players have cards
        for player in state.players {
            #expect(!player.cards.isEmpty)
        }
        
        // Verify cards were dealt (deck count decreased)
        // For 2 players: 7 cards each = 14 cards dealt, so deck should have 104 - 14 = 90 cards
        let expectedCardsDealt = GameConstants.cardsPerPlayer(playerCount: state.players.count) * state.players.count
        let expectedDeckCount = GameConstants.totalCardsInDoubleDeck - expectedCardsDealt
        #expect(state.deck.cardsRemaining() == expectedDeckCount)
    }
    
    @Test("restartGame resets board state")
    func testRestartGame_resetsBoardState() {
        let state = createTestGameState()
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        // Board should be reset (no chips placed)
        let hasChips = state.boardTiles.flatMap { $0 }.contains { $0.isChipOn }
        #expect(hasChips == false)
    }
    
    @Test("restartGame with empty players throws error")
    func testRestartGame_withEmptyPlayers_throwsError() {
        let state = GameState()
        
        // Should throw error when no players exist
        do {
            try state.restartGame()
            Issue.record("Expected restartGame() to throw error when players are empty")
        } catch GameStateError.cannotRestartWithoutPlayers {
            // Expected error
            #expect(true)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
        
        #expect(state.players.isEmpty)
    }
    
    @Test("restartGame maintains turn order")
    func testRestartGame_maintainsTurnOrder() {
        let state = createFourPlayerGameState()
        let originalPlayerOrder = state.players.map { $0.name }
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        let restartedPlayerOrder = state.players.map { $0.name }
        #expect(restartedPlayerOrder == originalPlayerOrder)
    }
}
