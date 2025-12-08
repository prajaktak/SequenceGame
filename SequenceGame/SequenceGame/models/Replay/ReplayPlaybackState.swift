//
//  ReplayPlaybackState.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 08/12/2025.
//

import Foundation

/// State of replay playback
enum ReplayPlaybackState: String, Codable, Equatable {
    case stopped    // Replay not started or has ended
    case playing    // Replay is currently playing
    case paused     // Replay is paused
}
