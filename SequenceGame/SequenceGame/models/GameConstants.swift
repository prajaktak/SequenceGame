//
//  GameConstants.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 29/10/2025.
//

import Foundation

enum GameConstants {
    // MARK: - Board Dimensions
    static let boardRows = 10
    static let boardColumns = 10
    
    // MARK: - Corner Positions (Wild Spaces)
    static let cornerPositions: [Position] = [
        Position(row: 0, col: 0),
        Position(row: 0, col: 9),
        Position(row: 9, col: 0),
        Position(row: 9, col: 9)
    ]
    
    // MARK: - Team Configuration
    
    /// Available team colors. Add more colors here to support additional teams.
    ///
    /// The number of colors in this array determines the maximum number of teams
    /// that can be created in a game.
    static let teamColors: [TeamColor] = [TeamColor.blue, TeamColor.green, TeamColor.red]
    
    /// Maximum number of teams supported, determined by available team colors.
    ///
    /// This value is computed from `teamColors.count` to ensure they stay synchronized.
    /// To support more teams, add additional colors to the `teamColors` array.
    static var maxTeams: Int {
        return teamColors.count
    }
    
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
        // MARK: - Universal UI Constants
        
        /// Universal corner radius for most UI elements (cards, tiles, overlays)
        static let universalCornerRadius: CGFloat = 8
        
        /// Universal border width for most UI elements (cards, buttons, overlays)
        static let universalBorderWidth: CGFloat = 1
        
        /// Thicker border for emphasis (selected cards, valid moves)
        static let emphasizedBorderWidth: CGFloat = 3
        
        // MARK: - Corner Radius (Semantic Naming)
        static let buttonCornerRadius: CGFloat = 12        // Buttons
        static let cardCornerRadius: CGFloat = 8           // Cards and tiles
        static let tileHighlightCornerRadius: CGFloat = 4  // Sequence highlights
        static let overlayCornerRadius: CGFloat = 16       // Overlays and modals
        
        // MARK: - Border Widths (Semantic Naming)
        static let standardBorderWidth: CGFloat = 1        // Default borders
        static let cardBorderWidth: CGFloat = 2            // Card borders
        static let highlightBorderWidth: CGFloat = 3       // Highlights, selections
        
        // MARK: - Board (Exception - Larger for Visual Hierarchy)
        static let boardBorderThickness: CGFloat = 6       // Keep larger
        static let boardCornerRadius: CGFloat = 12         // Keep larger
        
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
        static let tileWidth: CGFloat = 32
        static let tileHeight: CGFloat = 50
        
        // Board Padding
        static let boardPadding: CGFloat = 12
        static let boardTopPadding: CGFloat = 20
        static let boardBottomPadding: CGFloat = 20
        
        // Board View Specific
        static let cardAspectRatio: CGFloat = 1.6
        static let boardContentInsetTop: CGFloat = 2
        static let boardContentInsetBottom: CGFloat = 2
        static let boardContentInsetLeading: CGFloat = 0
        static let boardContentInsetTrailing: CGFloat = 0
        
        // Chip Indicators
        static let validPositionIndicatorScale: CGFloat = 0.4
        static let validPositionShadowRadius: CGFloat = 6
        static let validPositionShadowY: CGFloat = 2
        static let validPositionBorderWidth: CGFloat = 2
        
        // Overlay Spacing
        static let overlayContentSpacing: CGFloat = 8
        static let overlayGameOverSpacing: CGFloat = 12
        
        // Font Sizes
        static let overlayInstructionFontSize: CGFloat = 13
        static let overlayHelpIconSize: CGFloat = 22
        static let overlayGameOverTitleSize: CGFloat = 24
        static let overlayGameOverSubtitleSize: CGFloat = 18
        
        // Hand View
        static let handHorizontalInsets: CGFloat = 24
        static let handVerticalInsets: CGFloat = 8
        static let handSpacing: CGFloat = 8
        static let handMinCardWidth: CGFloat = 44
        static let handMaxCardWidth: CGFloat = 54
        static let handCardAspect: CGFloat = 1.5
        static let handCardCornerRadius: CGFloat = 6
        static let handCardBorderWidth: CGFloat = 2
        static let handCardSelectedOffset: CGFloat = -8
        static let handCardSelectedScale: CGFloat = 1.06
        static let handCardShadowRadius: CGFloat = 6
        static let handCardShadowY: CGFloat = 3
        static let handCardShadowOpacity: Double = 0.25
        
        // Footer/Misc
        static let footerBottomPadding: CGFloat = 20
    }
    
    // MARK: - Animation Timing
    struct Animation {
        static let shimmerDuration: Double = 0.1
        static let sequenceHighlightDuration: Double = 0.3
        static let cardSelectionDuration: Double = 0.15
        static let playSpringResponse: Double = 0.25
        static let playSpringDamping: Double = 0.7
        static let sequenceSpringResponse: Double = 0.5
        static let sequenceSpringDamping: Double = 0.6
        
        // Overlay
        static let overlayAutoDismissDelay: Double = 2.0
        static let overlaySpringResponse: Double = 0.35
        static let overlaySpringDamping: Double = 0.8
        
        // Navigation
        static let navigationDismissDelay: Double = 0.1  // Add this
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
