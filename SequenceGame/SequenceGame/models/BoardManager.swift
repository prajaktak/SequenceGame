//
//  BoardManager.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 17/11/2025.
//

import SwiftUI

/// Manages board state and tile operations
final class BoardManager {
    
    /// Sets up a new board using two shuffled decks (excluding Jacks)
    func setupBoard() -> [[BoardTile]] {
        var newTiles: [[BoardTile]] = []
        
        let seedDeck = DoubleDeck()
        seedDeck.shuffle()
        
        for row in 0..<GameConstants.boardRows {
            var rowTiles: [BoardTile] = []
            for col in 0..<GameConstants.boardColumns {
                let position = Position(row: row, col: col)
                
                if position.isCorner {
                    rowTiles.append(BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil))
                } else if let card = seedDeck.drawCardExceptJacks() {
                    rowTiles.append(BoardTile(card: card, isEmpty: false, isChipOn: false, chip: nil))
                } else {
                    rowTiles.append(BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil))
                }
            }
            newTiles.append(rowTiles)
        }
        
        return newTiles
    }
    
    /// Places a chip at the specified position
    func placeChip(at position: Position, teamColor: Color, tiles: inout [[BoardTile]]) {
        guard position.isValid(rows: tiles.count, cols: tiles[0].count) else { return }
        
        tiles[position.row][position.col].isChipOn = true
        tiles[position.row][position.col].chip = Chip(
            color: teamColor,
            positionRow: position.row,
            positionColumn: position.col,
            isPlaced: true
        )
    }
    
    /// Removes a chip from the specified position
    /// Returns true if chip was removed, false if position is protected
    func removeChip(at position: Position, tiles: inout [[BoardTile]], detectedSequences: [Sequence]) -> Bool {
        guard position.isValid(rows: tiles.count, cols: tiles[0].count) else { return false }
        guard !position.isCorner else { return false }
        
        // Check if tile is part of a completed sequence
        let tile = tiles[position.row][position.col]
        let isProtected = detectedSequences.contains { sequence in
            sequence.tiles.contains { $0.id == tile.id }
        }
        
        guard !isProtected else { return false }
        
        tiles[position.row][position.col].isChipOn = false
        tiles[position.row][position.col].chip = nil
        
        return true
    }
}
