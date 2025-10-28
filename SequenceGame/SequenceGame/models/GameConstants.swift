//
//  GameConstants.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 29/10/2025.
//

import SwiftUI

enum GameConstants {
    // MARK: - Board Dimensions
    static let boardRows = 10
    static let boardColumns = 10
    
    // MARK: - Corner Positions (Wild Spaces)
    static let cornerPositions: [(row: Int, col: Int)] = [
        (0, 0),
        (0, 9),
        (9, 0),
        (9, 9)
    ]
    
    // MARK: - Team Configuration
    static let maxTeams = 4
    static let teamColors: [Color] = [.blue, .green, .red, .yellow]
    
    // MARK: - Cards Per Player (Based on Player Count)
    static func cardsPerPlayer(playerCount: Int) -> Int {
        switch playerCount {
        case 2:
            return 7
        case 3, 4:
            return 6
        case 6:
            return 5
        case 8, 9:
            return 4
        case 10, 12:
            return 3
        default:
            return 0
        }
    }
    
    // MARK: - Win Conditions
    static let sequencesToWin = 2
    static let sequenceLength = 5
    
    // MARK: - Deck Configuration
    static let totalCardsInDoubleDeck = 104 // 52 cards × 2 decks
    
    // MARK: - UI Sizing
    struct UISizing {
        // Button Heights
        static let primaryButtonHeight: CGFloat = 56
        static let secondaryButtonHeight: CGFloat = 50
        
        // Corner Radius
        static let largeCornerRadius: CGFloat = 16
        static let mediumCornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
        
        // Padding
        static let horizontalPadding: CGFloat = 24
        static let verticalSpacing: CGFloat = 16
        static let largeSpacing: CGFloat = 40
        
        // Icon Sizes
        static let iconSizeLarge: CGFloat = 28
        static let iconSizeMedium: CGFloat = 20
        static let iconSizeSmall: CGFloat = 16
        
        // Card Dimensions
        static let tileWidth: CGFloat = 28
        static let tileHeight: CGFloat = 45
        
        // Board Padding
        static let boardPadding: CGFloat = 12
        static let boardTopPadding: CGFloat = 20
        static let boardBottomPadding: CGFloat = 20
    }
    
    // MARK: - Star Arch Constants
    struct StarArch {
        static let starCount = 5
        static let starSpacing: CGFloat = 10
        static let archHeight: CGFloat = 60
        
        static func starSize(index: Int) -> CGFloat {
            switch index {
            case 0: return 20
            case 1: return 30
            case 2: return 50  // peak
            case 3: return 30
            case 4: return 20
            default: return 40
            }
        }
        
        static func starOffset(index: Int) -> CGFloat {
            switch index {
            case 0: return 5
            case 1: return -5
            case 2: return -15  // center, highest
            case 3: return -5
            case 4: return 5
            default: return 0
            }
        }
    }
}
