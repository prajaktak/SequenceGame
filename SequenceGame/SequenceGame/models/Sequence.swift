//
//  Sequence.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 11/11/2025.
//

import Foundation

struct Sequence: Identifiable {
    var id = UUID()
    var tiles: [BoardTile]
    var position: (row: Int, col: Int)
    var teamColor: TeamColor
    var sequenceType: SequenceType
}
