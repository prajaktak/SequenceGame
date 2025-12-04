//
//  Sequence.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 11/11/2025.
//

import Foundation

struct Sequence: Codable, Identifiable {
    var id = UUID()
    var tiles: [BoardTile]
    var position: Position
    var teamColor: TeamColor
    var sequenceType: SequenceType
}
