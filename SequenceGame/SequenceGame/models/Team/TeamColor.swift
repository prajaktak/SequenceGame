//
//  TeamColor.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 19/11/2025.
//

import Foundation

/// Identifies a team by color in a platform-agnostic way.
///
/// Use this enum in models instead of SwiftUI.Color to maintain separation of concerns.
/// Map to actual UI colors in views using the theme system.
enum TeamColor: Codable, CaseIterable, Equatable {
    case blue
    case green
    case red
    case noTeam 
    
    /// Human-readable display name for the team color.
    var stringValue: String {
        switch self {
        case .blue: return "teamBlue"
        case .green: return "teamGreen"
        case .red: return "teamRed"
        case .noTeam: return "No Team"
        }
    }
    var accessibilityName: String {
        switch self {
        case .blue: return "Blue"
        case .green: return "Green"
        case .red: return "Red"
        case .noTeam: return "No team"
        }
    }
}
