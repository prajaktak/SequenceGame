//
//  BoardTileTests.swift
//  SequenceGameTests
//
//  Created on 2025-11-20.
//

import Testing
import Foundation
@testable import SequenceGame

@Suite("BoardTile Tests")
struct BoardTileTests {
    
    // MARK: - Initialization Tests
    
    @Test("BoardTile initialization creates unique IDs")
    func boardTileHasUniqueIds() {
        let tile1 = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        let tile2 = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        
        #expect(tile1.id != tile2.id, "Each BoardTile should have a unique ID")
    }
    
    @Test("BoardTile stores card correctly")
    func boardTileStoresCard() {
        let card = Card(cardFace: .ace, suit: .hearts)
        let tile = BoardTile(card: card, isEmpty: false, isChipOn: false, chip: nil)
        
        #expect(tile.card?.cardFace == .ace)
        #expect(tile.card?.suit == .hearts)
        #expect(tile.isEmpty == false)
    }
    
    @Test("BoardTile handles empty corner tiles")
    func boardTileHandlesEmptyCorners() {
        let tile = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        
        #expect(tile.isEmpty == true)
        #expect(tile.card == nil)
        #expect(tile.chip == nil)
        #expect(tile.isChipOn == false)
    }
    
    @Test("BoardTile stores chip placement")
    func boardTileStoresChip() {
        let chip = Chip(color: .blue)
        var tile = BoardTile(
            card: Card(cardFace: .king, suit: .spades),
            isEmpty: false,
            isChipOn: false,
            chip: nil
        )
        
        tile.chip = chip
        tile.isChipOn = true
        
        #expect(tile.chip?.color == .blue)
        #expect(tile.isChipOn == true)
    }
    
    // MARK: - Mutation Tests
    
    @Test("BoardTile chip can be replaced")
    func boardTileChipCanBeReplaced() {
        let blueChip = Chip(color: .blue)
        let redChip = Chip(color: .red)
        
        var tile = BoardTile(
            card: Card(cardFace: .queen, suit: .diamonds),
            isEmpty: false,
            isChipOn: true,
            chip: blueChip
        )
        
        tile.chip = redChip
        
        #expect(tile.chip?.color == .red)
    }
    
    @Test("BoardTile chip can be removed")
    func boardTileChipCanBeRemoved() {
        let chip = Chip(color: .green)
        var tile = BoardTile(
            card: Card(cardFace: .seven, suit: .clubs),
            isEmpty: false,
            isChipOn: true,
            chip: chip
        )
        
        tile.chip = nil
        tile.isChipOn = false
        
        #expect(tile.chip == nil)
        #expect(tile.isChipOn == false)
    }
    
    @Test("BoardTile card remains when chip is placed")
    func boardTileCardRemainsWithChip() {
        let card = Card(cardFace: .jack, suit: .hearts)
        let chip = Chip(color: .blue)
        
        var tile = BoardTile(card: card, isEmpty: false, isChipOn: false, chip: nil)
        tile.chip = chip
        tile.isChipOn = true
        
        #expect(tile.card?.cardFace == .jack)
        #expect(tile.card?.suit == .hearts)
        #expect(tile.chip?.color == .blue)
    }
    
    // MARK: - State Combination Tests
    
    @Test("BoardTile can have card without chip")
    func boardTileCardWithoutChip() {
        let card = Card(cardFace: .ten, suit: .spades)
        let tile = BoardTile(card: card, isEmpty: false, isChipOn: false, chip: nil)
        
        #expect(tile.card != nil)
        #expect(tile.chip == nil)
        #expect(tile.isChipOn == false)
        #expect(tile.isEmpty == false)
    }
    
    @Test("BoardTile empty state is consistent")
    func boardTileEmptyStateConsistent() {
        let tile = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        
        // Empty tiles should have no card and no chip
        #expect(tile.isEmpty == true)
        #expect(tile.card == nil)
        #expect(tile.chip == nil)
    }
    
    // MARK: - Different Card Types
    
    @Test("BoardTile handles all card faces")
    func boardTileHandlesAllCardFaces() {
        let faces: [CardFace] = [.ace, .two, .three, .four, .five, .six, .seven,
                                  .eight, .nine, .ten, .jack, .queen, .king]
        
        for face in faces {
            let card = Card(cardFace: face, suit: .hearts)
            let tile = BoardTile(card: card, isEmpty: false, isChipOn: false, chip: nil)
            
            #expect(tile.card?.cardFace == face)
        }
    }
    
    @Test("BoardTile handles all suits")
    func boardTileHandlesAllSuits() {
        let suits: [Suit] = [.hearts, .diamonds, .clubs, .spades]
        
        for suit in suits {
            let card = Card(cardFace: .ace, suit: suit)
            let tile = BoardTile(card: card, isEmpty: false, isChipOn: false, chip: nil)
            
            #expect(tile.card?.suit == suit)
        }
    }
    
    @Test("BoardTile handles all team colors")
    func boardTileHandlesAllTeamColors() {
        let colors: [TeamColor] = [.blue, .red, .green]
        
        for color in colors {
            let chip = Chip(color: color)
            let tile = BoardTile(
                card: Card(cardFace: .ace, suit: .hearts),
                isEmpty: false,
                isChipOn: true,
                chip: chip
            )
            
            #expect(tile.chip?.color == color)
        }
    }
    
    // MARK: - Identifiable Conformance
    
    @Test("BoardTile conforms to Identifiable")
    func boardTileIsIdentifiable() {
        let tile = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        let id = tile.id
        
        // ID should be UUID type
        #expect(type(of: id) == UUID.self)
    }
    
    @Test("BoardTile IDs are stable")
    func boardTileIDsAreStable() {
        let tile = BoardTile(
            card: Card(cardFace: .king, suit: .diamonds),
            isEmpty: false,
            isChipOn: false,
            chip: nil
        )
        
        let id1 = tile.id
        let id2 = tile.id
        
        #expect(id1 == id2, "BoardTile ID should remain constant")
    }
}
