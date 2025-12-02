//
//  AIDifficulty.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 01/12/2025.
//
import Foundation

enum AIDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    /// User-friendly description of the difficulty level
    var description: String {
        switch self {
        case .easy:
            return "Makes random moves. Great for beginners!"
        case .medium:
            return "Builds sequences and blocks opponents. A good challenge!"
        case .hard:
            return "Strategic and challenging. Will try to win!"
        }
    }
    
    /// Thinking delay in seconds (makes AI feel more natural)
    var thinkingDelay: TimeInterval {
        switch self {
        case .easy:
            return 0.5
        case .medium:
            return 1.0
        case .hard:
            return 1.5
        }
    }
}
