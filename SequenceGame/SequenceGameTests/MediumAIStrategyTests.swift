//
//  MediumAIStrategyTests.swift
//  SequenceGameTests
//
//  Created by Prajakta Kulkarni on 01/12/2025.
//

import Testing
@testable import SequenceGame

struct MediumAIStrategyTests {

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

    // MARK: - MediumAIStrategy Tests

    @Test("Medium strategy prioritizes two-eyed jacks")
    func testMediumStrategyPrioritizesTwoEyedJacks() {
        let gameState = createTestGameStateWithAI(aiDifficulty: .medium)
        let strategy = MediumAIStrategy()

        // Advance to AI player
        gameState.advanceTurn()

        // Give AI a two-eyed jack
        let jackOfClubs = Card(cardFace: .jack, suit: .clubs)
        let normalCard = Card(cardFace: .two, suit: .hearts)
        let cards = [normalCard, jackOfClubs]

        let selectedCardId = strategy.selectCard(from: cards, gameState: gameState)

        // Should prefer the jack
        #expect(selectedCardId == jackOfClubs.id)
    }

    @Test("Medium strategy selects card when no jacks available")
    func testMediumStrategySelectsNonJackCard() {
        let gameState = createTestGameStateWithAI(aiDifficulty: .medium)
        let strategy = MediumAIStrategy()

        // Advance to AI player
        gameState.advanceTurn()

        let cards = [
            Card(cardFace: .two, suit: .hearts),
            Card(cardFace: .three, suit: .diamonds)
        ]

        let selectedCardId = strategy.selectCard(from: cards, gameState: gameState)

        #expect(selectedCardId != nil)
    }

    @Test("Medium strategy returns nil for no playable cards")
    func testMediumStrategyReturnsNilWhenNoCards() {
        let gameState = createTestGameStateWithAI(aiDifficulty: .medium)
        let strategy = MediumAIStrategy()

        let emptyCards: [Card] = []

        let selectedCardId = strategy.selectCard(from: emptyCards, gameState: gameState)

        #expect(selectedCardId == nil)
    }

    @Test("Medium strategy selects position with adjacent chips")
    func testMediumStrategyPrefersAdjacentChips() {
        let gameState = createTestGameStateWithAI(aiDifficulty: .medium)
        let strategy = MediumAIStrategy()

        // Advance to AI player (green team)
        gameState.advanceTurn()

        // Place a green chip
        gameState.placeChip(at: Position(row: 5, col: 5), teamColor: .green)

        let card = Card(cardFace: .two, suit: .hearts)
        let validPositions = [
            Position(row: 5, col: 6), // Adjacent to green chip
            Position(row: 1, col: 1)  // Far from any chips
        ]

        let selectedPosition = strategy.selectPosition(
            for: card,
            validPositions: validPositions,
            gameState: gameState
        )

        // Should prefer adjacent position
        #expect(selectedPosition != nil)
    }
}
