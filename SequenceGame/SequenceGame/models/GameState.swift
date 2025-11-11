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
    @Published var boardTiles: [[BoardTile]] = Board().boardTiles
    @Published var selectedCardId: UUID?
    @Published var sequenceDetector: SequenceDetector = SequenceDetector(board: Board(), currentLocation: (0, 0), forPlayer: Player(name: "no Player", team: Team(color: .blue, numberOfPlayers: 1)))
    @Published var detectedSequence: [Sequence] = []
    var hasSelection: Bool { selectedCardId != nil }

    // Deck for gameplay
    private(set) var deck: DoubleDeck = .init()
    
    // Derived
    var currentPlayer: Player? {
        guard players.indices.contains(currentPlayerIndex) else { return nil }
        return players[currentPlayerIndex]
    }

    // Lifecycle
    func startGame(with players: [Player]) {
        self.players = players
        currentPlayerIndex = 0

        // Shuffle deck and deal
        deck.resetDeck()
        deck.shuffle()
        setupBoard()

        let handCount = GameConstants.cardsPerPlayer(playerCount: players.count)
        deck.deal(handCount: handCount, to: &self.players)
        
        sequenceDetector.board = board
        sequenceDetector.currentLocation = (0, 0)
        sequenceDetector.forPlayer = players[currentPlayerIndex]

        overlayMode = .turnStart
    }
    
    func setupBoard() {
        var newTiles: [[BoardTile]] = []
        
        let seedDeck = DoubleDeck()
        seedDeck.shuffle()
        
        for row in 0..<GameConstants.boardRows {
            var rowTiles: [BoardTile] = []
            for col in 0..<GameConstants.boardColumns {
                if GameConstants.cornerPositions.contains(where: { $0.row == row && $0.col == col }) {
                    rowTiles.append(BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil))
                } else if let card = seedDeck.drawCardExceptJacks() {
                    rowTiles.append(BoardTile(card: card, isEmpty: false, isChipOn: false, chip: nil))
                } else {
                    rowTiles.append(BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil))
                }
            }
            newTiles.append(rowTiles)
        }
        boardTiles = newTiles
        board = Board(row: 10, col: 10)
        board.boardTiles = boardTiles
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
        guard let selectedId = selectedCardId,
              let playerIndex = players.firstIndex(where: { $0.id == currentPlayer?.id }),
              let card = players[playerIndex].cards.first(where: { $0.id == selectedId }) else { return [] }
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

    /// Return all playable board positions for a given card.
    func computePlayableTiles(for card: Card) -> [(row: Int, col: Int)] {
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
        var positions: [(row: Int, col: Int)] = []
        for rowIndex in boardTiles.indices {
            for colIndex in boardTiles[rowIndex].indices {
                let tile = boardTiles[rowIndex][colIndex]
                guard tile.isChipOn == false,
                      let tileCard = tile.card else { continue }
                if tileCard.cardFace == card.cardFace && tileCard.suit == card.suit {
                    positions.append((row: rowIndex, col: colIndex))
                }
            }
        }
        return positions
    }
    
    /// Return all empty, non-corner tiles for two-eyed jack placement.
    private func computePlayableTilesForTwoEyedJack() -> [(row: Int, col: Int)] {
        var positions: [(row: Int, col: Int)] = []
        for rowIndex in boardTiles.indices {
            for colIndex in boardTiles[rowIndex].indices {
                let isCorner = GameConstants.cornerPositions.contains { $0.row == rowIndex && $0.col == colIndex }
                let tile = boardTiles[rowIndex][colIndex]
                if !isCorner && !tile.isChipOn && tile.card != nil {
                    positions.append((row: rowIndex, col: colIndex))
                }
            }
        }
        return positions
    }
    
    /// Return all tiles with chips for one-eyed jack removal.
    /// Excludes corner positions (corners cannot have chips removed).
    private func computePlayableTilesForOneEyedJack() -> [(row: Int, col: Int)] {
        var positions: [(row: Int, col: Int)] = []
        for rowIndex in boardTiles.indices {
            for colIndex in boardTiles[rowIndex].indices {
                let isCorner = GameConstants.cornerPositions.contains { $0.row == rowIndex && $0.col == colIndex }
                let tile = boardTiles[rowIndex][colIndex]
                if !isCorner && tile.isChipOn && tile.chip != nil {
                    positions.append((row: rowIndex, col: colIndex))
                }
            }
        }
        return positions
    }
    /// Validate if position is playable for this card.
    func canPlace(at position: (row: Int, col: Int), for card: Card) -> Bool {
        computePlayableTiles(for: card).contains { $0 == position }
    }
    // Sets a chip at the given position. No hand/turn changes.
    func placeChip(at position: (row: Int, col: Int), teamColor: Color) {
        let row = position.row
        let col = position.col
        guard boardTiles.indices.contains(row),
              boardTiles[row].indices.contains(col) else { return }

        boardTiles[row][col].isChipOn = true
        boardTiles[row][col].chip = Chip(
            color: teamColor,
            positionRow: row,
            positionColumn: col,
            isPlaced: true
        )
    }
    
    /// Removes a chip from the given position. No hand/turn changes.
    func removeChip(at position: (row: Int, col: Int)) {
        let row = position.row
        let col = position.col
        guard boardTiles.indices.contains(row),
              boardTiles[row].indices.contains(col) else { return }
        if GameConstants.cornerPositions.contains(where: { $0.row == row && $0.col == col }) { return }
        
        boardTiles[row][col].isChipOn = false
        boardTiles[row][col].chip = nil
    }
    
    //  Remove card from current players hand
    func removeCardFromHand(cardId: UUID) -> Card? {
        guard let playerIndex = players.firstIndex(where: { $0.id == currentPlayer?.id }),
              let handIndex = players[playerIndex].cards.firstIndex(where: { $0.id == cardId }) else { return nil }
        return players[playerIndex].cards.remove(at: handIndex)
    }
    
    // Draw card for current playes hand
    func drawReplacementForHand() {
        guard let playerIndex = players.firstIndex(where: { $0.id == currentPlayer?.id }),
              let drawn = deck.drawCard() else { return }
        players[playerIndex].cards.append(drawn)
    }
    
    // performPlay
    func performPlay(atPos position: (row: Int, col: Int), using cardId: UUID) {
        // 1) Remove the card from current player's hand
        guard let playedCard = removeCardFromHand(cardId: cardId) else { return }

        // 2) Validate placement for the played card
        guard canPlace(at: position, for: playedCard) else {
            // Put card back if invalid (keeps function side-effect safe)
            players[currentPlayerIndex].cards.append(playedCard)
            return
        }

        // 3) Check if this is a one-eyed jack (remove chip) or regular/two-eyed jack (place chip)
        if let jackRule = classifyJack(playedCard), jackRule == .removeChip {
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
    
    func classifyJack(_ card: Card) -> JackRule? {
        guard card.cardFace == .jack else { return nil }
        switch card.suit {
            
        case .clubs, .diamonds:
            return .placeAnywhere   // two‑eyed
            
        case .spades, .hearts:
            return .removeChip      // one‑eyed
        case .empty:
            return .removeChip
        }
    }
    
}
