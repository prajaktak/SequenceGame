//
//  DoubleDeck.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 31/10/2025.
//

class DoubleDeck: Codable {
    private var deck1: Deck
    private var deck2: Deck
    var cardDrawCount: Int = 0
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case deck1, deck2, cardDrawCount
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(deck1, forKey: .deck1)
        try container.encode(deck2, forKey: .deck2)
        try container.encode(cardDrawCount, forKey: .cardDrawCount)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        deck1 = try container.decode(Deck.self, forKey: .deck1)
        deck2 = try container.decode(Deck.self, forKey: .deck2)
        cardDrawCount = try container.decode(Int.self, forKey: .cardDrawCount)
    }
    
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
