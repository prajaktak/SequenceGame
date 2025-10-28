//
//  Move.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 23/10/2025.
//

import Foundation

struct Move: Identifiable {
    var id = UUID()
    var player: Player
    var positionRow: Int
    var positionColumn: Int
    var team: Team
}
