//
//  PlayerConfig.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 01/12/2025.
//

import Foundation

/// Configuration for a player setup in GameSettings
struct PlayerConfig: Equatable, Hashable {
    var isAI: Bool = false
    var difficulty: AIDifficulty = .easy
}
