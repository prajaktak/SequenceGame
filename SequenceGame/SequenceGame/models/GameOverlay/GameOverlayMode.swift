//
//  GameOverlayMode.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 29/10/2025.
//

import Foundation

enum GameOverlayMode: Codable, Equatable {
    case turnStart                     // Appears at the start of a turn
    case cardSelected                  // After a player taps a card in hand
    case deadCard                      // Selected card is dead; offer discard + draw
    case postPlacement                 // Chip placed; prompt to draw and end turn
    case jackPlaceAnywhere             // Two‑eyed Jack flow
    case jackRemoveChip                // One‑eyed Jack flow
    case paused                        // Pause/options
    case gameOver                      // Winner dialog
    case aITurnInProgress              // AI Player turn progress 
}
