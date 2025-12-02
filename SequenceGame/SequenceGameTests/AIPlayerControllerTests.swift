//
//  AIPlayerControllerTests.swift
//  SequenceGameTests
//
//  Created by Prajakta Kulkarni on 01/12/2025.
//

import Testing
@testable import SequenceGame

struct AIPlayerControllerTests {

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

    // MARK: - AIPlayerController Tests

    @Test("Controller initializes with easy strategy")
    func testControllerInitializationEasy() {
        let controller = AIPlayerController(difficulty: .easy)

        #expect(controller.difficulty == .easy)
        #expect(controller.strategy is EasyAIStrategy)
    }

    @Test("Controller initializes with medium strategy")
    func testControllerInitializationMedium() {
        let controller = AIPlayerController(difficulty: .medium)

        #expect(controller.difficulty == .medium)
        #expect(controller.strategy is MediumAIStrategy)
    }

    @Test("Controller initializes with hard strategy")
    func testControllerInitializationHard() {
        let controller = AIPlayerController(difficulty: .hard)

        #expect(controller.difficulty == .hard)
        #expect(controller.strategy is HardAIStrategy)
    }

    @Test("Execute turn returns false when current player is not AI")
    func testExecuteTurnFailsForNonAIPlayer() {
        let gameState = createTestGameStateWithAI()
        let controller = AIPlayerController(difficulty: .easy)

        // Current player is human (index 0)
        #expect(gameState.currentPlayerIndex == 0)
        #expect(gameState.currentPlayer?.isAI == false)

        let result = controller.executeTurn(in: gameState)

        #expect(result == false)
    }

    @Test("Execute turn succeeds when current player is AI")
    func testExecuteTurnSucceedsForAIPlayer() {
        let gameState = createTestGameStateWithAI()
        let controller = AIPlayerController(difficulty: .easy)

        // Advance to AI player (index 1)
        gameState.advanceTurn()
        #expect(gameState.currentPlayerIndex == 1)
        #expect(gameState.currentPlayer?.isAI == true)

        let result = controller.executeTurn(in: gameState)

        #expect(result == true)
    }

    @Test("Execute turn returns false when no playable cards")
    func testExecuteTurnFailsWithNoPlayableCards() {
        let gameState = createTestGameStateWithAI()
        let controller = AIPlayerController(difficulty: .easy)

        // Advance to AI player
        gameState.advanceTurn()

        // Remove all cards from AI player's hand
        let aiPlayerIndex = gameState.currentPlayerIndex
        gameState.players[aiPlayerIndex].cards = []

        let result = controller.executeTurn(in: gameState)

        #expect(result == false)
    }
}
