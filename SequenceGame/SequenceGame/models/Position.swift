//
//  Position.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 17/11/2025.
//

import Foundation

struct Position: Equatable, Hashable {
    let row: Int
    let col: Int
    
    init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
    
    /// Check if this position is a corner tile
    var isCorner: Bool {
        GameConstants.cornerPositions.contains { $0.row == row && $0.col == col }
    }
    
    /// Check if position is within board bounds
    func isValid(rows: Int, cols: Int) -> Bool {
        return (0..<rows).contains(row) && (0..<cols).contains(col)
    }
}
