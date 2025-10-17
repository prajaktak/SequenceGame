//
//  Suit.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//
import Foundation
import SwiftUI

public enum Suit: CaseIterable {
    case hearts, spades, diamonds, clubs
    
    var systemImageName: String {
        switch self {
        case .hearts: return "heart.fill"
        case .spades: return "suit.spade.fill"
        case .diamonds: return "suit.diamond.fill"
        case .clubs: return "suit.club.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .hearts, .diamonds:
            return .red
        case .spades, .clubs:
            return .black
        }
    }
}
