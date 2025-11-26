//
//  Card.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//

import Foundation

struct Card: Codable, Identifiable, Equatable {
    var id = UUID()
    let cardFace: CardFace
    let suit: Suit
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.cardFace == rhs.cardFace && lhs.suit == rhs.suit
    }
}
