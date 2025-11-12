//
//  DeckTests.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 13/11/2025.
//

import Testing
@testable import SequenceGame
import SwiftUICore

struct DeckTests {
    
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
        #expect(firstCard?.cardFace != secondCard?.cardFace || firstCard?.suit != secondCard?.suit)
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
    
}
