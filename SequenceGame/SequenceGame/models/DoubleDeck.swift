//
//  DoubleDeck.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 31/10/2025.
//

class DoubleDeck {
    private var deck1: Deck
    private var deck2: Deck
    var cardDrawCount: Int = 0
    
    init() {
        deck1 = Deck()
        deck2 = Deck()
    }
    
    func resetDeck() {
        deck1.resetDeck()
        deck2.resetDeck()
        cardDrawCount = 0
    }
    
    func shuffle() {
        // Shuffle each deck separately
        // Note: For true randomization of all 104 cards together,
        // we would need Deck to expose a method to add cards back
        deck1.shuffle()
        deck2.shuffle()
    }
    
    func drawCard() -> Card? {
        if let card = deck1.drawCard() {
            cardDrawCount += 1
            return card
        } else if let card = deck2.drawCard() {
            cardDrawCount += 1
            return card
        }
        return nil
    }
    
    func drawCardExceptJacks() -> Card? {
        if let card = deck1.drawCardExceptJacks() {
            return card
        } else if let card = deck2.drawCardExceptJacks() {
            return card
        }
        return nil
    }
    
    func cardsRemaining() -> Int {
        return deck1.cardsRemaining() + deck2.cardsRemaining()
    }
    
    func deal(handCount: Int, to players: inout [Player]) {
        guard handCount > 0, !players.isEmpty else { return }
        for _ in 0..<handCount {
            for playerIndex in players.indices {
                if let card = drawCard() {
                    players[playerIndex].cards.append(card)
                }
            }
        }
    }
}
