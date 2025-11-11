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
    
    func isCornerTile(atPosition: (rowIndex: Int, columnIndex: Int)) -> Bool {
        return GameConstants.cornerPositions.contains { $0.row == atPosition.rowIndex && $0.col == atPosition.columnIndex }
    }
}
