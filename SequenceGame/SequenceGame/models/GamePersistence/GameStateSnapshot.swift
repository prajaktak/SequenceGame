//
//  GameStateSnapshot.swift
//  SequenceGame
//
//  Created on [today's date]
//

import Foundation

/// A codable snapshot of the current game state for persistence.
///
/// This struct contains only the essential game data needed to save and resume a game.
/// Utility objects like `BoardManager` are not saved and will be recreated on load.
struct GameStateSnapshot: Codable {
    // Properties will go here
        // MARK: - Game State
    
    /// All players in the game, in turn order
    let players: [Player]
    
    /// Index of the current player
    let currentPlayerIndex: Int
    
    /// Current overlay display mode
    let overlayMode: GameOverlayMode
    
    // MARK: - Board State
    
    /// The game board structure
    let board: Board
    
    /// The 2D array of board tiles
    let boardTiles: [[BoardTile]]
    
    // MARK: - Card Selection
    
    /// UUID of the currently selected card, if any
    let selectedCardId: UUID?
    
    // MARK: - Sequence Detection
    
    /// The sequence detection engine state
    let sequenceDetector: SequenceDetector
    
    /// All detected sequences on the board
    let detectedSequence: [Sequence]
    
    /// Cached set of tile IDs in sequences
    let tilesInSequences: Set<UUID>
    
    // MARK: - Win State
    
    /// The winning team's color, if any
    let winningTeam: TeamColor?
    
    // MARK: - Deck State
    
    /// The gameplay deck state
    let deck: DoubleDeck

        // MARK: - Initialization
    
    /// Creates a snapshot from the current GameState.
    ///
    /// - Parameter gameState: The GameState instance to snapshot
    init(from gameState: GameState) {
        self.players = gameState.players
        self.currentPlayerIndex = gameState.currentPlayerIndex
        self.overlayMode = gameState.overlayMode
        self.board = gameState.board
        self.boardTiles = gameState.boardTiles
        self.selectedCardId = gameState.selectedCardId
        self.sequenceDetector = gameState.sequenceDetector
        self.detectedSequence = gameState.detectedSequence
        self.tilesInSequences = gameState.tilesInSequences
        self.winningTeam = gameState.winningTeam
        self.deck = gameState.deck
    }
}
