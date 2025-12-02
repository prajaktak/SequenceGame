//
//  AIPlayerCreationTests.swift
//  SequenceGameTests
//
//  Created by Prajakta Kulkarni on 01/12/2025.
//

import Foundation
import Testing
@testable import SequenceGame

struct AIPlayerCreationTests {

    // MARK: - AI Player Creation Tests

    @Test("AI player creation with easy difficulty")
    func testAIPlayerCreationEasy() async throws {
        let aiPlayer = Player.aiPlayer(
            name: "AI Player 1",
            team: Team(color: TeamColor.red, numberOfPlayers: 1),
            difficulty: .easy
        )

        #expect(aiPlayer.name == "AI Player 1")
        #expect(aiPlayer.team.color == .red)
        #expect(aiPlayer.team.numberOfPlayers == 1)
        #expect(aiPlayer.isAI)
        #expect(aiPlayer.aiDifficulty == .easy)
    }

    @Test("AI player creation with medium difficulty")
    func testAIPlayerCreationMedium() {
        let aiPlayer = Player.aiPlayer(
            name: "AI Player 2",
            team: Team(color: .blue, numberOfPlayers: 1),
            difficulty: .medium
        )

        #expect(aiPlayer.name == "AI Player 2")
        #expect(aiPlayer.isAI == true)
        #expect(aiPlayer.aiDifficulty == .medium)
    }

    @Test("AI player creation with hard difficulty")
    func testAIPlayerCreationHard() {
        let aiPlayer = Player.aiPlayer(
            name: "AI Player 3",
            team: Team(color: .green, numberOfPlayers: 1),
            difficulty: .hard
        )

        #expect(aiPlayer.name == "AI Player 3")
        #expect(aiPlayer.isAI == true)
        #expect(aiPlayer.aiDifficulty == .hard)
    }

    @Test("AI player helper creates player with empty cards")
    func testAIPlayerHelperEmptyCards() {
        let aiPlayer = Player.aiPlayer(
            name: "Test AI",
            team: Team(color: .red, numberOfPlayers: 1),
            difficulty: .medium
        )

        #expect(aiPlayer.cards.isEmpty)
    }

    @Test("AI player helper creates player with isPlaying false")
    func testAIPlayerHelperIsPlayingFalse() {
        let aiPlayer = Player.aiPlayer(
            name: "Test AI",
            team: Team(color: .red, numberOfPlayers: 1),
            difficulty: .medium
        )

        #expect(aiPlayer.isPlaying == false)
    }

    // MARK: - AIDifficulty Tests

    @Test("Easy difficulty has correct description")
    func testEasyDifficultyDescription() {
        let difficulty = AIDifficulty.easy

        #expect(difficulty.description == "Makes random moves. Great for beginners!")
    }

    @Test("Medium difficulty has correct description")
    func testMediumDifficultyDescription() {
        let difficulty = AIDifficulty.medium

        #expect(difficulty.description == "Builds sequences and blocks opponents. A good challenge!")
    }

    @Test("Hard difficulty has correct description")
    func testHardDifficultyDescription() {
        let difficulty = AIDifficulty.hard

        #expect(difficulty.description == "Strategic and challenging. Will try to win!")
    }

    @Test("Easy difficulty has correct thinking delay")
    func testEasyDifficultyThinkingDelay() {
        let difficulty = AIDifficulty.easy

        #expect(difficulty.thinkingDelay == 0.5)
    }

    @Test("Medium difficulty has correct thinking delay")
    func testMediumDifficultyThinkingDelay() {
        let difficulty = AIDifficulty.medium

        #expect(difficulty.thinkingDelay == 1.0)
    }

    @Test("Hard difficulty has correct thinking delay")
    func testHardDifficultyThinkingDelay() {
        let difficulty = AIDifficulty.hard

        #expect(difficulty.thinkingDelay == 1.5)
    }

    @Test("AIDifficulty is case iterable")
    func testAIDifficultyCaseIterable() {
        let allCases = AIDifficulty.allCases

        #expect(allCases.count == 3)
        #expect(allCases.contains(.easy))
        #expect(allCases.contains(.medium))
        #expect(allCases.contains(.hard))
    }

    @Test("AIDifficulty is codable")
    func testAIDifficultyCodable() throws {
        let difficulty = AIDifficulty.medium
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let encoded = try encoder.encode(difficulty)
        let decoded = try decoder.decode(AIDifficulty.self, from: encoded)

        #expect(decoded == .medium)
    }
}
