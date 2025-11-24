//
//  Deck.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//

class Deck: Codable {
    private(set) var cards: [Card] = []
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case cards
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cards, forKey: .cards)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cards = try container.decode([Card].self, forKey: .cards)
    }
    
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
    /// Draws a card from the deck, skipping over any Jacks.
    ///
    /// This method is specifically designed for board seeding, where Jacks should not appear
    /// on the game board. When a Jack is encountered, it is permanently removed from this deck
    /// and the method continues searching for a non-Jack card.
    ///
    /// - Important: This method permanently discards any Jacks it encounters. Do NOT use this
    ///   for the gameplay deck where players need to draw Jacks. Use `drawCard()` instead for
    ///   normal gameplay draws.
    ///
    /// - Note: Intended usage is with a temporary deck instance used solely for board setup,
    ///   not the main gameplay deck.
    ///
    /// - Returns: A non-Jack card if available, or `nil` if only Jacks remain or deck is empty.
    func drawCardExceptJacks() -> Card? {
        // Iterate through remaining cards to find a non-Jack
        var attemptsRemaining = cards.count
        
        while attemptsRemaining > 0 {
            guard let card = drawCard() else { return nil }
            
            if card.cardFace != .jack {
                return card
            }
            
            // Card was a Jack, discard it and try again
            attemptsRemaining -= 1
        }
        
        // All remaining cards are Jacks or deck is empty
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
