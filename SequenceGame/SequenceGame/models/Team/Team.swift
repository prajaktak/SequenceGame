//
//  Team.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 23/10/2025.
//

import Foundation

struct Team: Codable, Identifiable {
    var id = UUID()
    var color: TeamColor
    var numberOfPlayers: Int
}
