//
//  GameSettingsTests.swift
//  SequenceGameTests
//
//  Created on 2025-11-20.
//

import Testing
import Foundation
@testable import SequenceGame

@Suite("GameSettings Tests")
struct GameSettingsTests {
    
    // MARK: - Initialization Tests
    
    @Test("Default settings are valid")
    func defaultSettingsAreValid() {
        let settings = GameSettings()
        
        #expect(settings.numberOfTeams == 2)
        #expect(settings.playersPerTeam == 1)
        #expect(settings.totalPlayers == 2)
        #expect(settings.isValid == true)
    }
    
    // MARK: - Computed Property Tests
    
    @Test("Total players computed correctly")
    func totalPlayersComputed() {
        var settings = GameSettings()
        settings.numberOfTeams = 3
        settings.playersPerTeam = 4
        
        #expect(settings.totalPlayers == 12)
    }
    
    @Test("Total players computed for 2 teams with 6 players each")
    func totalPlayersMaxConfiguration() {
        var settings = GameSettings()
        settings.numberOfTeams = 2
        settings.playersPerTeam = 6
        
        #expect(settings.totalPlayers == 12)
    }
    
    @Test("Total players computed for minimum configuration")
    func totalPlayersMinConfiguration() {
        var settings = GameSettings()
        settings.numberOfTeams = 2
        settings.playersPerTeam = 1
        
        #expect(settings.totalPlayers == 2)
    }
    
    // MARK: - Valid Range Tests
    
    @Test("Valid players per team range for 2 teams")
    func validRangeForTwoTeams() {
        var settings = GameSettings()
        settings.numberOfTeams = 2
        
        #expect(settings.validPlayersPerTeamRange == 1...6)
    }
    
    @Test("Valid players per team range for 3 teams")
    func validRangeForThreeTeams() {
        var settings = GameSettings()
        settings.numberOfTeams = 3
        
        #expect(settings.validPlayersPerTeamRange == 1...4)
    }
    
    @Test("Valid players per team range for other team counts")
    func validRangeForOtherTeamCounts() {
        var settings = GameSettings()
        
        // Test various team counts (fallback to default)
        for teamCount in [4, 5, 6] {
            settings.numberOfTeams = teamCount
            #expect(settings.validPlayersPerTeamRange == 1...6)
        }
    }
    
    // MARK: - Validation Tests
    
    @Test("isValid returns true for valid 2-team configuration")
    func isValidForTwoTeams() {
        var settings = GameSettings()
        settings.numberOfTeams = 2
        settings.playersPerTeam = 3  // Total = 6
        
        #expect(settings.isValid == true)
    }
    
    @Test("isValid returns true for valid 3-team configuration")
    func isValidForThreeTeams() {
        var settings = GameSettings()
        settings.numberOfTeams = 3
        settings.playersPerTeam = 4  // Total = 12
        
        #expect(settings.isValid == true)
    }
    
    @Test("isValid returns false when total exceeds 12")
    func invalidWhenExceeds12Players() {
        var settings = GameSettings()
        settings.numberOfTeams = 3
        settings.playersPerTeam = 5  // Total = 15
        
        #expect(settings.isValid == false)
    }
    
    @Test("isValid returns false when players per team exceeds range")
    func invalidWhenExceedsRange() {
        var settings = GameSettings()
        settings.numberOfTeams = 2
        settings.playersPerTeam = 7  // Max is 6 for 2 teams
        
        #expect(settings.isValid == false)
    }
    
    @Test("isValid returns false when players per team below range")
    func invalidWhenBelowRange() {
        var settings = GameSettings()
        settings.numberOfTeams = 2
        settings.playersPerTeam = 0  // Min is 1
        
        #expect(settings.isValid == false)
    }
    
    @Test("isValid handles boundary case: exactly 12 players")
    func isValidAtBoundary() {
        var settings = GameSettings()
        settings.numberOfTeams = 2
        settings.playersPerTeam = 6  // Total = 12 (max)
        
        #expect(settings.isValid == true)
    }
    
    @Test("isValid handles boundary case: 13 players")
    func invalidJustAboveBoundary() {
        var settings = GameSettings()
        settings.numberOfTeams = 2
        settings.playersPerTeam = 7  // Total = 14 (over max)
        
        #expect(settings.isValid == false)
    }
    
    // MARK: - Validation Message Tests
    
    @Test("Validation message for exceeding max players")
    func validationMessageForMaxPlayers() throws {
        var settings = GameSettings()
        settings.numberOfTeams = 3
        settings.playersPerTeam = 5  // Total = 15
        
        let message = try #require(settings.validationMessage)
        #expect(message.contains("Maximum 12 players"))
        #expect(message.contains("15"))
    }
    
    @Test("No validation message when valid")
    func noValidationMessageWhenValid() {
        var settings = GameSettings()
        settings.numberOfTeams = 2
        settings.playersPerTeam = 3
        
        #expect(settings.validationMessage == nil)
    }
    
    @Test("No validation message at maximum capacity")
    func noValidationMessageAtMax() {
        var settings = GameSettings()
        settings.numberOfTeams = 2
        settings.playersPerTeam = 6  // Total = 12
        
        #expect(settings.validationMessage == nil)
    }
    
    // MARK: - Auto-Adjustment Tests
    
    @Test("Auto-adjusts players per team when exceeds maximum")
    func autoAdjustsPlayersPerTeamDownward() {
        var settings = GameSettings()
        settings.numberOfTeams = 2
        settings.playersPerTeam = 10  // Would exceed 12
        
        settings.adjustPlayersPerTeamIfNeeded()
        
        #expect(settings.playersPerTeam == 6)  // Max for 2 teams
        #expect(settings.totalPlayers == 12)
    }
    
    @Test("Auto-adjusts players per team for 3 teams")
    func autoAdjustsForThreeTeams() {
        var settings = GameSettings()
        settings.numberOfTeams = 3
        settings.playersPerTeam = 10  // Would be 30 total
        
        settings.adjustPlayersPerTeamIfNeeded()
        
        #expect(settings.playersPerTeam == 4)  // Max: 12 / 3 = 4
        #expect(settings.totalPlayers == 12)
    }
    
    @Test("Auto-adjusts ensures minimum of 1 player per team")
    func autoAdjustsMinimum() {
        var settings = GameSettings()
        settings.playersPerTeam = 0
        
        settings.adjustPlayersPerTeamIfNeeded()
        
        #expect(settings.playersPerTeam == 1)
    }
    
    @Test("Auto-adjusts handles negative values")
    func autoAdjustsNegativeValues() {
        var settings = GameSettings()
        settings.playersPerTeam = -5
        
        settings.adjustPlayersPerTeamIfNeeded()
        
        #expect(settings.playersPerTeam == 1)
    }
    
    @Test("Auto-adjust does not change valid settings")
    func autoAdjustDoesNotChangeValid() {
        var settings = GameSettings()
        settings.numberOfTeams = 2
        settings.playersPerTeam = 3  // Valid
        
        settings.adjustPlayersPerTeamIfNeeded()
        
        #expect(settings.playersPerTeam == 3)  // Should remain unchanged
    }
    
    // MARK: - Edge Case Tests
    
    @Test("Edge case: 2 teams with 1 player each")
    func edgeCaseTwoTeamsOnePlayer() {
        var settings = GameSettings()
        settings.numberOfTeams = 2
        settings.playersPerTeam = 1
        
        #expect(settings.totalPlayers == 2)
        #expect(settings.isValid == true)
    }
    
    @Test("Edge case: 2 teams with 6 players each")
    func edgeCaseTwoTeamsSixPlayers() {
        var settings = GameSettings()
        settings.numberOfTeams = 2
        settings.playersPerTeam = 6
        
        #expect(settings.totalPlayers == 12)
        #expect(settings.isValid == true)
    }
    
    @Test("Edge case: 3 teams with 1 player each")
    func edgeCaseThreeTeamsOnePlayer() {
        var settings = GameSettings()
        settings.numberOfTeams = 3
        settings.playersPerTeam = 1
        
        #expect(settings.totalPlayers == 3)
        #expect(settings.isValid == true)
    }
    
    @Test("Edge case: 3 teams with 4 players each")
    func edgeCaseThreeTeamsFourPlayers() {
        var settings = GameSettings()
        settings.numberOfTeams = 3
        settings.playersPerTeam = 4
        
        #expect(settings.totalPlayers == 12)
        #expect(settings.isValid == true)
    }
    
    // MARK: - Boundary Tests
    
    @Test("Boundary: 12 players is valid")
    func boundaryTwelvePlayers() {
        var settings = GameSettings()
        settings.numberOfTeams = 2
        settings.playersPerTeam = 6
        
        #expect(settings.isValid == true)
        #expect(settings.validationMessage == nil)
    }
    
    @Test("Boundary: 13 players is invalid")
    func boundaryThirteenPlayers() {
        var settings = GameSettings()
        settings.numberOfTeams = 2
        settings.playersPerTeam = 7  // Would be 14 total
        
        #expect(settings.isValid == false)
    }
    
    // MARK: - Multiple Adjustments
    
    @Test("Multiple adjustments work correctly")
    func multipleAdjustments() {
        var settings = GameSettings()
        
        // First adjustment
        settings.numberOfTeams = 2
        settings.playersPerTeam = 10
        settings.adjustPlayersPerTeamIfNeeded()
        #expect(settings.playersPerTeam == 6)
        
        // Second adjustment
        settings.numberOfTeams = 3
        settings.adjustPlayersPerTeamIfNeeded()
        #expect(settings.playersPerTeam == 4)
        
        // Third adjustment
        settings.numberOfTeams = 4
        settings.adjustPlayersPerTeamIfNeeded()
        #expect(settings.playersPerTeam == 3)
    }
    
    // MARK: - Realistic Game Configurations
    
    @Test("Realistic: Standard 2v2 game")
    func realisticTwoVersusTwo() {
        var settings = GameSettings()
        settings.numberOfTeams = 2
        settings.playersPerTeam = 2
        
        #expect(settings.totalPlayers == 4)
        #expect(settings.isValid == true)
    }
    
    @Test("Realistic: 3-team game with 2 players each")
    func realisticThreeTeamsTwoPlayers() {
        var settings = GameSettings()
        settings.numberOfTeams = 3
        settings.playersPerTeam = 2
        
        #expect(settings.totalPlayers == 6)
        #expect(settings.isValid == true)
    }
    
    @Test("Realistic: Large 3v3v3 game")
    func realisticThreeVersusThreeVersusThree() {
        var settings = GameSettings()
        settings.numberOfTeams = 3
        settings.playersPerTeam = 3
        
        #expect(settings.totalPlayers == 9)
        #expect(settings.isValid == true)
    }
}
