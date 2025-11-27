//
//  GameState.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 29/10/2025.
//

import Foundation

/// The authoritative source of truth for all game state and logic.
///
/// `GameState` manages the complete lifecycle of a Sequence game, including:
/// - Player and team configuration
/// - Board setup and tile state
/// - Card deck and hand management
/// - Turn progression
/// - Chip placement and removal
/// - Sequence detection and win conditions
///
/// All game views observe this object via `@EnvironmentObject` to stay synchronized
/// with the current game state. Mutation methods handle game rules enforcement,
/// validation, and state transitions.
final class GameState: ObservableObject {
    
    // MARK: - Published State
    
    /// All players in the game, in turn order. This is the single source of truth for player data.
    @Published var players: [Player] = []
    
    /// Index of the current player in the `players` array.
    @Published var currentPlayerIndex: Int = 0
    
    /// Current overlay display mode (turn start, card selected, dead card, game over).
    @Published var overlayMode: GameOverlayMode = .turnStart
    
    /// The game board structure (10x10 grid metadata).
    @Published var board = Board()
    
    /// The 2D array of board tiles containing cards and chip state.
    ///
    /// Auto-syncs changes to `board` and `sequenceDetector` via `didSet` to maintain consistency.
    @Published var boardTiles: [[BoardTile]] = Board().boardTiles {
        didSet {
            // Auto-sync board and sequenceDetector whenever boardTiles changes
            board.boardTiles = boardTiles
            sequenceDetector.board = board
        }
    }
    
    /// UUID of the currently selected card in the active player's hand, if any.
    @Published var selectedCardId: UUID?
    
    /// The sequence detection engine that scans for completed sequences.
    @Published var sequenceDetector: SequenceDetector = SequenceDetector(board: Board())
    
    /// All detected sequences on the board. Used for win condition checks and chip protection.
    @Published var detectedSequence: [Sequence] = [] {
        didSet {
            // Update cached set for O(1) sequence membership lookups
            updateTilesInSequencesCache()
        }
    }
    
    /// Cached set of tile IDs that are part of any detected sequence.
    ///
    /// Provides O(1) lookup performance for sequence membership checks instead of O(n×m)
    /// nested array searches. Auto-updated via `detectedSequence.didSet`.
    ///
    /// Used by views to efficiently determine if a tile should display sequence highlighting.
    @Published private(set) var tilesInSequences: Set<UUID> = []
    
    /// The winning team's color, set when a team achieves the required number of sequences.
    @Published var winningTeam: TeamColor?
    
    /// Convenience computed property indicating whether a card is currently selected.
    var hasSelection: Bool { selectedCardId != nil }

    // MARK: - Private State
    
    /// The gameplay deck used for dealing and drawing cards during the game.
    ///
    /// This is separate from the temporary deck used for board seeding.
    private(set) var deck: DoubleDeck = .init()
    
    /// Manager responsible for board setup and chip operations.
    private let boardManager = BoardManager()
    
    // MARK: - Computed Properties
    
    /// The player whose turn it currently is, derived from `currentPlayerIndex`.
    ///
    /// Returns `nil` if the index is out of bounds (shouldn't happen in normal gameplay).
    var currentPlayer: Player? {
        guard players.indices.contains(currentPlayerIndex) else { return nil }
        return players[currentPlayerIndex]
    }
    
    /// Returns the required number of sequences to win based on game configuration.
    ///
    /// According to game rules:
    /// - 2 players: 2 sequences required
    /// - 3+ players: 1 sequence required
    var requiredSequencesToWin: Int {
        let playerCount = players.count
        
        if playerCount == 2 {
            return 2
        } else {
            return 1  // 3, 4, 6, 8, 9, 10, 12 players all need 1 sequence
        }
    }

    // MARK: - Game Lifecycle
    
    /// Starts a new game with the provided players.
    ///
    /// Resets all game state, shuffles and deals cards, sets up the board, and transitions
    /// to the first turn.
    ///
    /// - Parameter players: Array of players in turn order, typically interleaved by team.
    func startGame(with players: [Player]) {
        // Reset win state
        winningTeam = nil
        detectedSequence = []
        tilesInSequences = []  // Clear sequence cache
        
        self.players = players
        currentPlayerIndex = 0

        // Shuffle deck and deal
        deck.resetDeck()
        deck.shuffle()
        setupBoard()

        let handCount = GameConstants.cardsPerPlayer(playerCount: players.count)
        deck.deal(handCount: handCount, to: &self.players)
        
        sequenceDetector.board = board
        overlayMode = .turnStart
    }
    
    /// Sets up the 10x10 game board using a temporary seeding deck.
    ///
    /// Populates all non-corner tiles with cards (excluding Jacks per game rules).
    /// Called once during game start.
    func setupBoard() {
        boardTiles = boardManager.setupBoard()
        board = Board(row: 10, col: 10)
    }
    /// Completely resets all game state to initial values.
    ///
    /// Use this when returning to game settings or starting a completely new game.
    /// For restarting with the same players, use `restartGame()` instead.
    func resetGame() {
        // Clear all game state
        players = []
        currentPlayerIndex = 0
        selectedCardId = nil
        winningTeam = nil
        detectedSequence = []
        tilesInSequences = []
        overlayMode = .turnStart
        
        // Reset board
        board = Board()
        boardTiles = Board().boardTiles
        
        // Reset deck
        deck = DoubleDeck()
    }
    /// Restarts the game with the same player configuration.
    ///
    /// Preserves player names, teams, and player count, but resets all game progress.
    /// Used for "Play Again" and "Restart" features.
    func restartGame() throws {
        // Guard: Cannot restart with no players
        guard !players.isEmpty else {
            throw GameStateError.cannotRestartWithoutPlayers
        }
        // Save current player configuration (names and teams)
        let savedPlayers = players.map { player in
            Player(
                name: player.name,
                team: player.team,
                isPlaying: false,
                cards: []
            )
        }
        
        // Reset all game state
        resetGame()
        
        // Start new game with saved players
        startGame(with: savedPlayers)
    }
    
    // MARK: - Turn Control
    
    /// Advances to the next player's turn.
    ///
    /// Wraps around to the first player after the last player. Resets overlay mode to `.turnStart`.
    func advanceTurn() {
        guard !players.isEmpty else { return }
        AudioManager.shared.play(sound: .turnChange, haptic: .selection)
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        overlayMode = .turnStart
    }
    
    // MARK: - Card Selection
    
    /// Selects a card from the current player's hand.
    ///
    /// Sets the selected card ID and updates overlay mode based on whether the card can be played.
    /// If no valid positions exist for the card, displays a dead card overlay.
    ///
    /// - Parameter cardId: The UUID of the card to select from the current player's hand.
    func selectCard(_ cardId: UUID) {
        // Prevent card selection when game is over
        guard overlayMode != .gameOver else { return }
        
        AudioManager.shared.play(sound: .cardSelect, haptic: .light)
        selectedCardId = cardId
        // Trigger overlay for dead card if no valid positions
        if validPositionsForSelectedCard.isEmpty {
            overlayMode = .deadCard
        } else {
            overlayMode = .cardSelected
        }
    }
    
    var validPositionsForSelectedCard: [(row: Int, col: Int)] {
        guard let card = selectedCard else { return [] }
        return computePlayableTiles(for: card)
    }
    
    func replaceDeadCard(_ cardId: UUID) {
        guard let playerIndex = players.firstIndex(where: { $0.id == currentPlayer?.id }),
              let handIndex = players[playerIndex].cards.firstIndex(where: { $0.id == cardId }) else { return }

        // Discard the dead card
        _ = players[playerIndex].cards.remove(at: handIndex)

        // Draw replacement (excluding Jacks if available in Deck)
        if let replacement = deck.drawCard() {
            players[playerIndex].cards.append(replacement)
        }

        // Clear selection after replacement to avoid stale selection state
        clearSelection()
        // After replacement, return to selection mode for the same player
        overlayMode = .turnStart
    }

    /// Convenience for UI to replace the currently selected dead card
    func replaceCurrentlySelectedDeadCard() {
        guard let id = selectedCardId else { return }
        replaceDeadCard(id)
    }
    // MARK: - Placement API (stubs)
    
    /// Helper function to detect protected tiles in sequence.
    private func isPartOfCompletedSequence(position: (row: Int, col: Int)) -> Bool {
        let pos = Position(row: position.row, col: position.col)
        guard pos.isValid(rows: boardTiles.count, cols: boardTiles[0].count) else { return false }
        let tile = boardTiles[pos.row][pos.col]
        return detectedSequence.contains { sequence in
            sequence.tiles.contains { $0.id == tile.id }
        }
    }
    
    func computePlayableTiles(for card: Card) -> [(row: Int, col: Int)] {
        let validator = CardPlayValidator(boardTiles: boardTiles, detectedSequences: detectedSequence)
        return validator.computePlayableTiles(for: card).map { (row: $0.row, col: $0.col) }
    }

    func canPlace(at position: (row: Int, col: Int), for card: Card) -> Bool {
        let validator = CardPlayValidator(boardTiles: boardTiles, detectedSequences: detectedSequence)
        let pos = Position(row: position.row, col: position.col)
        return validator.canPlace(at: pos, for: card)
    }
    // Sets a chip at the given position. No hand/turn changes.
    func placeChip(at position: (row: Int, col: Int), teamColor: TeamColor) {
        let pos = Position(row: position.row, col: position.col)
        AudioManager.shared.play(sound: .chipPlace, haptic: .medium)
        boardManager.placeChip(at: pos, teamColor: teamColor, tiles: &boardTiles)
    }
    
    /// Removes a chip from the given position. No hand/turn changes.
    func removeChip(at position: (row: Int, col: Int)) {
        let pos = Position(row: position.row, col: position.col)
        _ = boardManager.removeChip(at: pos, tiles: &boardTiles, detectedSequences: detectedSequence)
    }
 
    //  Remove card from current players hand
    private func removeCardFromHand(cardId: UUID) -> Card? {
        let playerIndex = currentPlayerIndex
        guard let handIndex = players[playerIndex].cards.firstIndex(where: { $0.id == cardId }) else { return nil }
        return players[playerIndex].cards.remove(at: handIndex)
    }
    
    // Draw card for current playes hand
    private func drawReplacementForHand() {
        guard let playerIndex = players.firstIndex(where: { $0.id == currentPlayer?.id }),
              let drawn = deck.drawCard() else { return }
        players[playerIndex].cards.append(drawn)
    }

    #if DEBUG
    // Test helpers (only in debug builds)
    func testRemoveCardFromHand(cardId: UUID) -> Card? {
        return removeCardFromHand(cardId: cardId)
    }

    func testDrawReplacementForHand() {
        drawReplacementForHand()
    }
    #endif
    
    // MARK: - Core Gameplay
    
    /// Performs a complete play action: validates, executes, detects sequences, and advances turn.
    ///
    /// This is the main entry point for card plays. It orchestrates the full turn sequence:
    /// 1. Removes the played card from the current player's hand
    /// 2. Validates the placement using `CardPlayValidator`
    /// 3. Executes the play (place chip for normal cards, remove chip for one-eyed Jacks)
    /// 4. Detects new sequences and checks win conditions
    /// 5. Draws a replacement card
    /// 6. Advances to the next turn
    ///
    /// - Parameters:
    ///   - position: The board position (row, col) where the card is being played
    ///   - cardId: The UUID of the card being played from the current player's hand
    func performPlay(atPos position: (row: Int, col: Int), using cardId: UUID) {
        guard overlayMode != .gameOver else { return }
        
        // Create validator once
        let validator = CardPlayValidator(boardTiles: boardTiles, detectedSequences: detectedSequence)
        
        // 1) Remove the card from current player's hand
        guard let playedCard = removeCardFromHand(cardId: cardId) else { return }

        // 2) Validate placement for the played card
        let pos = Position(row: position.row, col: position.col)
        guard validator.canPlace(at: pos, for: playedCard) else {
            players[currentPlayerIndex].cards.append(playedCard)
            return
        }

        // 3) Check if this is a one-eyed jack (remove chip) or regular/two-eyed jack (place chip)
        if let jackRule = validator.classifyJack(playedCard), jackRule == .removeChip {
            // One-eyed jack: remove chip
            removeChip(at: position)
        } else {
            // Regular card or two-eyed jack: place chip
            guard let teamColor = currentPlayer?.team.color else {
                players[currentPlayerIndex].cards.append(playedCard)
                return
            }
            placeChip(at: position, teamColor: teamColor)
        }
        
        // 3.1) Check if sequence is completed && check winning condition
        if !(validator.classifyJack(playedCard) == .removeChip) {            // Only check sequences after chip placement (not removal)
            let previousSequenceCount = detectedSequence.count
            // Detect sequences at the placed position
            var detector = sequenceDetector
            _ = detector.detectSequence(
                atPosition: (rowIndex: position.row, colIndex: position.col),
                forPlayer: players[currentPlayerIndex],
                gameState: self
            )
            sequenceDetector = detector
            let newSequenceCount = detectedSequence.count
           
            // Check win condition
            let gameResult = evaluateGameState()
            switch gameResult {
            case .win(let teamColor):
                overlayMode = .gameOver
                // Store winning team for UI display
                winningTeam = teamColor
                // Play win sound and success haptic
                AudioManager.shared.play(sound: .gameWin, haptic: .success)
            case .ongoing:
                if newSequenceCount > previousSequenceCount {
                    AudioManager.shared.play(sound: .sequenceComplete, haptic: .heavy)
                }
                break // Continue game
            }
        }
        //  This guard to prevent drawing and advancing turn after win
        guard overlayMode != .gameOver else { return }
        
        // 4) Draw replacement
        drawReplacementForHand()
        
        // 5) Advance turn
        advanceTurn()
        
        clearSelection()
    }
    var selectedCard: Card? {
        guard let selectedId = selectedCardId,
              let playerIndex = players.firstIndex(where: { $0.id == currentPlayer?.id }) else { return nil }
        return players[playerIndex].cards.first(where: { $0.id == selectedId })
    }
    
    func clearSelection() {
        selectedCardId = nil
    }
    
    /// Returns the number of sequences completed by a specific team
    func sequencesForTeam(teamColor: TeamColor) -> Int {
        detectedSequence.filter { $0.teamColor == teamColor }.count
    }
    
    /// Evaluates the current game state and returns win or ongoing result
    func evaluateGameState() -> GameResult {
        
        let requiredSequences = requiredSequencesToWin
        let uniqueTeamColors = Set(players.map { $0.team.color })
        
        // Check each team's sequence count
        for teamColor in uniqueTeamColors {
            let teamSequenceCount = sequencesForTeam(teamColor: teamColor)
            if teamSequenceCount >= requiredSequences {
                winningTeam = teamColor
                return .win(team: teamColor)
            }
        }
        
        // No team has won yet
        winningTeam = nil
        return .ongoing
    }
    
    // MARK: - Performance Optimization
    
    /// Updates the cached set of tile IDs that are part of detected sequences.
    ///
    /// This is called automatically via `detectedSequence.didSet` to maintain a flattened
    /// Set for O(1) membership lookups. Without this cache, checking if a tile is in a
    /// sequence requires O(n×m) nested array searches (n sequences × m tiles per sequence).
    ///
    /// **Performance Impact:**
    /// - Before: `isTileInSequence()` = O(n×m) per tile × 100 tiles = expensive
    /// - After: `isTileInSequence()` = O(1) per tile × 100 tiles = fast
    private func updateTilesInSequencesCache() {
        tilesInSequences = Set(detectedSequence.flatMap { sequence in
            sequence.tiles.map { $0.id }
        })
    }

        // MARK: - Persistence
    
    /// Restores game state from a saved snapshot.
    ///
    /// This method updates all published properties from the snapshot data,
    /// triggering UI updates via the `@Published` property wrappers.
    ///
    /// - Parameter snapshot: The saved game state snapshot to restore from
    func restore(from snapshot: GameStateSnapshot) {
        // Restore all game state properties
        self.players = snapshot.players
        self.currentPlayerIndex = snapshot.currentPlayerIndex
        self.overlayMode = snapshot.overlayMode
        self.board = snapshot.board
        self.boardTiles = snapshot.boardTiles
        self.selectedCardId = snapshot.selectedCardId
        self.sequenceDetector = snapshot.sequenceDetector
        self.detectedSequence = snapshot.detectedSequence
        self.tilesInSequences = snapshot.tilesInSequences
        self.winningTeam = snapshot.winningTeam
        self.deck = snapshot.deck
        
        // Ensure sequence detector's board reference is updated
        sequenceDetector.board = board
    }
        
}
