//
//  CardPlayValidator.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 17/11/2025.
//

import Foundation

/// Validates card placement rules and computes valid board positions for card plays.
///
/// `CardPlayValidator` implements the core game rules for card placement, including:
/// - Regular card matching (rank + suit)
/// - Two-eyed Jack wild card rules (clubs/diamonds)
/// - One-eyed Jack removal rules (hearts/spades)
/// - Sequence protection (chips in sequences can't be removed)
/// - Corner tile handling (free spaces)
///
/// ## Game Rules Implemented
///
/// ### Regular Cards
/// - Must match **both** the card face (rank) and suit on the board
/// - Can only be played on unoccupied matching tiles
/// - Cannot be played on corners (they have no cards)
///
/// ### Two-Eyed Jacks (Wild Cards)
/// - **Jack of Clubs** or **Jack of Diamonds**
/// - Can be played on **any** empty non-corner tile
/// - Acts as a wild card to place a chip anywhere
///
/// ### One-Eyed Jacks (Chip Removal)
/// - **Jack of Hearts** or **Jack of Spades**
/// - Removes **opponent chips** from any unprotected tile
/// - Cannot remove chips that are part of completed sequences
/// - Cannot remove chips from corner tiles
///
/// ## Usage Example
///
/// ```swift
/// let validator = CardPlayValidator(
///     boardTiles: gameState.boardTiles,
///     detectedSequences: gameState.detectedSequence
/// )
///
/// // Get all valid positions for a card
/// let validPositions = validator.computePlayableTiles(for: card)
///
/// // Check if specific position is valid
/// let canPlay = validator.canPlace(at: position, for: card)
/// ```
struct CardPlayValidator {
    /// The current board state (2D array of tiles)
    let boardTiles: [[BoardTile]]
    
    /// All detected sequences (used to determine chip protection)
    let detectedSequences: [Sequence]
    
    // MARK: - Public API
    
    /// Computes all valid board positions where the given card can be played.
    ///
    /// This is the main entry point for determining valid moves. It handles all three
    /// card types (regular cards, two-eyed Jacks, one-eyed Jacks) and returns an array
    /// of positions where the card can legally be played.
    ///
    /// - Parameter card: The card to find valid positions for
    /// - Returns: An array of `Position` objects representing valid board coordinates
    ///
    /// ## Return Values
    ///
    /// - **Regular cards**: Positions matching card face AND suit (unoccupied)
    /// - **Two-eyed Jacks**: All empty non-corner tiles
    /// - **One-eyed Jacks**: All unprotected opponent chips
    ///
    /// ## Example
    ///
    /// ```swift
    /// let card = Card(cardFace: .queen, suit: .hearts)
    /// let positions = validator.computePlayableTiles(for: card)
    /// // Returns: [(row: 2, col: 3), (row: 7, col: 5)] - all Queen of Hearts positions
    /// ```
    ///
    /// - Complexity: O(n²) where n is the board dimension (100 iterations for 10x10 board)
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
    
    /// Validates whether a specific position is playable for the given card.
    ///
    /// This is a convenience method that checks if a position exists in the array
    /// returned by `computePlayableTiles(for:)`.
    ///
    /// - Parameters:
    ///   - position: The board position to validate
    ///   - card: The card being played
    /// - Returns: `true` if the card can be played at the position, `false` otherwise
    ///
    /// ## Example
    ///
    /// ```swift
    /// let position = Position(row: 5, col: 5)
    /// let card = Card(cardFace: .king, suit: .spades)
    ///
    /// if validator.canPlace(at: position, for: card) {
    ///     // Valid move - place chip
    /// } else {
    ///     // Invalid move - reject play
    /// }
    /// ```
    ///
    /// - Complexity: O(n²) due to calling `computePlayableTiles(for:)`
    func canPlace(at position: Position, for card: Card) -> Bool {
        return computePlayableTiles(for: card).contains(position)
    }
    
    // MARK: - Private Card Type Handlers
    
    /// Finds all valid positions for regular (non-Jack) cards.
    ///
    /// Regular cards must match **both** the card face (rank) and suit on the board tile.
    /// Only unoccupied tiles are considered valid.
    ///
    /// - Parameter card: The regular card to find positions for
    /// - Returns: Array of positions where the card face and suit both match
    ///
    /// ## Matching Rules
    ///
    /// A tile is valid if:
    /// 1. It has a card (not a corner)
    /// 2. It's not occupied by a chip
    /// 3. The tile's card face matches the played card's face
    /// 4. The tile's suit matches the played card's suit
    ///
    /// ## Example
    ///
    /// ```
    /// Card to play: 7 of Diamonds
    /// Board has:
    ///   - Tile at (2,3): 7 of Diamonds, no chip → VALID ✅
    ///   - Tile at (5,5): 7 of Diamonds, has chip → INVALID ❌
    ///   - Tile at (8,1): 7 of Hearts, no chip → INVALID ❌ (suit mismatch)
    /// ```
    ///
    /// - Complexity: O(n²) for full board scan
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
    
    /// Finds all valid positions for two-eyed Jacks (wild cards).
    ///
    /// Two-eyed Jacks (Jack of Clubs and Jack of Diamonds) can be played on **any**
    /// empty non-corner tile, acting as wild cards.
    ///
    /// - Returns: Array of all empty, non-corner positions on the board
    ///
    /// ## Wild Card Rules
    ///
    /// A tile is valid if:
    /// 1. It's **not** a corner position
    /// 2. It doesn't have a chip placed on it
    /// 3. The chip property is `nil` (double-check for safety)
    ///
    /// ## Example
    ///
    /// ```
    /// Two-eyed Jack played:
    /// Board (10x10 = 100 tiles):
    ///   - Corner tiles: 4 → INVALID ❌
    ///   - Occupied tiles: 20 → INVALID ❌
    ///   - Empty non-corners: 76 → VALID ✅
    /// Returns: 76 positions
    /// ```
    ///
    /// - Complexity: O(n²) for full board scan
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
    
    /// Finds all valid positions for one-eyed Jacks (chip removal).
    ///
    /// One-eyed Jacks (Jack of Hearts and Jack of Spades) can remove **opponent chips**
    /// from any tile **except** those that are part of completed sequences or corners.
    ///
    /// - Returns: Array of positions with removable chips (unprotected opponents)
    ///
    /// ## Removal Rules
    ///
    /// A chip is removable if:
    /// 1. The tile is **not** a corner
    /// 2. The tile **has** a chip placed on it
    /// 3. The chip is **not** part of a completed sequence (protected)
    ///
    /// ## Sequence Protection
    ///
    /// Chips in completed 5-in-a-row sequences are **protected** and cannot be removed.
    /// This is a core game rule to prevent disrupting winning sequences.
    ///
    /// ## Example
    ///
    /// ```
    /// One-eyed Jack played:
    /// Board:
    ///   - Tile (2,3): Blue chip, no sequence → REMOVABLE ✅
    ///   - Tile (5,5): Red chip, in sequence → PROTECTED ❌
    ///   - Tile (0,0): Corner with chip → INVALID ❌
    /// ```
    ///
    /// - Complexity: O(n² × m) where m is the number of detected sequences
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
    
    // MARK: - Jack Classification
    
    /// Classifies a Jack card by its special rule based on suit.
    ///
    /// Jack cards have special rules depending on which suit they are:
    /// - **Two-eyed Jacks** (Clubs, Diamonds): Wild cards that can be placed anywhere
    /// - **One-eyed Jacks** (Hearts, Spades): Remove opponent chips
    ///
    /// - Parameter card: The card to classify
    /// - Returns: A `JackRule` enum value if the card is a Jack, `nil` otherwise
    ///
    /// ## Jack Types
    ///
    /// | Suit | Eyes | Rule | Behavior |
    /// |------|------|------|----------|
    /// | ♣ Clubs | Two | `.placeAnywhere` | Wild card |
    /// | ♦ Diamonds | Two | `.placeAnywhere` | Wild card |
    /// | ♠ Spades | One | `.removeChip` | Remove opponent chip |
    /// | ♥ Hearts | One | `.removeChip` | Remove opponent chip |
    ///
    /// ## Real-World Context
    ///
    /// In traditional playing card imagery:
    /// - **Two-eyed Jacks** show both eyes in profile (Clubs, Diamonds)
    /// - **One-eyed Jacks** show only one eye in profile (Hearts, Spades)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let jackOfClubs = Card(cardFace: .jack, suit: .clubs)
    /// let rule = validator.classifyJack(jackOfClubs)
    /// // rule = .placeAnywhere (two-eyed Jack)
    ///
    /// let queenOfHearts = Card(cardFace: .queen, suit: .hearts)
    /// let noRule = validator.classifyJack(queenOfHearts)
    /// // noRule = nil (not a Jack)
    /// ```
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
