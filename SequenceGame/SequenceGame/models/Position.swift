//
//  Position.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 17/11/2025.
//

import Foundation

struct Position: Codable, Equatable, Hashable {
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
    func directionUp() -> Position {
        //  (-1, 0),  // up
        return Position(row: row - 1, col: self.col)
    }
    func directionDown() -> Position {
        // (1, 0),   // down
        return Position(row: row + 1, col: self.col)
    }
    func directionLeft() -> Position {
        // (0, -1),  // left
        return Position(row: row, col: self.col - 1)
    }
    func directionRight() -> Position {
        // (0, 1),   // right
        return Position(row: row, col: self.col + 1)
    }
    func directionUpLeft() -> Position {
        // (-1, -1), // up-left
        return Position(row: row - 1, col: self.col - 1)
    }
    func directionUpRight() -> Position {
        // (-1, 1),  // up-right
        return Position(row: row - 1, col: self.col + 1)
    }
    func directionDownLeft() -> Position {
        // (1, -1),  // down-left
        return Position(row: row + 1, col: self.col - 1)
    }
    func directionDownRight() -> Position {
        // (1, 1)    // down-right
        return Position(row: row + 1, col: self.col + 1)
    }
    
}
