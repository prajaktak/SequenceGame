//
//  GameState.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 29/10/2025.
//

import SwiftUI

final class GameState: ObservableObject {
    // Core state
    @Published var players: [Player] = []
    @Published var currentPlayerIndex: Int = 0
    @Published var overlayMode: GameOverlayMode = .turnStart
    @Published var board = Board()
    @Published var boardTiles: [[BoardTile]] = Board().boardTiles {
        didSet {
            // Auto-sync board and sequenceDetector whenever boardTiles changes
            board.boardTiles = boardTiles
            sequenceDetector.board = board
        }
    }
    @Published var selectedCardId: UUID?
    @Published var sequenceDetector: SequenceDetector = SequenceDetector(board: Board())
    @Published var detectedSequence: [Sequence] = []
    @Published var winningTeam: Color?
    var hasSelection: Bool { selectedCardId != nil }

    // Deck for gameplay
    private(set) var deck: DoubleDeck = .init()
    private let boardManager = BoardManager()
    
    // Derived
    var currentPlayer: Player? {
        guard players.indices.contains(currentPlayerIndex) else { return nil }
        return players[currentPlayerIndex]
    }
    
    /// Returns the required number of sequences to win based on game configuration
    var requiredSequencesToWin: Int {
        let playerCount = players.count
        
        // According to game rules:
        // - 2 players: 2 sequences
        // - 3+ players: 1 sequence
        if playerCount == 2 {
            return 2
        } else {
            return 1  // 3, 4, 6, 8, 9, 10, 12 players all need 1 sequence
        }
    }

    // Lifecycle
    func startGame(with players: [Player]) {
        // Reset win state
        winningTeam = nil
        detectedSequence = []
        
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
    
    func setupBoard() {
        boardTiles = boardManager.setupBoard()
        board = Board(row: 10, col: 10)
    }
    
    // Turn control
    func advanceTurn() {
        guard !players.isEmpty else { return }
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        overlayMode = .turnStart
    }
    
    // Select a card in current player's hand (by id)
    func selectCard(_ cardId: UUID) {
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
    func placeChip(at position: (row: Int, col: Int), teamColor: Color) {
        let pos = Position(row: position.row, col: position.col)
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
    
    // performPlay
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
            
            // Detect sequences at the placed position
            var detector = sequenceDetector
            _ = detector.detectSequence(
                atPosition: (rowIndex: position.row, colIndex: position.col),
                forPlayer: players[currentPlayerIndex],
                gameState: self
            )
            sequenceDetector = detector
            
            // Check win condition
            let gameResult = evaluateGameState()
            switch gameResult {
            case .win(let teamColor):
                overlayMode = .gameOver
                // Store winning team for UI display
                winningTeam = teamColor
            case .ongoing:
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
    func sequencesForTeam(teamColor: Color) -> Int {
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
        
}
