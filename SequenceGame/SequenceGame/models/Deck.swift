//
//  Deck.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//

class Deck {
    var cardDrawCount: Int = 0
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
        guard !cards.isEmpty else {
            return nil
        }
        cardDrawCount += 1
        let card = cards.removeLast()
        return card// or removeFirst() based on your logic
    }
    func drawCardExceptJacks() -> Card? {
        guard !cards.isEmpty else { return nil }
        let card = cards.removeLast()
        if card.cardFace != .jack {
            return card
        } else {
            return drawCardExceptJacks()
        }
        let card = cards.removeLast()
        if card.cardFace != .jack {
            return card
        } else {
            return drawCardExceptJacks()
        }
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
