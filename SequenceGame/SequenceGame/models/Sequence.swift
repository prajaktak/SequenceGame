//
//  Sequence.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 11/11/2025.
//

import Foundation
import SwiftUI

struct Sequence: Identifiable {
    var id = UUID()
    var tiles: [BoardTile]
    var position: (row: Int, col: Int)
    var teamColor: Color
    var sequenceType: SequenceType
}
