//
//  EasyAIStrategyTests.swift
//  SequenceGameTests
//
//  Created by Prajakta Kulkarni on 01/12/2025.
//

import Testing
@testable import SequenceGame

struct EasyAIStrategyTests {

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

    // MARK: - EasyAIStrategy Tests

    @Test("Easy strategy selects random playable card")
    func testEasyStrategySelectsPlayableCard() {
        let gameState = createTestGameStateWithAI(aiDifficulty: .easy)
        let strategy = EasyAIStrategy()

        // Advance to AI player
        gameState.advanceTurn()

        let cards = gameState.currentPlayer?.cards ?? []
        let selectedCardId = strategy.selectCard(from: cards, gameState: gameState)

        #expect(selectedCardId != nil)
    }

    @Test("Easy strategy returns nil when no playable cards")
    func testEasyStrategyReturnsNilForNoPlayableCards() {
        let gameState = createTestGameStateWithAI(aiDifficulty: .easy)
        let strategy = EasyAIStrategy()

        // Advance to AI player
        gameState.advanceTurn()

        // Create cards with no valid positions
        let deadCards = [Card(cardFace: .ace, suit: .hearts)]

        // Fill all positions for aces
        for rowIndex in 0..<GameConstants.boardRows {
            for colIndex in 0..<GameConstants.boardColumns {
                let tile = gameState.boardTiles[rowIndex][colIndex]
                if tile.card?.cardFace == .ace {
                    gameState.placeChip(
                        at: Position(row: rowIndex, col: colIndex),
                        teamColor: .blue
                    )
                }
            }
        }

        let selectedCardId = strategy.selectCard(from: deadCards, gameState: gameState)

        #expect(selectedCardId == nil)
    }

    @Test("Easy strategy selects random position")
    func testEasyStrategySelectsRandomPosition() {
        let gameState = createTestGameStateWithAI(aiDifficulty: .easy)
        let strategy = EasyAIStrategy()

        let card = Card(cardFace: .two, suit: .hearts)
        let validPositions = [Position(row: 0, col: 1), Position(row: 1, col: 2), Position(row: 2, col: 3)]

        let selectedPosition = strategy.selectPosition(
            for: card,
            validPositions: validPositions,
            gameState: gameState
        )

        #expect(selectedPosition != nil)
        if let selectedPosition = selectedPosition {
            #expect(validPositions.contains(where: { $0 == selectedPosition }))
        }
    }

    @Test("Easy strategy returns nil when no valid positions")
    func testEasyStrategyReturnsNilForNoPositions() {
        let gameState = createTestGameStateWithAI(aiDifficulty: .easy)
        let strategy = EasyAIStrategy()

        let card = Card(cardFace: .two, suit: .hearts)
        let validPositions: [Position] = []

        let selectedPosition = strategy.selectPosition(
            for: card,
            validPositions: validPositions,
            gameState: gameState
        )

        #expect(selectedPosition == nil)
    }
}
