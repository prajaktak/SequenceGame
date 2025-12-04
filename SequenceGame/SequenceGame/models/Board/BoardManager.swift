//
//  BoardManager.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 17/11/2025.
//
import Foundation

/// Manages board state and tile operations.
///
/// `BoardManager` is responsible for:
/// - Setting up the game board with cards from a seeding deck
/// - Placing chips on tiles
/// - Removing chips with sequence protection logic
///
/// This manager is used by `GameState` to handle all board-related mutations.
final class BoardManager {
    
    /// Sets up a new board using two shuffled decks (excluding Jacks).
    ///
    /// Creates a temporary DoubleDeck specifically for board seeding. This deck is separate
    /// from the gameplay deck and is discarded after board setup. Jacks are intentionally
    /// excluded from the board per game rules.
    ///
    /// The 10x10 board has:
    /// - 4 corner tiles marked as empty (free spaces)
    /// - 96 tiles populated with cards (no Jacks)
    ///
    /// - Returns: A 2D array of `BoardTile` representing the initialized game board.
    func setupBoard() -> [[BoardTile]] {
        var newTiles: [[BoardTile]] = []
        
        // Create a temporary deck solely for board seeding (separate from gameplay deck)
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
    
    /// Places a chip at the specified position on the board.
    ///
    /// Creates a new `Chip` with the provided team color and marks the tile as occupied.
    ///
    /// - Parameters:
    ///   - position: The board position where the chip should be placed
    ///   - teamColor: The color representing the team placing the chip
    ///   - tiles: The 2D board tile array to mutate (passed as `inout`)
    func placeChip(at position: Position, teamColor: TeamColor, tiles: inout [[BoardTile]]) {
        guard position.isValid(rows: tiles.count, cols: tiles[0].count) else { return }
        
        tiles[position.row][position.col].isChipOn = true
        tiles[position.row][position.col].chip = Chip(
            color: teamColor,
            positionRow: position.row,
            positionColumn: position.col,
            isPlaced: true
        )
    }
    
    /// Removes a chip from the specified position, respecting sequence protection.
    ///
    /// Chips that are part of a completed sequence cannot be removed (they are "protected").
    /// Corner positions also cannot have chips removed.
    ///
    /// - Parameters:
    ///   - position: The board position to remove the chip from
    ///   - tiles: The 2D board tile array to mutate (passed as `inout`)
    ///   - detectedSequences: Array of all completed sequences used to determine protection
    ///
    /// - Returns: `true` if the chip was removed, `false` if the position is protected or invalid
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
