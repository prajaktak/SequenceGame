//
//  SequenceGameTests.swift
//  SequenceGameTests
//
//  Created by Prajakta Kulkarni on 17/10/2025.
//

import Testing
@testable import SequenceGame
import SwiftUICore

struct SequenceGameTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test("Test Deck Size")
    func testDeckSize() {
        let deck = Deck()
        let numerOfCards = deck.cardsRemaining()
        #expect(numerOfCards == 52)
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
        let deck1 = Deck()
        let deck2 = Deck()
        var cardCount: Int = 0
        for _ in 0..<96 {
            if deck1.cardsRemaining() != 0 {
                _ = deck1.drawCardExceptJacks()
                cardCount += 1
            } else  if deck2.cardsRemaining() != 0 {
                _ = deck2.drawCardExceptJacks()
                cardCount += 1
            }
        }
        
        #expect(cardCount == 96)
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
        
        #expect(emptyTile == 4 && cardPlaced == 96 && deck1.cardsRemaining() == 0 && deck2.cardsRemaining() == 0)
    }
    
    @Test("one card Draw")
    func testOneCardDraw() {
        let deck1 = Deck()
        deck1.shuffle()
        _ = deck1.drawCard()
        #expect(deck1.cards.count == 51)
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
        
        #expect(deck1.cards.count == 27)
    }
}
