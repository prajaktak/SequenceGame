//
//  Card.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//

import Foundation

struct Card: Identifiable {
    let id = UUID()
    let cardFace: CardFace
    let suit: Suit
}
