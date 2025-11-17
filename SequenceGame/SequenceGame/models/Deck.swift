//
//  Deck.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//

class Deck {
    private(set) var cards: [Card] = []
    
    init() {
        resetDeck()
    }
    
    func resetDeck() {
        cards = []
        // Create standard 52-card deck
        for suit in Suit.allCases {
            for face in CardFace.allCases {
                if suit != .empty && face != .empty {
                    cards.append(Card(cardFace: face, suit: suit))
                }
            }
        }
    }
    
    func shuffle() {
        cards.shuffle()
    }
    
    func drawCard() -> Card? {
        guard !cards.isEmpty else { return nil }
        return cards.removeLast()
    }
    func drawCardExceptJacks() -> Card? {
        // Iterate through remaining cards to find a non-Jack
        var attemptsRemaining = cards.count
        
        while attemptsRemaining > 0 {
            guard let card = drawCard() else { return nil }
            
            if card.cardFace != .jack {
                return card
            }
            
            // Card was a Jack, try again
            attemptsRemaining -= 1
        }
        
        // All remaining cards are Jacks
        return nil
    }
    
    func cardsRemaining() -> Int {
        return cards.count
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
    
#if DEBUG
    /// Test helper: Replace deck with custom cards
    func setCards(_ newCards: [Card]) {
        self.cards = newCards
    }
#endif
}
