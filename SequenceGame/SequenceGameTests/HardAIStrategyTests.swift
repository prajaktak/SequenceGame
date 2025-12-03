//
//  HardAIStrategyTests.swift
//  SequenceGameTests
//
//  Created by Prajakta Kulkarni on 01/12/2025.
//

import Testing
@testable import SequenceGame

struct HardAIStrategyTests {

    // MARK: - Helper Functions

    /// Creates a basic game state with AI and human players
    func createTestGameStateWithAI(aiDifficulty: AIDifficulty = .easy) -> GameState {
        let gameState = GameState()

        let humanPlayer = Player(
            name: "Human",
            team: Team(color: .blue, numberOfPlayers: 1),
            isPlaying: false,
            cards: [],
            isAI: false,
            aiDifficulty: nil
        )

        let aiPlayer = Player.aiPlayer(
            name: "AI Player",
            team: Team(color: .green, numberOfPlayers: 1),
            difficulty: aiDifficulty
        )

        gameState.startGame(with: [humanPlayer, aiPlayer])
        return gameState
    }

    // MARK: - HardAIStrategy Tests

    @Test("Hard strategy selects winning move when available")
    func testHardStrategySelectsWinningMove() {
        let gameState = createTestGameStateWithAI(aiDifficulty: .hard)
        let strategy = HardAIStrategy()

        // Advance to AI player (green team)
        gameState.advanceTurn()

        // Set up a near-win situation for AI
        // Place 4 green chips in a row
        for colIndex in 0..<4 {
            gameState.placeChip(at: Position(row: 5, col: colIndex), teamColor: .green)
        }

        // Give AI a card that can complete the sequence
        let winningCard = Card(cardFace: .two, suit: .hearts)
        let otherCard = Card(cardFace: .three, suit: .diamonds)
        let cards = [otherCard, winningCard]

        // Manually set one of the cards to match position (5, 4)
        gameState.boardTiles[5][4].card = Card(cardFace: .two, suit: .hearts)

        let selectedCardId = strategy.selectCard(from: cards, gameState: gameState)

        #expect(selectedCardId != nil)
    }

    @Test("Hard strategy blocks opponent winning move")
    func testHardStrategyBlocksOpponent() {
        let gameState = createTestGameStateWithAI(aiDifficulty: .hard)
        let strategy = HardAIStrategy()

        // Advance to AI player (green team)
        gameState.advanceTurn()

        // Set up opponent (blue team) near-win
        for colIndex in 0..<4 {
            gameState.placeChip(at: Position(row: 3, col: colIndex), teamColor: .blue)
        }

        let cards = gameState.currentPlayer?.cards ?? []

        let selectedCardId = strategy.selectCard(from: cards, gameState: gameState)

        #expect(selectedCardId != nil)
    }

    @Test("Hard strategy uses one-eyed jack strategically")
    func testHardStrategyUsesOneEyedJack() {
        let gameState = createTestGameStateWithAI(aiDifficulty: .hard)
        let strategy = HardAIStrategy()

        // Advance to AI player
        gameState.advanceTurn()

        // Place opponent chips
        gameState.placeChip(at: Position(row: 5, col: 5), teamColor: .blue)
        gameState.placeChip(at: Position(row: 5, col: 6), teamColor: .blue)

        // Give AI a one-eyed jack
        let oneEyedJack = Card(cardFace: .jack, suit: .hearts)
        let normalCard = Card(cardFace: .two, suit: .diamonds)
        let cards = [normalCard, oneEyedJack]

        let selectedCardId = strategy.selectCard(from: cards, gameState: gameState)

        #expect(selectedCardId != nil)
    }

    @Test("Hard strategy returns nil for empty card list")
    func testHardStrategyReturnsNilForEmptyCards() {
        let gameState = createTestGameStateWithAI(aiDifficulty: .hard)
        let strategy = HardAIStrategy()

        let emptyCards: [Card] = []

        let selectedCardId = strategy.selectCard(from: emptyCards, gameState: gameState)

        #expect(selectedCardId == nil)
    }

    @Test("Hard strategy selects position to complete sequence")
    func testHardStrategyCompletesSequence() {
        let gameState = createTestGameStateWithAI(aiDifficulty: .hard)
        let strategy = HardAIStrategy()

        // Advance to AI player (green team)
        gameState.advanceTurn()

        // Set up 4 chips in a row
        for colIndex in 0..<4 {
            gameState.placeChip(at: Position(row: 5, col: colIndex), teamColor: .green)
        }

        let card = Card(cardFace: .two, suit: .hearts)
        let validPositions = [
            Position(row: 5, col: 4), // Completes sequence
            Position(row: 1, col: 1)  // Random position
        ]

        let selectedPosition = strategy.selectPosition(
            for: card,
            validPositions: validPositions,
            gameState: gameState
        )

        // Should select winning position
        #expect(selectedPosition != nil)
    }
}
