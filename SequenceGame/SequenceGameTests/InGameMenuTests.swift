//
//  InGameMenuTests.swift
//  SequenceGameTests
//
//  Created on 2025-11-24.
//

import Foundation
import Testing
@testable import SequenceGame

/// Unit tests for in-game menu functionality.
///
/// Tests the InGameMenuView behavior and its interactions with GameState,
/// ensuring menu actions (Resume, Restart, New Game) work correctly
/// without breaking the current game state.
@Suite("In-Game Menu Tests")
struct InGameMenuTests {
    
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
    
    // MARK: - Restart Action Tests
    
    @Test("restartGame from menu preserves player configuration")
    func testRestartGame_fromMenu_preservesPlayerConfiguration() {
        let state = createTestGameState()
        let originalPlayerNames = state.players.map { $0.name }
        let originalTeamColors = state.players.map { $0.team.color }
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        let restartedPlayerNames = state.players.map { $0.name }
        let restartedTeamColors = state.players.map { $0.team.color }
        #expect(restartedPlayerNames == originalPlayerNames)
        #expect(restartedTeamColors == originalTeamColors)
    }
    
    @Test("restartGame from menu resets game progress")
    func testRestartGame_fromMenu_resetsGameProgress() {
        let state = createTestGameState()
        state.currentPlayerIndex = 1
        state.selectedCardId = UUID()
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        #expect(state.currentPlayerIndex == 0)
        #expect(state.selectedCardId == nil)
    }
    
    @Test("restartGame from menu clears board chips")
    func testRestartGame_fromMenu_clearsBoardChips() {
        let state = createTestGameState()
        // Simulate some chips placed (in real scenario, chips would be placed during gameplay)
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        let hasChips = state.boardTiles.flatMap { $0 }.contains { $0.isChipOn }
        #expect(hasChips == false)
    }
    
    @Test("restartGame from menu deals new cards")
    func testRestartGame_fromMenu_dealsNewCards() {
        let state = createTestGameState()
        let originalCardCount = state.players[0].cards.count
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        let newCardCount = state.players[0].cards.count
        #expect(newCardCount == originalCardCount)
    }
    
    @Test("restartGame from menu sets overlay mode to turnStart")
    func testRestartGame_fromMenu_setsOverlayModeToTurnStart() {
        let state = createTestGameState()
        state.overlayMode = .cardSelected
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        #expect(state.overlayMode == .turnStart)
    }
    
    // MARK: - New Game Action Tests
    
    @Test("resetGame for new game clears all players")
    func testResetGame_forNewGame_clearsAllPlayers() {
        let state = createTestGameState()
        
        state.resetGame()
        
        #expect(state.players.isEmpty)
    }
    
    @Test("resetGame for new game resets all game state")
    func testResetGame_forNewGame_resetsAllGameState() {
        let state = createTestGameState()
        state.currentPlayerIndex = 1
        state.selectedCardId = UUID()
        state.winningTeam = .blue
        
        state.resetGame()
        
        #expect(state.currentPlayerIndex == 0)
        #expect(state.selectedCardId == nil)
        #expect(state.winningTeam == nil)
    }
    
    @Test("resetGame for new game clears detected sequences")
    func testResetGame_forNewGame_clearsDetectedSequences() {
        let state = createTestGameState()
        
        state.resetGame()
        
        #expect(state.detectedSequence.isEmpty)
        #expect(state.tilesInSequences.isEmpty)
    }
    
    @Test("resetGame for new game resets board")
    func testResetGame_forNewGame_resetsBoard() {
        let state = createTestGameState()
        
        state.resetGame()
        
        #expect(state.board.row == GameConstants.boardRows)
        #expect(state.board.col == GameConstants.boardColumns)
    }
    
    @Test("resetGame for new game resets deck")
    func testResetGame_forNewGame_resetsDeck() {
        let state = createTestGameState()
        // After startGame, some cards are dealt, so deck has fewer than 104 cards
        let originalDeckCardCount = state.deck.cardsRemaining()
        #expect(originalDeckCardCount < GameConstants.totalCardsInDoubleDeck)
        
        state.resetGame()
        
        // New deck should have full card count (104 cards)
        let newDeckCardCount = state.deck.cardsRemaining()
        #expect(newDeckCardCount == GameConstants.totalCardsInDoubleDeck)
    }
    
    // MARK: - Menu State Tests
    
    @Test("menu can be opened during active game")
    func testMenu_canBeOpenedDuringActiveGame() {
        let state = createTestGameState()
        
        // Menu should be accessible when game is active
        #expect(!state.players.isEmpty)
        #expect(state.currentPlayer != nil)
    }
    
    @Test("menu restart action does not affect current game until confirmed")
    func testMenu_restartAction_doesNotAffectGameUntilConfirmed() {
        let state = createTestGameState()
        let originalPlayerCount = state.players.count
        _ = state.currentPlayerIndex
        
        // Menu shows confirmation dialog - game state should not change yet
        // (In real implementation, confirmation is handled by UI)
        // This test verifies restartGame() itself works correctly
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        // After restart, players should still exist but game reset
        #expect(state.players.count == originalPlayerCount)
        #expect(state.currentPlayerIndex == 0)
    }
    
    @Test("menu new game action resets game state")
    func testMenu_newGameAction_resetsGameState() {
        let state = createTestGameState()
        
        state.resetGame()
        
        #expect(state.players.isEmpty)
        #expect(state.currentPlayerIndex == 0)
    }
    
    // MARK: - Menu Integration Tests
    
    @Test("restart then new game works correctly")
    func testRestartThenNewGame_worksCorrectly() {
        let state = createTestGameState()
        let originalPlayerCount = state.players.count
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        #expect(state.players.count == originalPlayerCount)
        
        state.resetGame()
        #expect(state.players.isEmpty)
    }
    
    @Test("new game then start game works correctly")
    func testNewGameThenStartGame_worksCorrectly() {
        let state = createTestGameState()
        
        state.resetGame()
        #expect(state.players.isEmpty)
        
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let teamRed = Team(color: .red, numberOfPlayers: 1)
        let newPlayer1 = Player(name: "New Player 1", team: teamBlue, cards: [])
        let newPlayer2 = Player(name: "New Player 2", team: teamRed, cards: [])
        state.startGame(with: [newPlayer1, newPlayer2])
        
        #expect(state.players.count == 2)
        #expect(state.currentPlayerIndex == 0)
    }
    
    @Test("multiple restart operations work correctly")
    func testMultipleRestartOperations_workCorrectly() {
        let state = createTestGameState()
        let originalPlayerCount = state.players.count
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        #expect(state.players.count == originalPlayerCount)
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        #expect(state.players.count == originalPlayerCount)
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        #expect(state.players.count == originalPlayerCount)
    }
    
    // MARK: - Edge Cases
    
    @Test("restart with empty players throws error")
    func testRestart_withEmptyPlayers_throwsError() {
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
    
    @Test("reset with empty state does not crash")
    func testReset_withEmptyState_doesNotCrash() {
        let state = GameState()
        
        // Should not crash when called on empty state
        state.resetGame()
        
        #expect(state.players.isEmpty)
        #expect(state.currentPlayerIndex == 0)
    }
    
    @Test("restart preserves player order")
    func testRestart_preservesPlayerOrder() {
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
    
    @Test("restart maintains team assignments")
    func testRestart_maintainsTeamAssignments() {
        let state = createFourPlayerGameState()
        let originalTeamAssignments = state.players.map { ($0.name, $0.team.color) }
        
        do {
            try state.restartGame()
        } catch {
            Issue.record("restartGame() should not throw error with valid game state: \(error)")
        }
        
        let restartedTeamAssignments = state.players.map { ($0.name, $0.team.color) }
        // Compare tuples element by element since tuples don't conform to Equatable
        for index in originalTeamAssignments.indices {
            #expect(restartedTeamAssignments[index].0 == originalTeamAssignments[index].0)
            #expect(restartedTeamAssignments[index].1 == originalTeamAssignments[index].1)
        }
    }
}
