//
//  GameSettings.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 12/11/2025.
//

import Foundation

struct GameSettings {
    var numberOfTeams: Int = 2
    var playersPerTeam: Int = 1
    
    // Computed properties
    var totalPlayers: Int {
        numberOfTeams * playersPerTeam
    }
    
    var validPlayersPerTeamRange: ClosedRange<Int> {
        switch numberOfTeams {
        case 2:
            return 1...6  // Total: 2-12
        case 3:
            return 1...4  // Total: 3-12
        default:
            return 1...6
        }
    }
    
    var isValid: Bool {
        print("total player \(totalPlayers) valid players per team \( validPlayersPerTeamRange.contains(playersPerTeam))" )
        return totalPlayers <= 12 &&
        validPlayersPerTeamRange.contains(playersPerTeam)
    }
    
    // Validation message
    var validationMessage: String? {
        if totalPlayers > 12 {
            return "Maximum 12 players allowed. Current: \(totalPlayers)"
        }
        return nil
    }
    
    // Auto-adjust players per team if needed
    mutating func adjustPlayersPerTeamIfNeeded() {
        let maxPlayersPerTeam = 12 / numberOfTeams
        if playersPerTeam > maxPlayersPerTeam {
            playersPerTeam = maxPlayersPerTeam
        }
        // Ensure minimum
        if playersPerTeam < 1 {
            playersPerTeam = 1
        }
    }
}
