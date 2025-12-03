//
//  Suit.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//
import Foundation

enum Suit: String, Codable, CaseIterable {
    case hearts = "heart"
    case spades = "spade"
    case diamonds = "diamond"
    case clubs = "club"
    case empty = " "
    
    var systemImageName: String {
        switch self {
        case .hearts: return "heart.fill"
        case .spades: return "suit.spade.fill"
        case .diamonds: return "suit.diamond.fill"
        case .clubs: return "suit.club.fill"
        case .empty: return "circle.fill"
        }
    }
    
    var accessibilityName: String {
        switch self {
        case .hearts: return "Hearts"
        case .spades: return "Spades"
        case .diamonds: return "Diamonds"
        case .clubs: return "Clubs"
        case .empty: return "Empty"
        }
    }
}
