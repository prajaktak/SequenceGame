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
}
