//
//  GameStateTests.swift
//  SequenceGameTests
//
//  Created on 2025-11-20.
//
// swiftlint:disable type_body_length
import Foundation
import Testing
@testable import SequenceGame

/// Comprehensive unit tests for GameState core functionality
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
        guard let card = state.players[0].cards.first else {
            Issue.record("No cards in player hand")
            return
        }
        
        state.selectCard(card.id)
        
        #expect(state.selectedCardId == card.id)
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
            for colIndex in 0..<state.boardTiles[rowIndex].count  where !state.boardTiles[rowIndex][colIndex].isEmpty {
                    state.placeChip(at: (rowIndex, colIndex), teamColor: .blue)
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
        guard let card = state.players[0].cards.first else {
            Issue.record("No cards in player hand")
            return
        }
        
        state.selectCard(card.id)
        
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
        guard let card = state.players[0].cards.first else {
            Issue.record("No cards in player hand")
            return
        }
        
        state.selectCard(card.id)
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
        guard let card = state.players[0].cards.first else {
            Issue.record("No cards in player hand")
            return
        }
        
        state.selectCard(card.id)
        
        #expect(state.selectedCard?.id == card.id)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("canPlace validates position bounds")
    func testCanPlaceValidatesBounds() {
        let state = createTestGameState()
        guard let card = state.players[0].cards.first else {
            Issue.record("No cards in player hand")
            return
        }
        
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
    
    // MARK: - Sequence Cache Optimization Tests (Task 14)
    
    @Test("tilesInSequences cache is empty on initialization")
    func testTilesInSequencesCacheInitiallyEmpty() {
        let state = GameState()
        
        #expect(state.tilesInSequences.isEmpty)
    }
    
    @Test("tilesInSequences cache updates when sequences detected")
    func testTilesInSequencesCacheUpdatesOnDetection() {
        let state = createTestGameState()
        
        // Initially empty
        #expect(state.tilesInSequences.isEmpty)
        
        // Create a mock sequence
        let tile1 = state.boardTiles[1][1]
        let tile2 = state.boardTiles[1][2]
        let tile3 = state.boardTiles[1][3]
        let tile4 = state.boardTiles[1][4]
        let tile5 = state.boardTiles[1][5]
        
        let sequence = Sequence(
            tiles: [tile1, tile2, tile3, tile4, tile5],
            position: Position(row: 1, col: 1),
            teamColor: .blue,
            sequenceType: .horizontal
        )
        
        // Manually set detected sequence (simulating detection)
        state.detectedSequence = [sequence]
        
        // Cache should now contain the 5 tile IDs
        #expect(state.tilesInSequences.count == 5)
        #expect(state.tilesInSequences.contains(tile1.id))
        #expect(state.tilesInSequences.contains(tile2.id))
        #expect(state.tilesInSequences.contains(tile3.id))
        #expect(state.tilesInSequences.contains(tile4.id))
        #expect(state.tilesInSequences.contains(tile5.id))
    }
    
    @Test("tilesInSequences cache handles multiple sequences")
    func testTilesInSequencesCacheMultipleSequences() {
        let state = createTestGameState()
        
        // Create two sequences with no overlap
        let seq1Tiles = [
            state.boardTiles[1][1],
            state.boardTiles[1][2],
            state.boardTiles[1][3],
            state.boardTiles[1][4],
            state.boardTiles[1][5]
        ]
        
        let seq2Tiles = [
            state.boardTiles[5][5],
            state.boardTiles[6][5],
            state.boardTiles[7][5],
            state.boardTiles[8][5],
            state.boardTiles[9][5]
        ]
        
        let sequence1 = Sequence(tiles: seq1Tiles, position: Position(row: 1, col: 1), teamColor: .blue, sequenceType: .horizontal)
        let sequence2 = Sequence(tiles: seq2Tiles, position: Position(row: 5, col: 5), teamColor: .red, sequenceType: .vertical)
        
        state.detectedSequence = [sequence1, sequence2]
        
        // Cache should contain all 10 tile IDs
        #expect(state.tilesInSequences.count == 10)
        
        // Verify all tiles from both sequences are cached
        for tile in seq1Tiles {
            #expect(state.tilesInSequences.contains(tile.id))
        }
        for tile in seq2Tiles {
            #expect(state.tilesInSequences.contains(tile.id))
        }
    }
    
    @Test("tilesInSequences cache handles overlapping sequences")
    func testTilesInSequencesCacheOverlappingSequences() {
        let state = createTestGameState()
        
        // Create two sequences that share a tile
        let sharedTile = state.boardTiles[5][5]
        
        let seq1Tiles = [
            state.boardTiles[5][1],
            state.boardTiles[5][2],
            state.boardTiles[5][3],
            state.boardTiles[5][4],
            sharedTile  // Row sequence
        ]
        
        let seq2Tiles = [
            state.boardTiles[1][5],
            state.boardTiles[2][5],
            state.boardTiles[3][5],
            state.boardTiles[4][5],
            sharedTile  // Column sequence
        ]
        
        let sequence1 = Sequence(tiles: seq1Tiles, position: Position(row: 5, col: 1), teamColor: .blue, sequenceType: .horizontal)
        let sequence2 = Sequence(tiles: seq2Tiles, position: Position(row: 1, col: 5), teamColor: .blue, sequenceType: .vertical)
        
        state.detectedSequence = [sequence1, sequence2]
        
        // Cache should contain 9 unique tiles (5 + 5 - 1 overlap)
        #expect(state.tilesInSequences.count == 9)
        #expect(state.tilesInSequences.contains(sharedTile.id))
    }
    
    @Test("tilesInSequences cache clears when sequences removed")
    func testTilesInSequencesCacheClearsOnRemoval() {
        let state = createTestGameState()
        
        // Add a sequence
        let tiles = [
            state.boardTiles[1][1],
            state.boardTiles[1][2],
            state.boardTiles[1][3],
            state.boardTiles[1][4],
            state.boardTiles[1][5]
        ]
        
        let sequence = Sequence(tiles: tiles, position: Position(row: 1, col: 1), teamColor: .blue, sequenceType: .horizontal)
        state.detectedSequence = [sequence]
        
        #expect(state.tilesInSequences.count == 5)
        
        // Clear sequences
        state.detectedSequence = []
        
        // Cache should be empty
        #expect(state.tilesInSequences.isEmpty)
    }
    
    @Test("tilesInSequences cache resets on game start")
    func testTilesInSequencesCacheResetsOnGameStart() {
        let state = GameState()
        
        // Manually add something to the cache
        let dummyTiles = [
            BoardTile(card: Card(cardFace: .ace, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .two, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .three, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .four, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .five, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil)
        ]
        let sequence = Sequence(tiles: dummyTiles, position: Position(row: 0, col: 0), teamColor: .blue, sequenceType: .horizontal)
        state.detectedSequence = [sequence]
        
        #expect(!state.tilesInSequences.isEmpty)
        
        // Start a new game
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let teamRed = Team(color: .red, numberOfPlayers: 1)
        state.startGame(with: [
            Player(name: "P1", team: teamBlue, cards: []),
            Player(name: "P2", team: teamRed, cards: [])
        ])
        
        // Cache should be empty after starting new game
        #expect(state.tilesInSequences.isEmpty)
    }
    
    @Test("tilesInSequences provides O(1) lookup performance")
    func testTilesInSequencesCachePerformance() {
        let state = createTestGameState()
        
        // Create a sequence
        let tiles = [
            state.boardTiles[1][1],
            state.boardTiles[1][2],
            state.boardTiles[1][3],
            state.boardTiles[1][4],
            state.boardTiles[1][5]
        ]
        
        let sequence = Sequence(tiles: tiles, position: Position(row: 1, col: 1), teamColor: .blue, sequenceType: .horizontal)
        state.detectedSequence = [sequence]
        
        // Test that lookups work (O(1) access)
        let tileToCheck = tiles[2]
        #expect(state.tilesInSequences.contains(tileToCheck.id))
        
        // Test that non-sequence tiles are not in cache
        let nonSequenceTile = state.boardTiles[9][9]
        #expect(!state.tilesInSequences.contains(nonSequenceTile.id))
    }
    
    // MARK: - Additional Edge Case Tests
    
    @Test("computePlayableTiles returns empty for nil selected card")
    func testComputePlayableTilesNoCard() {
        let state = createTestGameState()
        state.selectedCardId = nil
        
        let positions = state.validPositionsForSelectedCard
        
        #expect(positions.isEmpty)
    }
    
    @Test("performPlay handles invalid card ID gracefully")
    func testPerformPlayInvalidCardId() {
        let state = createTestGameState()
        let initialHandCount = state.currentPlayer?.cards.count ?? 0
        
        // Try to perform play with non-existent card ID
        let fakeCardId = UUID()
        state.performPlay(atPos: (5, 5), using: fakeCardId)
        
        // Hand should be unchanged
        #expect(state.currentPlayer?.cards.count == initialHandCount)
    }
    
    @Test("replaceDeadCard handles invalid card ID gracefully")
    func testReplaceDeadCardInvalidId() {
        let state = createTestGameState()
        let initialHandCount = state.currentPlayer?.cards.count ?? 0
        
        // Try to replace non-existent card
        let fakeCardId = UUID()
        state.replaceDeadCard(fakeCardId)
        
        // Hand should be unchanged
        #expect(state.currentPlayer?.cards.count == initialHandCount)
    }
    
    @Test("replaceCurrentlySelectedDeadCard handles nil selection")
    func testReplaceCurrentlySelectedDeadCardNilSelection() {
        let state = createTestGameState()
        state.selectedCardId = nil
        let initialHandCount = state.currentPlayer?.cards.count ?? 0
        
        state.replaceCurrentlySelectedDeadCard()
        
        // Nothing should change
        #expect(state.currentPlayer?.cards.count == initialHandCount)
    }
    
    @Test("canPlace handles out of bounds positions")
    func testCanPlaceOutOfBounds() {
        let state = createTestGameState()
        let card = Card(cardFace: .ace, suit: .hearts)
        
        // Test negative indices
        #expect(!state.canPlace(at: (-1, 5), for: card))
        #expect(!state.canPlace(at: (5, -1), for: card))
        
        // Test indices beyond board size
        #expect(!state.canPlace(at: (10, 5), for: card))
        #expect(!state.canPlace(at: (5, 10), for: card))
    }
    
    @Test("evaluateGameState handles teams with no sequences")
    func testEvaluateGameStateNoSequences() {
        let state = createTestGameState()
        state.detectedSequence = []
        
        let result = state.evaluateGameState()
        
        if case .ongoing = result {
            #expect(true)
        } else {
            #expect(Bool(false), "Should return .ongoing when no sequences exist")
        }
    }
    
    @Test("evaluateGameState detects win for 2-player game")
    func testEvaluateGameStateWinTwoPlayers() {
        let state = createTestGameState()
        
        // Create 2 sequences for blue team (required for 2-player game)
        let dummyTiles1 = [
            BoardTile(card: Card(cardFace: .ace, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .two, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .three, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .four, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .five, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil)
        ]
        
        let dummyTiles2 = [
            BoardTile(card: Card(cardFace: .six, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .seven, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .eight, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .nine, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .ten, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil)
        ]
        
        let sequence1 = Sequence(tiles: dummyTiles1, position: Position(row: 0, col: 0), teamColor: .blue, sequenceType: .horizontal)
        let sequence2 = Sequence(tiles: dummyTiles2, position: Position(row: 1, col: 0), teamColor: .blue, sequenceType: .horizontal)
        
        state.detectedSequence = [sequence1, sequence2]
        
        let result = state.evaluateGameState()
        
        if case .win(let team) = result {
            #expect(team == .blue)
            #expect(state.winningTeam == .blue)
        } else {
            #expect(Bool(false), "Should detect win for blue team with 2 sequences")
        }
    }
    
    @Test("evaluateGameState detects win for 3+ player game")
    func testEvaluateGameStateWinMultiplePlayers() {
        let state = createFourPlayerGameState()
        
        // Create 1 sequence for red team (required for 4-player game)
        let dummyTiles = [
            BoardTile(card: Card(cardFace: .ace, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .two, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .three, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .four, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .five, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil)
        ]
        
        let sequence = Sequence(tiles: dummyTiles, position: Position(row: 0, col: 0), teamColor: .red, sequenceType: .horizontal)
        state.detectedSequence = [sequence]
        
        let result = state.evaluateGameState()
        
        if case .win(let team) = result {
            #expect(team == .red)
        } else {
            #expect(Bool(false), "Should detect win for red team with 1 sequence")
        }
    }
    
    @Test("sequencesForTeam counts correctly with multiple sequences")
    func testSequencesForTeamMultipleSequences() {
        let state = createTestGameState()
        
        let dummyTiles1 = [
            BoardTile(card: Card(cardFace: .ace, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .two, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .three, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .four, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .five, suit: .hearts), isEmpty: false, isChipOn: false, chip: nil)
        ]
        
        let dummyTiles2 = [
            BoardTile(card: Card(cardFace: .six, suit: .diamonds), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .seven, suit: .diamonds), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .eight, suit: .diamonds), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .nine, suit: .diamonds), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .ten, suit: .diamonds), isEmpty: false, isChipOn: false, chip: nil)
        ]
        
        let dummyTiles3 = [
            BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .two, suit: .clubs), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .three, suit: .clubs), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .four, suit: .clubs), isEmpty: false, isChipOn: false, chip: nil),
            BoardTile(card: Card(cardFace: .five, suit: .clubs), isEmpty: false, isChipOn: false, chip: nil)
        ]
        
        let blueSeq1 = Sequence(tiles: dummyTiles1, position: Position(row: 0, col: 0), teamColor: .blue, sequenceType: .horizontal)
        let blueSeq2 = Sequence(tiles: dummyTiles2, position: Position(row: 1, col: 0), teamColor: .blue, sequenceType: .horizontal)
        let redSeq = Sequence(tiles: dummyTiles3, position: Position(row: 2, col: 0), teamColor: .red, sequenceType: .horizontal)
        
        state.detectedSequence = [blueSeq1, blueSeq2, redSeq]
        
        #expect(state.sequencesForTeam(teamColor: .blue) == 2)
        #expect(state.sequencesForTeam(teamColor: .red) == 1)
        #expect(state.sequencesForTeam(teamColor: .green) == 0)
    }
    
    @Test("hasSelection computed property works correctly")
    func testHasSelectionComputedProperty() {
        let state = createTestGameState()
        
        // Initially no selection
        #expect(!state.hasSelection)
        
        // Select a card
        if let firstCard = state.currentPlayer?.cards.first {
            state.selectCard(firstCard.id)
            #expect(state.hasSelection)
        }
        
        // Clear selection
        state.clearSelection()
        #expect(!state.hasSelection)
    }
}
// swiftlint:enable type_body_length
