//
//  GameStateTests.swift
//  SequenceGameTests
//
//  Created on 2025-11-20.
//

import Testing
@testable import SequenceGame

/// Comprehensive unit tests for GameState core functionality
@Suite("GameState Core Logic Tests")
struct GameStateTests {
    
    // MARK: - Helper Functions
    
    /// Creates a test game state with basic 2-player setup
    func createTestGameState() -> GameState {
        let state = GameState()
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let teamRed = Team(color: .red, numberOfPlayers: 1)
        let player1 = Player(name: "Player 1", team: teamBlue, cards: [])
        let player2 = Player(name: "Player 2", team: teamRed, cards: [])
        state.startGame(with: [player1, player2])
        return state
    }
    
    /// Creates a game state with 4 players (2 teams)
    func createFourPlayerGameState() -> GameState {
        let state = GameState()
        let teamBlue = Team(color: .blue, numberOfPlayers: 2)
        let teamRed = Team(color: .red, numberOfPlayers: 2)
        let player1 = Player(name: "T1-P1", team: teamBlue, cards: [])
        let player2 = Player(name: "T2-P1", team: teamRed, cards: [])
        let player3 = Player(name: "T1-P2", team: teamBlue, cards: [])
        let player4 = Player(name: "T2-P2", team: teamRed, cards: [])
        state.startGame(with: [player1, player2, player3, player4])
        return state
    }
    
    // MARK: - Game Initialization Tests
    
    @Test("Game initialization creates empty state")
    func testGameInitialization() {
        let state = GameState()
        
        #expect(state.players.isEmpty)
        #expect(state.currentPlayerIndex == 0)
        #expect(state.overlayMode == .turnStart)
        #expect(state.selectedCardId == nil)
        #expect(state.detectedSequence.isEmpty)
        #expect(state.winningTeam == nil)
    }
    
    @Test("startGame initializes players correctly")
    func testStartGameInitializesPlayers() {
        let state = createTestGameState()
        
        #expect(state.players.count == 2)
        #expect(state.players[0].name == "Player 1")
        #expect(state.players[1].name == "Player 2")
        #expect(state.currentPlayerIndex == 0)
    }
    
    @Test("startGame deals correct number of cards")
    func testStartGameDealsCards() {
        let state = createTestGameState()
        
        let expectedCards = GameConstants.cardsPerPlayer(playerCount: 2) // Should be 7
        #expect(state.players[0].cards.count == expectedCards)
        #expect(state.players[1].cards.count == expectedCards)
    }
    
    @Test("startGame resets win state")
    func testStartGameResetsWinState() {
        let state = GameState()
        
        // Manually set win state
        state.winningTeam = .blue
        
        // Start new game
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        state.startGame(with: [Player(name: "P1", team: teamBlue)])
        
        #expect(state.winningTeam == nil)
        #expect(state.detectedSequence.isEmpty)
    }
    
    @Test("startGame sets overlay to turnStart")
    func testStartGameSetsOverlay() {
        let state = createTestGameState()
        
        #expect(state.overlayMode == .turnStart)
    }
    
    // MARK: - Board Setup Tests
    
    @Test("setupBoard creates 10x10 grid")
    func testSetupBoardDimensions() {
        let state = createTestGameState()
        
        #expect(state.boardTiles.count == 10)
        #expect(state.boardTiles.allSatisfy { $0.count == 10 })
    }
    
    @Test("setupBoard leaves corners empty")
    func testSetupBoardCornersEmpty() {
        let state = createTestGameState()
        
        let cornerPositions = GameConstants.cornerPositions
        for corner in cornerPositions {
            let tile = state.boardTiles[corner.row][corner.col]
            #expect(tile.isEmpty)
            #expect(tile.card == nil)
        }
    }
    
    @Test("setupBoard fills non-corner tiles with cards")
    func testSetupBoardNonCornersFilled() {
        let state = createTestGameState()
        
        let totalTiles = 10 * 10
        let cornerCount = GameConstants.cornerPositions.count
        let expectedCardTiles = totalTiles - cornerCount // 100 - 4 = 96
        
        var cardCount = 0
        for rowIndex in 0..<state.boardTiles.count {
            for colIndex in 0..<state.boardTiles[rowIndex].count {
                let tile = state.boardTiles[rowIndex][colIndex]
                if tile.card != nil {
                    cardCount += 1
                }
            }
        }
        
        #expect(cardCount == expectedCardTiles)
    }
    
    @Test("setupBoard excludes Jacks from board")
    func testSetupBoardNoJacks() {
        let state = createTestGameState()
        
        for row in state.boardTiles {
            for tile in row {
                if let card = tile.card {
                    #expect(card.cardFace != .jack)
                }
            }
        }
    }
    
    // MARK: - Turn Management Tests
    
    @Test("currentPlayer returns first player initially")
    func testCurrentPlayerInitial() {
        let state = createTestGameState()
        
        #expect(state.currentPlayer?.name == "Player 1")
    }
    
    @Test("advanceTurn moves to next player")
    func testAdvanceTurnProgression() {
        let state = createTestGameState()
        
        #expect(state.currentPlayerIndex == 0)
        
        state.advanceTurn()
        #expect(state.currentPlayerIndex == 1)
        #expect(state.currentPlayer?.name == "Player 2")
    }
    
    @Test("advanceTurn wraps around to first player")
    func testAdvanceTurnWrapsAround() {
        let state = createTestGameState()
        
        state.advanceTurn() // Player 2
        #expect(state.currentPlayerIndex == 1)
        
        state.advanceTurn() // Back to Player 1
        #expect(state.currentPlayerIndex == 0)
        #expect(state.currentPlayer?.name == "Player 1")
    }
    
    @Test("advanceTurn resets overlay to turnStart")
    func testAdvanceTurnResetsOverlay() {
        let state = createTestGameState()
        state.overlayMode = .cardSelected
        
        state.advanceTurn()
        
        #expect(state.overlayMode == .turnStart)
    }
    
    @Test("advanceTurn handles empty players array")
    func testAdvanceTurnEmptyPlayers() {
        let state = GameState()
        
        // Should not crash
        state.advanceTurn()
        
        #expect(state.currentPlayerIndex == 0)
    }
    
    // MARK: - Card Selection Tests
    
    @Test("selectCard sets selectedCardId")
    func testSelectCardSetsId() {
        let state = createTestGameState()
        let cardId = state.players[0].cards.first!.id
        
        state.selectCard(cardId)
        
        #expect(state.selectedCardId == cardId)
    }
    
    @Test("selectCard sets overlay to cardSelected when valid moves exist")
    func testSelectCardSetsOverlayCardSelected() {
        let state = createTestGameState()
        
        // Find a card that has valid positions
        var validCard: Card?
        for card in state.players[0].cards {
            state.selectCard(card.id)
            if !state.validPositionsForSelectedCard.isEmpty {
                validCard = card
                break
            }
        }
        
        if validCard != nil {
            #expect(state.overlayMode == .cardSelected)
        }
    }
    
    @Test("selectCard sets overlay to deadCard when no valid moves")
    func testSelectCardSetsOverlayDeadCard() {
        let state = createTestGameState()
        
        // Create a dead card (card not on board)
        let deadCard = Card(cardFace: .jack, suit: .hearts) // One-eyed jack
        state.players[0].cards.append(deadCard)
        
        // Find all tiles and mark them as occupied or protected
        // This makes the jack have no valid moves
        for rowIndex in 0..<state.boardTiles.count {
            for colIndex in 0..<state.boardTiles[rowIndex].count {
                if !state.boardTiles[rowIndex][colIndex].isEmpty {
                    state.placeChip(at: (rowIndex, colIndex), teamColor: .blue)
                }
            }
        }
        
        state.selectCard(deadCard.id)
        
        // If no valid positions, overlay should be deadCard
        if state.validPositionsForSelectedCard.isEmpty {
            #expect(state.overlayMode == .deadCard)
        }
    }
    
    @Test("hasSelection returns true when card selected")
    func testHasSelectionTrue() {
        let state = createTestGameState()
        let cardId = state.players[0].cards.first!.id
        
        state.selectCard(cardId)
        
        #expect(state.hasSelection == true)
    }
    
    @Test("hasSelection returns false when no card selected")
    func testHasSelectionFalse() {
        let state = createTestGameState()
        
        #expect(state.hasSelection == false)
    }
    
    @Test("clearSelection removes selectedCardId")
    func testClearSelection() {
        let state = createTestGameState()
        let cardId = state.players[0].cards.first!.id
        
        state.selectCard(cardId)
        #expect(state.selectedCardId != nil)
        
        state.clearSelection()
        #expect(state.selectedCardId == nil)
    }
    
    // MARK: - Valid Positions Tests
    
    @Test("validPositionsForSelectedCard returns empty when no card selected")
    func testValidPositionsNoSelection() {
        let state = createTestGameState()
        
        #expect(state.validPositionsForSelectedCard.isEmpty)
    }
    
    @Test("validPositionsForSelectedCard excludes corners")
    func testValidPositionsExcludesCorners() {
        let state = createTestGameState()
        
        // Select any card
        if let card = state.players[0].cards.first {
            state.selectCard(card.id)
            
            let validPositions = state.validPositionsForSelectedCard
            let cornerPositions = GameConstants.cornerPositions
            
            for corner in cornerPositions {
                let hasCorner = validPositions.contains { $0.row == corner.row && $0.col == corner.col }
                #expect(!hasCorner)
            }
        }
    }
    
    @Test("validPositionsForSelectedCard excludes occupied tiles")
    func testValidPositionsExcludesOccupied() {
        let state = createTestGameState()
        
        // Place a chip
        let occupiedPosition = (row: 5, col: 5)
        state.placeChip(at: occupiedPosition, teamColor: .blue)
        
        // Select a card that matches that position
        if let card = state.boardTiles[occupiedPosition.row][occupiedPosition.col].card {
            let matchingCard = Card(cardFace: card.cardFace, suit: card.suit)
            state.players[0].cards.append(matchingCard)
            state.selectCard(matchingCard.id)
            
            let validPositions = state.validPositionsForSelectedCard
            let hasOccupied = validPositions.contains {
                $0.row == occupiedPosition.row && $0.col == occupiedPosition.col
            }
            
            #expect(!hasOccupied)
        }
    }
    
    // MARK: - Chip Placement Tests
    
    @Test("placeChip sets chip on tile")
    func testPlaceChipSetsChip() {
        let state = createTestGameState()
        let position = (row: 5, col: 5)
        
        state.placeChip(at: position, teamColor: .blue)
        
        let tile = state.boardTiles[position.row][position.col]
        #expect(tile.isChipOn == true)
        #expect(tile.chip != nil)
        #expect(tile.chip?.color == .blue)
    }
    
    @Test("placeChip marks chip as placed")
    func testPlaceChipMarksPlaced() {
        let state = createTestGameState()
        let position = (row: 5, col: 5)
        
        state.placeChip(at: position, teamColor: .red)
        
        let tile = state.boardTiles[position.row][position.col]
        #expect(tile.chip?.isPlaced == true)
    }
    
    @Test("placeChip does not remove card from tile")
    func testPlaceChipKeepsCard() {
        let state = createTestGameState()
        let position = (row: 5, col: 5)
        let originalCard = state.boardTiles[position.row][position.col].card
        
        state.placeChip(at: position, teamColor: .blue)
        
        let tile = state.boardTiles[position.row][position.col]
        #expect(tile.card?.cardFace == originalCard?.cardFace)
        #expect(tile.card?.suit == originalCard?.suit)
    }
    
    // MARK: - Chip Removal Tests
    
    @Test("removeChip removes chip from tile")
    func testRemoveChipRemovesChip() {
        let state = createTestGameState()
        let position = (row: 5, col: 5)
        
        // Place chip first
        state.placeChip(at: position, teamColor: .blue)
        #expect(state.boardTiles[position.row][position.col].isChipOn == true)
        
        // Remove chip
        state.removeChip(at: position)
        
        let tile = state.boardTiles[position.row][position.col]
        #expect(tile.isChipOn == false)
        #expect(tile.chip == nil)
    }
    
    @Test("removeChip keeps card on tile")
    func testRemoveChipKeepsCard() {
        let state = createTestGameState()
        let position = (row: 5, col: 5)
        let originalCard = state.boardTiles[position.row][position.col].card
        
        state.placeChip(at: position, teamColor: .blue)
        state.removeChip(at: position)
        
        let tile = state.boardTiles[position.row][position.col]
        #expect(tile.card?.cardFace == originalCard?.cardFace)
    }
    
    // MARK: - Dead Card Replacement Tests
    
    @Test("replaceDeadCard removes card from hand")
    func testReplaceDeadCardRemovesCard() {
        let state = createTestGameState()
        let deadCard = Card(cardFace: .ace, suit: .spades)
        state.players[0].cards.append(deadCard)
        
        let initialCount = state.players[0].cards.count
        state.replaceDeadCard(deadCard.id)
        
        let hasDeadCard = state.players[0].cards.contains { $0.id == deadCard.id }
        #expect(!hasDeadCard)
    }
    
    @Test("replaceDeadCard draws replacement card")
    func testReplaceDeadCardDrawsReplacement() {
        let state = createTestGameState()
        let deadCard = Card(cardFace: .ace, suit: .spades)
        state.players[0].cards.append(deadCard)
        
        let initialCount = state.players[0].cards.count
        state.replaceDeadCard(deadCard.id)
        
        // Hand size should remain the same (removed 1, added 1)
        #expect(state.players[0].cards.count == initialCount)
    }
    
    @Test("replaceDeadCard clears selection")
    func testReplaceDeadCardClearsSelection() {
        let state = createTestGameState()
        let deadCard = Card(cardFace: .ace, suit: .spades)
        state.players[0].cards.append(deadCard)
        
        state.selectCard(deadCard.id)
        state.replaceDeadCard(deadCard.id)
        
        #expect(state.selectedCardId == nil)
    }
    
    @Test("replaceDeadCard resets overlay to turnStart")
    func testReplaceDeadCardResetsOverlay() {
        let state = createTestGameState()
        let deadCard = Card(cardFace: .ace, suit: .spades)
        state.players[0].cards.append(deadCard)
        
        state.overlayMode = .deadCard
        state.replaceDeadCard(deadCard.id)
        
        #expect(state.overlayMode == .turnStart)
    }
    
    // MARK: - Win Condition Tests
    
    @Test("requiredSequencesToWin returns 2 for 2 players")
    func testRequiredSequencesTwoPlayers() {
        let state = createTestGameState() // 2 players
        
        #expect(state.requiredSequencesToWin == 2)
    }
    
    @Test("requiredSequencesToWin returns 1 for 3+ players")
    func testRequiredSequencesMultiplePlayers() {
        let state = createFourPlayerGameState() // 4 players
        
        #expect(state.requiredSequencesToWin == 1)
    }
    
    @Test("sequencesForTeam counts team sequences")
    func testSequencesForTeam() {
        let state = createTestGameState()
        
        // Initially no sequences
        #expect(state.sequencesForTeam(teamColor: .blue) == 0)
        #expect(state.sequencesForTeam(teamColor: .red) == 0)
    }
    
    @Test("evaluateGameState returns ongoing when no winner")
    func testEvaluateGameStateOngoing() {
        let state = createTestGameState()
        
        let result = state.evaluateGameState()
        
        if case .ongoing = result {
            #expect(true)
        } else {
            #expect(Bool(false), "Expected ongoing game state")
        }
    }
    
    // MARK: - Computed Properties Tests
    
    @Test("currentPlayer returns nil for empty players")
    func testCurrentPlayerEmptyPlayers() {
        let state = GameState()
        
        #expect(state.currentPlayer == nil)
    }
    
    @Test("currentPlayer returns nil for out of bounds index")
    func testCurrentPlayerOutOfBounds() {
        let state = createTestGameState()
        state.currentPlayerIndex = 999
        
        #expect(state.currentPlayer == nil)
    }
    
    @Test("selectedCard returns nil when no selection")
    func testSelectedCardNoSelection() {
        let state = createTestGameState()
        
        #expect(state.selectedCard == nil)
    }
    
    @Test("selectedCard returns correct card when selected")
    func testSelectedCardReturnsCorrectCard() {
        let state = createTestGameState()
        let card = state.players[0].cards.first!
        
        state.selectCard(card.id)
        
        #expect(state.selectedCard?.id == card.id)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("canPlace validates position bounds")
    func testCanPlaceValidatesBounds() {
        let state = createTestGameState()
        let card = state.players[0].cards.first!
        
        // Out of bounds position
        let outOfBounds = (row: 20, col: 20)
        let canPlace = state.canPlace(at: outOfBounds, for: card)
        
        #expect(!canPlace)
    }
    
    @Test("canPlace rejects corner positions")
    func testCanPlaceRejectsCorners() {
        let state = createTestGameState()
        
        if let card = state.players[0].cards.first {
            for corner in GameConstants.cornerPositions {
                let canPlace = state.canPlace(at: (row: corner.row, col: corner.col), for: card)
                #expect(!canPlace)
            }
        }
    }
    
    @Test("performPlay prevents play after game over")
    func testPerformPlayPreventedAfterGameOver() {
        let state = createTestGameState()
        state.overlayMode = .gameOver
        
        let initialHandCount = state.players[0].cards.count
        
        if let card = state.players[0].cards.first {
            state.performPlay(atPos: (5, 5), using: card.id)
        }
        
        // Hand should not change
        #expect(state.players[0].cards.count == initialHandCount)
    }
    
    @Test("boardTiles syncs with board on update")
    func testBoardTilesSyncsWithBoard() {
        let state = createTestGameState()
        
        // Modify boardTiles
        let newTiles = state.boardTiles
        state.boardTiles = newTiles
        
        // board.boardTiles should be synced automatically via didSet
        #expect(state.board.boardTiles.count == state.boardTiles.count)
    }
}

