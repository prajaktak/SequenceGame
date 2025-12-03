//
//  GameRestartWithAITests.swift
//  SequenceGameTests
//
//  Created by Prajakta Kulkarni on 01/12/2025.
//

import Testing
@testable import SequenceGame

struct GameRestartWithAITests {

    // MARK: - Game Restart Tests

    @Test("Play Again preserves AI players")
    func testPlayAgainPreservesAIPlayers() throws {
        let gameState = GameState()

        let humanPlayer = Player(
            name: "Human",
            team: Team(color: .blue, numberOfPlayers: 1),
            isPlaying: false,
            cards: [],
            isAI: false,
            aiDifficulty: nil
        )

        let easyAI = Player(
            name: "Easy AI",
            team: Team(color: .green, numberOfPlayers: 1),
            isPlaying: false,
            cards: [],
            isAI: true,
            aiDifficulty: .easy
        )

        let hardAI = Player(
            name: "Hard AI",
            team: Team(color: .red, numberOfPlayers: 1),
            isPlaying: false,
            cards: [],
            isAI: true,
            aiDifficulty: .hard
        )

        gameState.startGame(with: [humanPlayer, easyAI, hardAI])

        #expect(gameState.players.count == 3)
        #expect(gameState.players[0].isAI == false)
        #expect(gameState.players[1].isAI == true)
        #expect(gameState.players[2].isAI == true)

        try gameState.restartGame()

        #expect(gameState.players.count == 3)
        #expect(gameState.players[0].isAI == false)
        #expect(gameState.players[1].isAI == true)
        #expect(gameState.players[1].aiDifficulty == .easy)
        #expect(gameState.players[2].isAI == true)
        #expect(gameState.players[2].aiDifficulty == .hard)
    }

    @Test("Restart game preserves mixed AI and human configuration")
    func testRestartWithMixedPlayers() throws {
        let gameState = GameState()

        let players = [
            Player.aiPlayer(name: "AI 1", team: Team(color: .blue, numberOfPlayers: 1), difficulty: .hard),
            Player(name: "Human 1", team: Team(color: .green, numberOfPlayers: 1)),
            Player.aiPlayer(name: "AI 2", team: Team(color: .red, numberOfPlayers: 1), difficulty: .medium),
            Player(name: "Human 2", team: Team(color: .blue, numberOfPlayers: 1))
        ]

        gameState.startGame(with: players)
        gameState.advanceTurn()
        gameState.advanceTurn()

        try gameState.restartGame()

        #expect(gameState.players[0].isAI == true)
        #expect(gameState.players[0].aiDifficulty == .hard)
        #expect(gameState.players[1].isAI == false)
        #expect(gameState.players[1].aiDifficulty == nil)
        #expect(gameState.players[2].isAI == true)
        #expect(gameState.players[2].aiDifficulty == .medium)
        #expect(gameState.players[3].isAI == false)
        #expect(gameState.players[3].aiDifficulty == nil)
    }

    @Test("Restart game resets cards but preserves AI properties")
    func testRestartResetsCardsButPreservesAI() throws {
        let gameState = GameState()

        let aiPlayer = Player.aiPlayer(
            name: "Test AI",
            team: Team(color: .blue, numberOfPlayers: 1),
            difficulty: .hard
        )

        let humanPlayer = Player(name: "Test Human", team: Team(color: .green, numberOfPlayers: 1))

        gameState.startGame(with: [aiPlayer, humanPlayer])

        #expect(!gameState.players[0].cards.isEmpty)
        #expect(!gameState.players[1].cards.isEmpty)

        try gameState.restartGame()

        #expect(!gameState.players[0].cards.isEmpty)
        #expect(!gameState.players[1].cards.isEmpty)
        #expect(gameState.players[0].isAI == true)
        #expect(gameState.players[0].aiDifficulty == .hard)
        #expect(gameState.players[1].isAI == false)
    }

    @Test("All difficulty levels preserved on restart")
    func testAllDifficultyLevelsPreserved() throws {
        let gameState = GameState()

        let players = [
            Player.aiPlayer(name: "Easy", team: Team(color: .blue, numberOfPlayers: 1), difficulty: .easy),
            Player.aiPlayer(name: "Medium", team: Team(color: .green, numberOfPlayers: 1), difficulty: .medium),
            Player.aiPlayer(name: "Hard", team: Team(color: .red, numberOfPlayers: 1), difficulty: .hard)
        ]

        gameState.startGame(with: players)
        try gameState.restartGame()

        #expect(gameState.players[0].aiDifficulty == .easy)
        #expect(gameState.players[1].aiDifficulty == .medium)
        #expect(gameState.players[2].aiDifficulty == .hard)
    }

    @Test("Restart preserves player names")
    func testRestartPreservesPlayerNames() throws {
        let gameState = GameState()

        let players = [
            Player.aiPlayer(name: "Easy Bot", team: Team(color: .blue, numberOfPlayers: 1), difficulty: .easy),
            Player(name: "Human Player", team: Team(color: .green, numberOfPlayers: 1)),
            Player.aiPlayer(name: "Hard Bot", team: Team(color: .red, numberOfPlayers: 1), difficulty: .hard)
        ]

        gameState.startGame(with: players)
        try gameState.restartGame()

        #expect(gameState.players[0].name == "Easy Bot")
        #expect(gameState.players[1].name == "Human Player")
        #expect(gameState.players[2].name == "Hard Bot")
    }

    @Test("Restart preserves team colors")
    func testRestartPreservesTeamColors() throws {
        let gameState = GameState()

        let players = [
            Player.aiPlayer(name: "AI 1", team: Team(color: .blue, numberOfPlayers: 1), difficulty: .easy),
            Player(name: "Human", team: Team(color: .green, numberOfPlayers: 1)),
            Player.aiPlayer(name: "AI 2", team: Team(color: .red, numberOfPlayers: 1), difficulty: .hard)
        ]

        gameState.startGame(with: players)
        try gameState.restartGame()

        #expect(gameState.players[0].team.color == .blue)
        #expect(gameState.players[1].team.color == .green)
        #expect(gameState.players[2].team.color == .red)
    }

    @Test("Restart resets game state")
    func testRestartResetsGameState() throws {
        let gameState = GameState()

        let players = [
            Player.aiPlayer(name: "AI", team: Team(color: .blue, numberOfPlayers: 1), difficulty: .easy),
            Player(name: "Human", team: Team(color: .green, numberOfPlayers: 1))
        ]

        gameState.startGame(with: players)

        // Advance game state
        gameState.advanceTurn()
        gameState.advanceTurn()

        try gameState.restartGame()

        #expect(gameState.currentPlayerIndex == 0)
        #expect(gameState.winningTeam == nil)
        #expect(gameState.detectedSequence.isEmpty)
    }
}
