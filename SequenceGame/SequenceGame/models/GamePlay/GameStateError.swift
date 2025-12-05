//
//  GameStateError.swift
//  SequenceGame
//
//  Created on 2025-11-25.
//

import Foundation

/// Errors that can occur during game state operations.
enum GameStateError: Error, LocalizedError {
    case cannotRestartWithoutPlayers
    
    var errorDescription: String? {
        switch self {
        case .cannotRestartWithoutPlayers:
            return "Can not restart game due to technical issue. Please start new game"
        }
    }
}
