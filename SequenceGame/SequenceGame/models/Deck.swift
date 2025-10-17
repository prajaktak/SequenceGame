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
        for suit in Suit.allCases {
            for face in CardFace.allCases {
                cards.append(Card(cardFace: face, suit: suit))
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
        print("cardDrawCount \(cardDrawCount) card drawn: \(card.cardFace.displayValue) of (\(card.suit))")
        return card// or removeFirst() based on your logic
    }
    func drawCardExceptJacks() -> Card? {
        guard !cards.isEmpty else { return nil }
        if let lastCard = cards.last, lastCard.cardFace == .jack {
            cards.removeLast()
        }
        return cards.removeLast()
    }
    
    func cardsRemaining() -> Int {
        return cards.count
    }
}
