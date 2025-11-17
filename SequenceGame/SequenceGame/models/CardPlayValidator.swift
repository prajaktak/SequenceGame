//
//  CardPlayValidator.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 17/11/2025.
//

import Foundation

/// Validates card plays and computes valid positions
struct CardPlayValidator {
    let boardTiles: [[BoardTile]]
    let detectedSequences: [Sequence]
    
    /// Computes all playable board positions for a given card
    func computePlayableTiles(for card: Card) -> [Position] {
        // Handle Jack cards with special rules
        if let jackRule = classifyJack(card) {
            switch jackRule {
            case .placeAnywhere:
                return computePlayableTilesForTwoEyedJack()
            case .removeChip:
                return computePlayableTilesForOneEyedJack()
            }
        }
        
        // Regular card matching: match by cardFace and suit
        return computePlayableTilesForRegularCard(card)
    }
    
    /// Validates if a position is playable for the given card
    func canPlace(at position: Position, for card: Card) -> Bool {
        return computePlayableTiles(for: card).contains(position)
    }
    
    // MARK: - Private Helpers
    
    private func computePlayableTilesForRegularCard(_ card: Card) -> [Position] {
        var positions: [Position] = []
        
        for rowIndex in boardTiles.indices {
            for colIndex in boardTiles[rowIndex].indices {
                let tile = boardTiles[rowIndex][colIndex]
                guard tile.isChipOn == false,
                      let tileCard = tile.card else { continue }
                
                if tileCard.cardFace == card.cardFace && tileCard.suit == card.suit {
                    positions.append(Position(row: rowIndex, col: colIndex))
                }
            }
        }
        
        return positions
    }
    
    private func computePlayableTilesForTwoEyedJack() -> [Position] {
        var positions: [Position] = []
        
        for rowIndex in boardTiles.indices {
            for colIndex in boardTiles[rowIndex].indices {
                let position = Position(row: rowIndex, col: colIndex)
                let tile = boardTiles[rowIndex][colIndex]
                
                if !position.isCorner && !tile.isChipOn && tile.chip == nil {
                    positions.append(position)
                }
            }
        }
        
        return positions
    }
    
    private func computePlayableTilesForOneEyedJack() -> [Position] {
        var positions: [Position] = []
        
        for rowIndex in boardTiles.indices {
            for colIndex in boardTiles[rowIndex].indices {
                let position = Position(row: rowIndex, col: colIndex)
                let tile = boardTiles[rowIndex][colIndex]
                
                // Check if tile is part of a completed sequence
                let isProtected = detectedSequences.contains { sequence in
                    sequence.tiles.contains { $0.id == tile.id }
                }
                
                if !position.isCorner && tile.isChipOn && tile.chip != nil && !isProtected {
                    positions.append(position)
                }
            }
        }
        
        return positions
    }
    
    func classifyJack(_ card: Card) -> JackRule? {
        guard card.cardFace == .jack else { return nil }
        
        switch card.suit {
        case .clubs, .diamonds:
            return .placeAnywhere   // two-eyed
        case .spades, .hearts:
            return .removeChip      // one-eyed
        case .empty:
            return .removeChip
        }
    }
}
