//
//  ReplaySpeed.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 08/12/2025.
//

import Foundation

/// Playback speed for replay
enum ReplaySpeed: String, Codable, Equatable, CaseIterable {
    case normal = "1x"
    case fast = "2x"
    case veryFast = "4x"

    /// Time interval in seconds between moves
    var delayInterval: TimeInterval {
        switch self {
        case .normal:
            return 1.5
        case .fast:
            return 0.75
        case .veryFast:
            return 0.4
        }
    }

    /// Next speed in sequence
    var nextSpeed: ReplaySpeed {
        switch self {
        case .normal:
            return .fast
        case .fast:
            return .veryFast
        case .veryFast:
            return .normal
        }
    }
}
