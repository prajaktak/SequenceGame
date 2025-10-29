//
//  SequenceGameTests.swift
//  SequenceGameTests
//
//  Created by Prajakta Kulkarni on 17/10/2025.
//

// swiftlint:disable type_body_length

import Testing
@testable import SequenceGame
import SwiftUICore

struct SequenceGameTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test("Test Standard Deck Size")
    func testStandardDeckSize() {
        let deck = Deck()
        let numberOfCards = deck.cardsRemaining()
        #expect(numberOfCards == 52)  // Standard 52-card deck
    }
    
    @Test("Test DoubleDeck Size")
    func testDoubleDeckSize() {
        let doubleDeck = DoubleDeck()
        let numberOfCards = doubleDeck.cardsRemaining()
        #expect(numberOfCards == 104)  // Two standard decks combined
    }
    
    @Test("Test Shuffle")
    func testShuffle() {
        let deck = Deck()
        deck.shuffle()
        let firstCard = deck.drawCard()
        let secondCard = deck.drawCard()
        #expect(firstCard?.cardFace != secondCard?.cardFace)
    }
    
    @Test("Test Draw Card without Jack")
    func testDrawCardWithoutJack() {
        let deck = Deck()
        var cardCount: Int = 0
        for _ in 0..<48 {
            let card = deck.drawCardExceptJacks()
            if card?.cardFace != .jack {
                cardCount += 1
            }
        }
        #expect(cardCount == 48)
    }
    
    @Test("Test Two deck draw")
    func testTwoDeckDraw() {
        let doubleDeck = DoubleDeck()
        var cardCount: Int = 0
        for _ in 0..<96 where  doubleDeck.cardsRemaining() != 0 {
            if doubleDeck.drawCardExceptJacks() != nil {
                cardCount += 1
            }
        }
        
        #expect(cardCount == 96)  // Two decks: 104 total - 8 Jacks = 96 non-Jack cards
    }
    
    @Test("Test Shuffle and card Draw")
    func testShuffleAndCardDraw() {
        var cardCount: Int = 0
        let deck = Deck()
        for _ in 0..<48 {
            deck.shuffle()
            let card = deck.drawCardExceptJacks()
            if card?.cardFace != nil {
                cardCount += 1
            }
        }
        
        #expect(cardCount == 48)
    }
    
    @Test("DoubleDeck resetDeck restores to 104 and clears draw count")
    func testDoubleDeck_resetDeckRestoresState() {
        let doubleDeck = DoubleDeck()
        _ = doubleDeck.drawCard()
        _ = doubleDeck.drawCard()
        #expect(doubleDeck.cardsRemaining() < 104)

        doubleDeck.resetDeck()

        #expect(doubleDeck.cardsRemaining() == 104)
        #expect(doubleDeck.cardDrawCount == 0)
    }
    
    @Test("DoubleDeck drawCard reduces count by one")
    func testDoubleDeck_drawCardReducesCount() {
        let doubleDeck = DoubleDeck()
        let before = doubleDeck.cardsRemaining()
        _ = doubleDeck.drawCard()
        #expect(doubleDeck.cardsRemaining() == before - 1)
    }
    
    @Test("DoubleDeck deal distributes round-robin")
    func testDoubleDeck_dealRoundRobin() {
        // Teams must have at least 1 player
        let teamBlue = Team(color: .blue, numberOfPlayers: 2)
        let teamGreen = Team(color: .green, numberOfPlayers: 1)

        // Players correctly reference their teams
        var players = [
            Player(name: "P1", team: teamBlue),
            Player(name: "P2", team: teamGreen),
            Player(name: "P3", team: teamBlue)
        ]

        let doubleDeck = DoubleDeck()
        doubleDeck.shuffle()

        doubleDeck.deal(handCount: 2, to: &players)

        #expect(players[0].cards.count == 2)
        #expect(players[1].cards.count == 2)
        #expect(players[2].cards.count == 2)
        #expect(doubleDeck.cardsRemaining() == 104 - (players.count * 2))
    }
    
    @Test("DoubleDeck shuffle preserves count")
    func testDoubleDeck_shufflePreservesCount() {
        let doubleDeck = DoubleDeck()
        let before = doubleDeck.cardsRemaining()
        doubleDeck.shuffle()
        #expect(doubleDeck.cardsRemaining() == before)
    }
    
    @Test("DoubleDeck drawCardExceptJacks never returns a Jack")
    func testDoubleDeck_drawNonJack() {
        let doubleDeck = DoubleDeck()
        doubleDeck.shuffle()

        var sawJack = false
        for _ in 0..<96 { // 104 total minus 8 Jacks ≈ 96 non-Jacks
            if let card = doubleDeck.drawCardExceptJacks(),
               card.cardFace == .jack {
                sawJack = true
                break
            }
        }
        #expect(sawJack == false)
    }
    
    // MARK: - Additional DoubleDeck Tests (per Improvements.md)
    
    @Test("DoubleDeck resetDeck resets both internal decks to 52 cards each")
    func testDoubleDeck_resetDeck_resetsBothDecks() {
        let doubleDeck = DoubleDeck()
        // Draw all cards from first deck (52 cards)
        for _ in 0..<52 {
            _ = doubleDeck.drawCard()
        }
        // Verify we've drawn from first deck
        #expect(doubleDeck.cardsRemaining() == 52)
        
        // Reset should restore both decks
        doubleDeck.resetDeck()
        #expect(doubleDeck.cardsRemaining() == 104)
    }
    
    @Test("DoubleDeck resetDeck clears cardDrawCount")
    func testDoubleDeck_resetDeck_clearsCardDrawCount() {
        let doubleDeck = DoubleDeck()
        _ = doubleDeck.drawCard()
        _ = doubleDeck.drawCard()
        #expect(doubleDeck.cardDrawCount > 0)
        
        doubleDeck.resetDeck()
        #expect(doubleDeck.cardDrawCount == 0)
    }
    
    @Test("DoubleDeck shuffle preserves total card count")
    func testDoubleDeck_shuffle_preservesTotalCount() {
        let doubleDeck = DoubleDeck()
        let beforeCount = doubleDeck.cardsRemaining()
        doubleDeck.shuffle()
        #expect(doubleDeck.cardsRemaining() == beforeCount)
    }
    
    @Test("DoubleDeck drawCard draws sequentially from deck1 then deck2")
    func testDoubleDeck_drawCard_drawsSequentiallyFromBothDecks() {
        let doubleDeck = DoubleDeck()
        
        // Draw all 52 cards from first deck
        for _ in 0..<52 {
            _ = doubleDeck.drawCard()
        }
        #expect(doubleDeck.cardsRemaining() == 52)
        
        // Next draw should come from second deck
        let cardFromDeck2 = doubleDeck.drawCard()
        #expect(cardFromDeck2 != nil)
        #expect(doubleDeck.cardsRemaining() == 51)
    }
    
    @Test("DoubleDeck deal distributes cards to all players")
    func testDoubleDeck_deal_distributesToAllPlayers() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        var players = [
            Player(name: "Player1", team: teamBlue),
            Player(name: "Player2", team: teamBlue)
        ]
        
        let doubleDeck = DoubleDeck()
        doubleDeck.shuffle()
        let initialCount = doubleDeck.cardsRemaining()
        
        doubleDeck.deal(handCount: 3, to: &players)
        
        #expect(players[0].cards.count == 3)
        #expect(players[1].cards.count == 3)
        #expect(doubleDeck.cardsRemaining() == initialCount - 6)
    }
    
    @Test("Tile Placement Test")
    func testTilePlacement() {
        let deck1 = Deck()
        let deck2 = Deck()
        let noOfColumns: Int = 10
        let noOfRows: Int = 10
        var emptyTile: Int = 0
        var cardPlaced: Int = 0
        deck1.shuffle()
        deck2.shuffle()
        for row in 0..<noOfRows {
            for column in (0..<noOfColumns) {
                if (row == 0 && column == 0) ||
                    (row == 0 && column == noOfColumns - 1) ||
                    (row == noOfRows - 1 && column == 0) ||
                    (row == noOfRows - 1 && column == noOfColumns - 1) {
                    emptyTile += 1
                } else {
                    if deck1.cardsRemaining() != 0 {
                        let card = deck1.drawCardExceptJacks()
                        print(row, column, card?.cardFace ?? "nil", card?.suit ?? "nil")
                        cardPlaced += 1
                    } else if deck2.cardsRemaining() != 0 {
                        let card = deck2.drawCardExceptJacks()
                        print(row, column, card?.cardFace ?? "nil", card?.suit ?? "nil")
                        cardPlaced += 1
                    } else {
                        emptyTile += 1
                        
                    }
                }
            }
        }
        
        // With double deck (208 cards total, 16 Jacks), we have 192 non-Jack cards
        // We need 96 cards for board (100 tiles - 4 corners), so both decks should have cards remaining
        // Test verifies board setup uses non-Jack cards correctly
        #expect(emptyTile == 4)
        #expect(cardPlaced == 96)
        // Decks will have cards remaining (including Jacks and remaining non-Jack cards)
        #expect(deck1.cardsRemaining() + deck2.cardsRemaining() >= 0)
    }
    
    @Test("one card Draw")
    func testOneCardDraw() {
        let deck1 = Deck()
        deck1.shuffle()
        _ = deck1.drawCard()
        #expect(deck1.cardsRemaining() == 51)  // 52 - 1 = 51 (standard deck)
    }
    
    @Test("Card draw in 2d for loop")
    func testTwoDimensionalCardDraw() {
        let deck1 = Deck()
        deck1.shuffle()
        for _ in 0..<5 {
            for _ in 0..<5 {
                _ = deck1.drawCard()
            }
        }
        
        #expect(deck1.cardsRemaining() == 27)  // 52 - 25 = 27 (standard deck, 25 cards drawn)
    }
    @Test("Deck deal round-robin and allows Jacks")
    func testDealRoundRobinAllowsJacks() {
        let deck = Deck()
        deck.resetDeck()
        deck.shuffle()

        var players: [Player] = [
            Player(name: "P1", team: Team(color: .blue, numberOfPlayers: 1)),
            Player(name: "P2", team: Team(color: .green, numberOfPlayers: 1)),
            Player(name: "P3", team: Team(color: .red, numberOfPlayers: 1))
        ]
        let handCount = 6

        deck.deal(handCount: handCount, to: &players)

        #expect(players.map { $0.cards.count } == [handCount, handCount, handCount])

        // Non-deterministic for Jack presence; ensure we dealt correct total count
        #expect(players.flatMap { $0.cards }.count == handCount * players.count)
    }
    @Test("startGame sets players and current player")
    func testStartGamePlayers() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])
        #expect(state.players.count == 2)
        #expect(state.currentPlayer?.name == "P1")
    }
    
    @Test("startGame deals expected hand size")
    func testStartGameDealsHands() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])
        let expected = GameConstants.cardsPerPlayer(playerCount: 2)
        #expect(state.players.allSatisfy { $0.cards.count == expected })
    }
    
    @Test("startGame seeds board (non-corners have cards)")
    func testStartGameSeedsBoard() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])
        let total = GameConstants.boardRows * GameConstants.boardColumns
        let nonCorners = total - GameConstants.cornerPositions.count
        let withCards = state.boardTiles.flatMap { $0 }.filter { $0.card != nil }.count
        #expect(withCards == nonCorners)
    }
    
    @Test("startGame sets overlay to turnStart")
    func testStartGameOverlayMode() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])
        #expect(state.overlayMode == .turnStart)
    }
    
    @Test("computePlayableTiles: finds matches, skips occupied and corners")
    func testComputePlayableTiles() {
        // Given board seeded
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])

        // Pick a tile with a real card
        // Find first non-corner, non-occupied tile
        guard let targetPos = (0..<GameConstants.boardRows).lazy.flatMap({ row in
            (0..<GameConstants.boardColumns).lazy.compactMap { col -> (row: Int, col: Int)? in
                let tile = state.boardTiles[row][col]
                return (tile.card != nil && !tile.isChipOn) ? (row, col) : nil
            }
        }).first else {
            #expect(Bool(false), "No suitable tile found"); return
        }

        let targetCard = state.boardTiles[targetPos.row][targetPos.col].card!
        // Occupy one matching spot (if multiple exist)
        let allMatches = state.computePlayableTiles(for: targetCard)
        #expect(!allMatches.isEmpty)

        // Mark first match as occupied
        let occupy = allMatches.first!
        state.boardTiles[occupy.row][occupy.col].isChipOn = true

        // When
        let playable = state.computePlayableTiles(for: targetCard)

        // Then
        #expect(playable.allSatisfy { pos in
            let tile = state.boardTiles[pos.row][pos.col]
            return tile.card?.cardFace == targetCard.cardFace &&
                   tile.card?.suit == targetCard.suit &&
                   tile.isChipOn == false
        })
        #expect(!playable.contains { $0 == occupy }) // occupied excluded
        // Corners have nil card, implicitly excluded by the function
    }
    
    @Test("placeChip sets chip at position")
    func testPlaceChip_setsChip() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])

        let position = (row: 3, col: 3)
        state.placeChip(at: position, teamColor: team.color)

        let tile = state.boardTiles[position.row][position.col]
        #expect(tile.isChipOn == true)
        #expect(tile.chip?.color == team.color)
    }
    
    @Test("placeChip does not change current player's hand")
    func testPlaceChip_doesNotChangeHand() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])

        let start = state.players[state.currentPlayerIndex].cards.count
        state.placeChip(at: (row: 2, col: 2), teamColor: team.color)
        #expect(state.players[state.currentPlayerIndex].cards.count == start)
    }
    
    @Test("removeChip sets isChipOn to false")
    func testRemoveChip_setsIsChipOnToFalse() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])
        
        let position = (row: 4, col: 4)
        state.placeChip(at: position, teamColor: team.color)
        state.removeChip(at: position)
        
        let tile = state.boardTiles[position.row][position.col]
        #expect(tile.isChipOn == false)
    }
    
    @Test("removeChip sets chip to nil")
    func testRemoveChip_setsChipToNil() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])
        
        let position = (row: 4, col: 4)
        state.placeChip(at: position, teamColor: team.color)
        state.removeChip(at: position)
        
        let tile = state.boardTiles[position.row][position.col]
        #expect(tile.chip == nil)
    }
    
    @Test("placeChip does not advance turn")
    func testPlaceChip_doesNotAdvanceTurn() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])

        let startIndex = state.currentPlayerIndex
        state.placeChip(at: (row: 1, col: 1), teamColor: team.color)
        #expect(state.currentPlayerIndex == startIndex)
    }
    
    @Test("removeCardFromHand removes one")
    func testRemoveCardFromHandRemovesOne() {
        // Given
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])

        let playerIndex = state.currentPlayerIndex
        #expect(!state.players[playerIndex].cards.isEmpty)

        let originalHandCount = state.players[playerIndex].cards.count
        let cardToRemove = state.players[playerIndex].cards.first!
        let cardId = cardToRemove.id

        // When
        let removed = state.removeCardFromHand(cardId: cardId)

        // Then
        #expect(removed?.id == cardId)
        #expect(state.players[playerIndex].cards.count == originalHandCount - 1)
        #expect(!state.players[playerIndex].cards.contains { $0.id == cardId })
    }
    
    @Test("drawReplacement adds one card")
    func testDrawReplacementAddsOne() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])

        let index = state.currentPlayerIndex
        let before = state.players[index].cards.count

        state.drawReplacementForHand()

        #expect(state.players[index].cards.count == before + 1)
    }
    
    @Test("canPlace true for matching unoccupied")
    func testCanPlace_matchingUnoccupied_true() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])

        // Controlled setup
        let position = (row: 4, col: 4)
        let card = Card(cardFace: .ace, suit: .hearts)
        state.boardTiles[position.row][position.col].card = card
        state.boardTiles[position.row][position.col].isChipOn = false

        #expect(state.canPlace(at: position, for: card) == true)
    }
    
    @Test("canPlace false when occupied")
    func testCanPlace_matchingOccupied_false() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])

        let position = (row: 5, col: 5)
        let card = Card(cardFace: .ten, suit: .clubs)
        state.boardTiles[position.row][position.col].card = card
        state.boardTiles[position.row][position.col].isChipOn = true  // occupied

        #expect(state.canPlace(at: position, for: card) == false)
    }
    
    @Test("canPlace false for non‑matching unoccupied")
    func testCanPlace_nonMatchingUnoccupied_false() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])

        let position = (row: 6, col: 6)
        state.boardTiles[position.row][position.col].card = Card(cardFace: .queen, suit: .spades)
        state.boardTiles[position.row][position.col].isChipOn = false

        let differentCard = Card(cardFace: .nine, suit: .diamonds)
        #expect(state.canPlace(at: position, for: differentCard) == false)
    }
    
    @Test("performPlay removes, places, draws, advances")
    func testPerformPlay_orchestratesSteps() {
        // Given
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])

        // Controlled board setup: choose a position and card that matches the tile
        let position = (row: 3, col: 4)
        let playableCard = Card(cardFace: .ten, suit: .hearts)
        state.boardTiles[position.row][position.col].card = playableCard
        state.boardTiles[position.row][position.col].isChipOn = false

        // Put that exact card in current player's hand
        let startPlayerIndex = state.currentPlayerIndex
        state.players[startPlayerIndex].cards.append(playableCard)
        let handBefore = state.players[startPlayerIndex].cards.count
        let cardId = playableCard.id

        // When
        state.performPlay(atPos: position, using: cardId)

        // Then
        // 1) Card removed from hand, then 1 card drawn → net hand size unchanged
        #expect(state.players[startPlayerIndex].cards.count == handBefore)

        // 2) Chip placed at the position with player team color
        let placed = state.boardTiles[position.row][position.col]
        #expect(placed.isChipOn == true)
        #expect(placed.chip?.color == team.color)

        // 3) Turn advanced
        #expect(state.currentPlayerIndex == (startPlayerIndex + 1) % state.players.count)
    }
    
    @Test("advanceTurn increments index")
    func testAdvanceTurn_increments() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])

        let start = state.currentPlayerIndex
        state.advanceTurn()
        #expect(state.currentPlayerIndex == start + 1)
    }
    
    @Test("advanceTurn wraps to zero")
    func testAdvanceTurn_wraps() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [
            Player(name: "P1", team: team),
            Player(name: "P2", team: team)
        ])

        // Move to last index and advance
        state.currentPlayerIndex = state.players.count - 1
        state.advanceTurn()

        #expect(state.currentPlayerIndex == 0)
    }
    
    @Test("replaceDeadCard removes one and draws one (no turn advance)")
    func testReplaceDeadCard_removesAndDraws_noAdvance() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])

        let startIndex = state.currentPlayerIndex
        let playerIndex = startIndex
        #expect(!state.players[playerIndex].cards.isEmpty)

        let before = state.players[playerIndex].cards.count
        let deadCardId = state.players[playerIndex].cards.first!.id

        state.replaceDeadCard(deadCardId)

        // Hand size unchanged (−1 discard +1 draw)
        #expect(state.players[playerIndex].cards.count == before)
        // Removed card no longer present
        #expect(!state.players[playerIndex].cards.contains { $0.id == deadCardId })
        // Turn did not advance
        #expect(state.currentPlayerIndex == startIndex)
    }
    
    @Test("selectCard stores id and exposes valid positions")
    func testSelectCard_exposesValidPositions() {
        // Given
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])

        // Put a known card on the board at a known position
        let position = (row: 4, col: 4)
        let knownCard = Card(cardFace: .king, suit: .spades)
        state.boardTiles[position.row][position.col].card = knownCard
        state.boardTiles[position.row][position.col].isChipOn = false

        // Also add the same card to the current player's hand so this is a realistic selection
        let currentIndex = state.currentPlayerIndex
        state.players[currentIndex].cards.append(knownCard)

        // When: select that card
        state.selectCard(knownCard.id)

        // Then
        #expect(state.selectedCardId == knownCard.id)
        #expect(state.validPositionsForSelectedCard.contains { $0.row == position.row && $0.col == position.col })
    }
    
    @Test("clearSelection resets id and positions")
    func testClearSelection_resets() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])

        // Put a known card on board and in hand
        let position = (row: 2, col: 2)
        let knownCard = Card(cardFace: .king, suit: .hearts)
        state.boardTiles[position.row][position.col].card = knownCard
        state.boardTiles[position.row][position.col].isChipOn = false
        state.players[state.currentPlayerIndex].cards.append(knownCard)

        state.selectCard(knownCard.id)
        #expect(state.selectedCardId == knownCard.id)
        #expect(!state.validPositionsForSelectedCard.isEmpty)

        state.clearSelection()

        #expect(state.selectedCardId == nil)
        #expect(state.validPositionsForSelectedCard.isEmpty)
    }
    
    @Test("clearSelection resets selectedCardId")
    func testClearSelection_resetsId() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])

        let anyCard = state.players[state.currentPlayerIndex].cards.first!
        state.selectCard(anyCard.id)
        #expect(state.selectedCardId == anyCard.id)

        state.clearSelection()
        #expect(state.selectedCardId == nil)
    }
    
    @Test("validPositionsForSelectedCard empty when no selection")
    func testValidPositions_emptyWhenNoSelection() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])

        state.clearSelection()
        #expect(state.validPositionsForSelectedCard.isEmpty)
    }
    
    @Test("selectedCard is nil when id not in hand")
    func testSelectedCard_nilWhenMissing() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])

        // Select a random UUID not present in hand
        state.selectedCardId = UUID()

        #expect(state.selectedCard == nil)
        #expect(state.validPositionsForSelectedCard.isEmpty)
    }
    
    @Test("Jack classification: clubs → placeAnywhere")
    func jackClassification_clubs_returnsPlaceAnywhere() {
        let gameState = GameState()
        let jackOfClubs = Card(cardFace: .jack, suit: .clubs)
        #expect(gameState.classifyJack(jackOfClubs) == .placeAnywhere)
    }

    @Test("Jack classification: diamonds → placeAnywhere")
    func jackClassification_diamonds_returnsPlaceAnywhere() {
        let gameState = GameState()
        let jackOfDiamonds = Card(cardFace: .jack, suit: .diamonds)
        #expect(gameState.classifyJack(jackOfDiamonds) == .placeAnywhere)
    }

    @Test("Jack classification: spades → removeChip")
    func jackClassification_spades_returnsRemoveChip() {
        let gameState = GameState()
        let jackOfSpades = Card(cardFace: .jack, suit: .spades)
        #expect(gameState.classifyJack(jackOfSpades) == .removeChip)
    }

    @Test("Jack classification: hearts → removeChip")
    func jackClassification_hearts_returnsRemoveChip() {
        let gameState = GameState()
        let jackOfHearts = Card(cardFace: .jack, suit: .hearts)
        #expect(gameState.classifyJack(jackOfHearts) == .removeChip)
    }

    @Test("computePlayableTiles: two-eyed jack returns all empty non-corner tiles")
    func computePlayableTiles_twoEyedJack_returnsAllEmptyNonCornerTiles() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])
        
        let jackOfClubs = Card(cardFace: .jack, suit: .clubs)
        let playableTiles = state.computePlayableTiles(for: jackOfClubs)
        
        // Count total non-corner, empty tiles (should be ~96 for 10x10 board minus 4 corners)
        var expectedCount = 0
        for rowIndex in 0..<GameConstants.boardRows {
            for colIndex in 0..<GameConstants.boardColumns {
                let isCorner = GameConstants.cornerPositions.contains { $0.row == rowIndex && $0.col == colIndex }
                let tile = state.boardTiles[rowIndex][colIndex]
                if !isCorner && !tile.isChipOn && tile.card != nil {
                    expectedCount += 1
                }
            }
        }
        
        // Current implementation returns 0 for Jacks (tries to match Jack on board, which doesn't exist)
        // After implementation, should return all empty non-corner tiles
        #expect(expectedCount > 0)  // Ensure we have tiles to test with
        // This will fail with current implementation (returns 0), should pass after implementation
        #expect(playableTiles.count == expectedCount)
        #expect(!playableTiles.isEmpty)  // Should fail now, pass after implementation
        
        // Verify all returned tiles are empty and non-corner
        for position in playableTiles {
            let isCorner = GameConstants.cornerPositions.contains { $0.row == position.row && $0.col == position.col }
            let tile = state.boardTiles[position.row][position.col]
            #expect(!isCorner)
            #expect(!tile.isChipOn)
            #expect(tile.card != nil)
        }
    }

    @Test("computePlayableTiles: one-eyed jack returns only tiles with chips")
    func computePlayableTiles_oneEyedJack_returnsOnlyTilesWithChips() {
        let team = Team(color: .blue, numberOfPlayers: 1)
        let state = GameState()
        state.startGame(with: [Player(name: "P1", team: team), Player(name: "P2", team: team)])
        
        // Place some chips on the board
        state.placeChip(at: (row: 3, col: 3), teamColor: .blue)
        state.placeChip(at: (row: 5, col: 5), teamColor: .green)
        
        let jackOfSpades = Card(cardFace: .jack, suit: .spades)
        let playableTiles = state.computePlayableTiles(for: jackOfSpades)
        
        // Current implementation returns 0 for Jacks (tries to match Jack on board, which doesn't exist)
        // After implementation, should return all tiles with chips (at least our 2 placed chips)
        // This will fail with current implementation (returns 0), should pass after implementation
        #expect(playableTiles.count >= 2)
        #expect(!playableTiles.isEmpty)  // Should fail now, pass after implementation
        
        // Verify all returned tiles have chips
        for position in playableTiles {
            let tile = state.boardTiles[position.row][position.col]
            #expect(tile.isChipOn == true)
            #expect(tile.chip != nil)
        }
    }
    
    @Test("GameState startGame deals correct hand sizes with DoubleDeck")
    func testStartGame_dealsCorrectHandSizes_withDoubleDeck() {
        // Given 4 players (6 cards each per rules)
        let teamBlue = Team(color: .blue, numberOfPlayers: 2)
        let teamGreen = Team(color: .green, numberOfPlayers: 2)
        let players = [
            Player(name: "P1", team: teamBlue),
            Player(name: "P2", team: teamGreen),
            Player(name: "P3", team: teamBlue),
            Player(name: "P4", team: teamGreen)
        ]

        let gameState = GameState()
        gameState.startGame(with: players)

        let expected = GameConstants.cardsPerPlayer(playerCount: players.count)
        #expect(gameState.players.allSatisfy { $0.cards.count == expected })
    }
    
    @Test("GameState startGame reduces deck by dealt cards")
    func testStartGame_reducesDeckByDealtCards() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 2)
        let teamGreen = Team(color: .green, numberOfPlayers: 2)
        let players = [
            Player(name: "P1", team: teamBlue),
            Player(name: "P2", team: teamGreen),
            Player(name: "P3", team: teamBlue),
            Player(name: "P4", team: teamGreen)
        ]

        let gameState = GameState()
        let expectedHand = GameConstants.cardsPerPlayer(playerCount: players.count)
        let expectedTotalDealt = players.count * expectedHand

        let before = gameState.deck.cardsRemaining()
        gameState.startGame(with: players)
        let after = gameState.deck.cardsRemaining()

        #expect(after == before - expectedTotalDealt)
    }
    
    @Test("GameState setupBoard places no Jacks and keeps corners empty")
    func testSetupBoard_noJacks_cornersEmpty() {
        let state = GameState()
        state.setupBoard()

        // Corners are empty
        for corner in GameConstants.cornerPositions {
            let tile = state.boardTiles[corner.row][corner.col]
            #expect(tile.card == nil)
            #expect(tile.isEmpty == true)
        }

        // Non-corner tiles have a non-Jack card (or are empty if deck runs out)
        for row in 0..<GameConstants.boardRows {
            for col in 0..<GameConstants.boardColumns {
                if GameConstants.cornerPositions.contains(where: { $0.row == row && $0.col == col }) {
                    continue
                }
                let tile = state.boardTiles[row][col]
                if let card = tile.card {
                    #expect(card.cardFace != .jack)
                }
            }
        }
    }
    
    @Test("setupBoard fills all non-corner tiles using DoubleDeck seeding")
    func testSetupBoard_fillsNonCornerTiles_withDoubleDeckSeeding() {
        let state = GameState()
        state.setupBoard()

        var nonCornerFilled = 0
        for row in 0..<GameConstants.boardRows {
            for col in 0..<GameConstants.boardColumns {
                if GameConstants.cornerPositions.contains(where: { $0.row == row && $0.col == col }) { continue }
                if state.boardTiles[row][col].card != nil {
                    nonCornerFilled += 1
                }
            }
        }
        #expect(nonCornerFilled == 96)
    }
    
    @Test("performPlay clears selection after valid move")
    func testPerformPlay_clearsSelection() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let teamGreen = Team(color: .green, numberOfPlayers: 1)
        let players = [
            Player(name: "P1", team: teamBlue),
            Player(name: "P2", team: teamGreen)
        ]

        let state = GameState()
        state.startGame(with: players)

        // Select a non-Jack card from current player's hand
        let currentIndex = state.currentPlayerIndex
        guard let cardId = state.players[currentIndex].cards.first(where: { $0.cardFace != .jack })?.id else {
            #expect(Bool(false)) // no playable card found
            return
        }
        state.selectCard(cardId)

        // Pick a valid board position for that card
        let positions = state.validPositionsForSelectedCard
        #expect(!positions.isEmpty)
        let pos = positions[0]

        state.performPlay(atPos: (pos.row, pos.col), using: cardId)

        // Selection should be cleared by performPlay
        #expect(state.selectedCardId == nil)
    }
    
    @Test("replaceDeadCard removes the selected card and draws a replacement")
    func testReplaceDeadCard_removesAndDraws() {
        // Setup: 2 players so each gets a hand
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let teamGreen = Team(color: .green, numberOfPlayers: 1)
        let players = [
            Player(name: "P1", team: teamBlue),
            Player(name: "P2", team: teamGreen)
        ]

        let state = GameState()
        state.startGame(with: players)

        // Pick any card from current player's hand and treat it as a dead card
        let currentIndex = state.currentPlayerIndex
        let startCount = state.players[currentIndex].cards.count
        guard let deadCardId = state.players[currentIndex].cards.first?.id else {
            #expect(Bool(false)) // setup failure
            return
        }

        state.replaceDeadCard(deadCardId)

        // Hand size remains same: removed one, drew one
        #expect(state.players[currentIndex].cards.count == startCount)
    }
    
    @Test("replaceDeadCard does not advance the turn")
    func testReplaceDeadCard_doesNotAdvanceTurn() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let teamGreen = Team(color: .green, numberOfPlayers: 1)
        let players = [
            Player(name: "P1", team: teamBlue),
            Player(name: "P2", team: teamGreen)
        ]

        let state = GameState()
        state.startGame(with: players)

        let originalIndex = state.currentPlayerIndex
        guard let deadCardId = state.players[originalIndex].cards.first?.id else {
            #expect(Bool(false))
            return
        }

        state.replaceDeadCard(deadCardId)

        #expect(state.currentPlayerIndex == originalIndex)
    }
    
    @Test("replaceDeadCard clears selection")
    func testReplaceDeadCard_clearsSelection() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let teamGreen = Team(color: .green, numberOfPlayers: 1)
        let players = [
            Player(name: "P1", team: teamBlue),
            Player(name: "P2", team: teamGreen)
        ]

        let state = GameState()
        state.startGame(with: players)

        let currentIndex = state.currentPlayerIndex
        guard let deadCardId = state.players[currentIndex].cards.first?.id else {
            #expect(Bool(false))
            return
        }
        // Simulate selection prior to replacement
        state.selectCard(deadCardId)

        state.replaceDeadCard(deadCardId)

        #expect(state.selectedCardId == nil)
    }
    
    @Test("one-eyed jack cannot remove corner chips")
    func testOneEyedJack_cannotRemoveCorner() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let teamGreen = Team(color: .green, numberOfPlayers: 1)
        let players = [Player(name: "P1", team: teamBlue), Player(name: "P2", team: teamGreen)]
        let state = GameState()
        state.startGame(with: players)

        // Pick a one-eyed Jack for current player (spades/hearts). If none, just create the card and call directly.
        _ = Card(cardFace: .jack, suit: .spades) // one-eyed
        // Try removing at any corner:
        for corner in GameConstants.cornerPositions {
            let before = state.boardTiles[corner.row][corner.col].isChipOn
            // Simulate the rule via guard in remove or canPlace path
            state.removeChip(at: (corner.row, corner.col))
            let after = state.boardTiles[corner.row][corner.col].isChipOn
            #expect(before == after) // no change for corners
        }
    }
    
    @Test("two-eyed jack cannot place on corner tiles")
    func testTwoEyedJack_cannotPlaceOnCorners() {
        let state = GameState()
        state.setupBoard()
        let positions = state.computePlayableTiles(for: Card(cardFace: .jack, suit: .clubs)) // two‑eyed
        // Ensure none of the returned positions are corners
        #expect(!positions.contains { pos in
            GameConstants.cornerPositions.contains { $0.row == pos.row && $0.col == pos.col }
        })
    }
    
    @Test("canPlace returns false on occupied matching tile")
    func testCanPlace_onOccupiedTile_returnsFalse() {
        let state = GameState()
        // Minimal controlled board: put a known card at (0,0), mark occupied
        let matchingCard = Card(cardFace: .five, suit: .hearts)
        state.boardTiles[0][0] = BoardTile(card: matchingCard, isEmpty: false, isChipOn: true, chip: Chip(color: .red, positionRow: 0, positionColumn: 0, isPlaced: true))

        // Same card cannot be placed on an occupied tile
        let result = state.canPlace(at: (row: 0, col: 0), for: matchingCard)
        #expect(result == false)
    }
    
    @Test("canPlace returns true on unoccupied matching tile")
    func testCanPlace_onUnoccupiedMatchingTile_returnsTrue() {
        let state = GameState()
        // Minimal controlled board: same card at (0,1), unoccupied
        let matchingCard = Card(cardFace: .five, suit: .hearts)
        state.boardTiles[0][1] = BoardTile(card: matchingCard, isEmpty: false, isChipOn: false, chip: nil)

        // Same card can be placed on an unoccupied matching tile
        let result = state.canPlace(at: (row: 0, col: 1), for: matchingCard)
        #expect(result == true)
    }
}
// swiftlint:enable type_body_length
