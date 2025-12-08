//
//  MoveType.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 08/12/2025.
//

import Foundation

/// Type of move performed during gameplay
enum MoveType: String, Codable, Equatable {
    case placeChip          // Regular chip placement
    case removeChip         // One-eyed Jack chip removal
    case deadCardReplace    // Dead card replacement
}
