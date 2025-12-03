//
//  Player.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 23/10/2025.
//

import Foundation

struct Player: Codable, Identifiable {
    var id = UUID()
    var name: String
    let team: Team
    var isPlaying: Bool = false
    var cards: [Card] = []
    
    // NEW: AI support
   var isAI: Bool = false
    var aiDifficulty: AIDifficulty?
}

// Add this to Player.swift
extension Player {
    /// Creates an AI player with the specified difficulty
    static func aiPlayer(name: String, team: Team, difficulty: AIDifficulty) -> Player {
        return Player(
            name: name,
            team: team,
            isPlaying: false,
            cards: [],
            isAI: true,
            aiDifficulty: difficulty
        )
    }
}
