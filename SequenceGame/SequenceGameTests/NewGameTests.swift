//
//  NewGameTests.swift
//  SequenceGameTests
//
//  Created on 2025-11-24.
//

import Foundation
import Testing
@testable import SequenceGame

/// Unit tests for new game functionality.
///
/// Tests the `resetGame()` method and new game initialization flow,
/// ensuring games can be properly reset and new games can be started
/// without interfering with existing game state.
@Suite("New Game Tests")
struct NewGameTests {
    
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
    
    @Test("resetGame clears all players when starting new game")
    func testResetGame_clearsAllPlayers() {
        let state = createTestGameState()
        
        state.resetGame()
        
        #expect(state.players.isEmpty)
    }
    
    @Test("resetGame resets current player index to zero")
    func testResetGame_resetsCurrentPlayerIndexToZero() {
        let state = createTestGameState()
        state.currentPlayerIndex = 1
        
        state.resetGame()
        
        #expect(state.currentPlayerIndex == 0)
    }
    
    @Test("resetGame clears selected card ID")
    func testResetGame_clearsSelectedCardId() {
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
        
        state.resetGame()
        
        #expect(state.detectedSequence.isEmpty)
    }
    
    @Test("resetGame clears tiles in sequences cache")
    func testResetGame_clearsTilesInSequencesCache() {
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
    
    @Test("resetGame resets board to default size")
    func testResetGame_resetsBoardToDefaultSize() {
        let state = createTestGameState()
        
        state.resetGame()
        
        #expect(state.board.row == GameConstants.boardRows)
        #expect(state.board.col == GameConstants.boardColumns)
    }
    
    @Test("resetGame resets board tiles to initial state")
    func testResetGame_resetsBoardTilesToInitialState() {
        let state = createTestGameState()
        
        state.resetGame()
        
        #expect(state.boardTiles.count == GameConstants.boardRows)
        #expect(state.boardTiles[0].count == GameConstants.boardColumns)
    }
    
    @Test("resetGame resets deck to new DoubleDeck")
    func testResetGame_resetsDeckToNewDoubleDeck() {
        let state = createTestGameState()
        // After startGame, some cards are dealt, so deck has fewer than 104 cards
        let originalDeckCardCount = state.deck.cardsRemaining()
        #expect(originalDeckCardCount < GameConstants.totalCardsInDoubleDeck)
        
        state.resetGame()
        
        // New deck should have full card count (104 cards)
        let newDeckCardCount = state.deck.cardsRemaining()
        #expect(newDeckCardCount == GameConstants.totalCardsInDoubleDeck)
    }
    
    @Test("resetGame with empty state does not crash")
    func testResetGame_withEmptyState_doesNotCrash() {
        let state = GameState()
        
        // Should not crash when called on empty state
        state.resetGame()
        
        #expect(state.players.isEmpty)
        #expect(state.currentPlayerIndex == 0)
    }
    
    // MARK: - startGame() After Reset Tests
    
    @Test("startGame after reset initializes new players correctly")
    func testStartGame_afterReset_initializesNewPlayers() {
        let state = createTestGameState()
        state.resetGame()
        
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let teamRed = Team(color: .red, numberOfPlayers: 1)
        let newPlayer1 = Player(name: "New Player 1", team: teamBlue, cards: [])
        let newPlayer2 = Player(name: "New Player 2", team: teamRed, cards: [])
        state.startGame(with: [newPlayer1, newPlayer2])
        
        #expect(state.players.count == 2)
        #expect(state.players[0].name == "New Player 1")
        #expect(state.players[1].name == "New Player 2")
    }
    
    @Test("startGame after reset sets current player index to zero")
    func testStartGame_afterReset_setsCurrentPlayerIndexToZero() {
        let state = createTestGameState()
        state.resetGame()
        
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let teamRed = Team(color: .red, numberOfPlayers: 1)
        let newPlayer1 = Player(name: "New Player 1", team: teamBlue, cards: [])
        let newPlayer2 = Player(name: "New Player 2", team: teamRed, cards: [])
        state.startGame(with: [newPlayer1, newPlayer2])
        
        #expect(state.currentPlayerIndex == 0)
    }
    
    @Test("startGame after reset deals cards to players")
    func testStartGame_afterReset_dealsCardsToPlayers() {
        let state = createTestGameState()
        state.resetGame()
        
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let teamRed = Team(color: .red, numberOfPlayers: 1)
        let newPlayer1 = Player(name: "New Player 1", team: teamBlue, cards: [])
        let newPlayer2 = Player(name: "New Player 2", team: teamRed, cards: [])
        state.startGame(with: [newPlayer1, newPlayer2])
        
        #expect(!state.players[0].cards.isEmpty)
        #expect(!state.players[1].cards.isEmpty)
    }
    
    @Test("startGame after reset sets overlay mode to turnStart")
    func testStartGame_afterReset_setsOverlayModeToTurnStart() {
        let state = createTestGameState()
        state.resetGame()
        
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let teamRed = Team(color: .red, numberOfPlayers: 1)
        let newPlayer1 = Player(name: "New Player 1", team: teamBlue, cards: [])
        let newPlayer2 = Player(name: "New Player 2", team: teamRed, cards: [])
        state.startGame(with: [newPlayer1, newPlayer2])
        
        #expect(state.overlayMode == .turnStart)
    }
    
    @Test("startGame after reset sets up board correctly")
    func testStartGame_afterReset_setsUpBoardCorrectly() {
        let state = createTestGameState()
        state.resetGame()
        
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let teamRed = Team(color: .red, numberOfPlayers: 1)
        let newPlayer1 = Player(name: "New Player 1", team: teamBlue, cards: [])
        let newPlayer2 = Player(name: "New Player 2", team: teamRed, cards: [])
        state.startGame(with: [newPlayer1, newPlayer2])
        
        #expect(state.board.row == GameConstants.boardRows)
        #expect(state.board.col == GameConstants.boardColumns)
        #expect(state.boardTiles.count == GameConstants.boardRows)
    }
    
    // MARK: - Multiple Reset Tests
    
    @Test("multiple resets do not cause issues")
    func testMultipleResets_doNotCauseIssues() {
        let state = createTestGameState()
        
        state.resetGame()
        state.resetGame()
        state.resetGame()
        
        #expect(state.players.isEmpty)
        #expect(state.currentPlayerIndex == 0)
        #expect(state.selectedCardId == nil)
    }
    
    @Test("reset then start then reset works correctly")
    func testResetThenStartThenReset_worksCorrectly() {
        let state = createTestGameState()
        state.resetGame()
        
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let teamRed = Team(color: .red, numberOfPlayers: 1)
        let newPlayer1 = Player(name: "New Player 1", team: teamBlue, cards: [])
        let newPlayer2 = Player(name: "New Player 2", team: teamRed, cards: [])
        state.startGame(with: [newPlayer1, newPlayer2])
        
        state.resetGame()
        
        #expect(state.players.isEmpty)
        #expect(state.currentPlayerIndex == 0)
    }
}
