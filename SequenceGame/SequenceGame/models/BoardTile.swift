//
//  BoardTile.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 22/10/2025.
//
import Foundation

struct BoardTile: Identifiable {
    let id = UUID()
    var card: Card?
    var isEmpty: Bool
    var isChipOn: Bool
    var chip: Chip?
    
//    static func isCornerTile(at position: (row: Int, col: Int)) -> Bool {
//        return GameConstants.cornerPositions.contains { $0.row == position.row && $0.col == position.col }
//    }
}
