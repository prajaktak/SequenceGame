//
//  SeatingRulesTests.swift
//  SequenceGameTests
//
//  Created on 2025-11-20.
//

import Testing
import Foundation
@testable import SequenceGame

@Suite("SeatingRules Tests")
struct SeatingRulesTests {
    
    // MARK: - Two Team Tests
    
    @Test("Interleaves two teams with equal players correctly")
    func interleavesTwoTeamsEqual() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 2)
        let teamRed = Team(color: .red, numberOfPlayers: 2)
        
        let players = [
            Player(name: "Blue1", team: teamBlue, cards: []),
            Player(name: "Blue2", team: teamBlue, cards: []),
            Player(name: "Red1", team: teamRed, cards: []),
            Player(name: "Red2", team: teamRed, cards: [])
        ]
        
        let teamOrder = [teamBlue.id, teamRed.id]
        let result = SeatingRules.interleaveByTeams(players, teamOrder: teamOrder)
        
        #expect(result.count == 4)
        #expect(result[0].name == "Blue1")
        #expect(result[1].name == "Red1")
        #expect(result[2].name == "Blue2")
        #expect(result[3].name == "Red2")
    }
    
    @Test("Interleaves two teams with unequal players")
    func interleavesTwoTeamsUnequal() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 3)
        let teamRed = Team(color: .red, numberOfPlayers: 2)
        
        let players = [
            Player(name: "Blue1", team: teamBlue, cards: []),
            Player(name: "Blue2", team: teamBlue, cards: []),
            Player(name: "Blue3", team: teamBlue, cards: []),
            Player(name: "Red1", team: teamRed, cards: []),
            Player(name: "Red2", team: teamRed, cards: [])
        ]
        
        let teamOrder = [teamBlue.id, teamRed.id]
        let result = SeatingRules.interleaveByTeams(players, teamOrder: teamOrder)
        
        #expect(result.count == 5)
        #expect(result[0].name == "Blue1")
        #expect(result[1].name == "Red1")
        #expect(result[2].name == "Blue2")
        #expect(result[3].name == "Red2")
        #expect(result[4].name == "Blue3")
    }
    
    @Test("Interleaves two teams with reverse unequal players")
    func interleavesTwoTeamsReverseUnequal() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 2)
        let teamRed = Team(color: .red, numberOfPlayers: 3)
        
        let players = [
            Player(name: "Blue1", team: teamBlue, cards: []),
            Player(name: "Blue2", team: teamBlue, cards: []),
            Player(name: "Red1", team: teamRed, cards: []),
            Player(name: "Red2", team: teamRed, cards: []),
            Player(name: "Red3", team: teamRed, cards: [])
        ]
        
        let teamOrder = [teamBlue.id, teamRed.id]
        let result = SeatingRules.interleaveByTeams(players, teamOrder: teamOrder)
        
        #expect(result.count == 5)
        #expect(result[0].name == "Blue1")
        #expect(result[1].name == "Red1")
        #expect(result[2].name == "Blue2")
        #expect(result[3].name == "Red2")
        #expect(result[4].name == "Red3")
    }
    
    // MARK: - Three Team Tests
    
    @Test("Interleaves three teams with equal players")
    func interleavesThreeTeamsEqual() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 2)
        let teamRed = Team(color: .red, numberOfPlayers: 2)
        let teamGreen = Team(color: .green, numberOfPlayers: 2)
        
        let players = [
            Player(name: "Blue1", team: teamBlue, cards: []),
            Player(name: "Blue2", team: teamBlue, cards: []),
            Player(name: "Red1", team: teamRed, cards: []),
            Player(name: "Red2", team: teamRed, cards: []),
            Player(name: "Green1", team: teamGreen, cards: []),
            Player(name: "Green2", team: teamGreen, cards: [])
        ]
        
        let teamOrder = [teamBlue.id, teamRed.id, teamGreen.id]
        let result = SeatingRules.interleaveByTeams(players, teamOrder: teamOrder)
        
        #expect(result.count == 6)
        #expect(result[0].name == "Blue1")
        #expect(result[1].name == "Red1")
        #expect(result[2].name == "Green1")
        #expect(result[3].name == "Blue2")
        #expect(result[4].name == "Red2")
        #expect(result[5].name == "Green2")
    }
    
    @Test("Interleaves three teams with unequal players")
    func interleavesThreeTeamsUnequal() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 3)
        let teamRed = Team(color: .red, numberOfPlayers: 2)
        let teamGreen = Team(color: .green, numberOfPlayers: 1)
        
        let players = [
            Player(name: "Blue1", team: teamBlue, cards: []),
            Player(name: "Blue2", team: teamBlue, cards: []),
            Player(name: "Blue3", team: teamBlue, cards: []),
            Player(name: "Red1", team: teamRed, cards: []),
            Player(name: "Red2", team: teamRed, cards: []),
            Player(name: "Green1", team: teamGreen, cards: [])
        ]
        
        let teamOrder = [teamBlue.id, teamRed.id, teamGreen.id]
        let result = SeatingRules.interleaveByTeams(players, teamOrder: teamOrder)
        
        #expect(result.count == 6)
        #expect(result[0].name == "Blue1")
        #expect(result[1].name == "Red1")
        #expect(result[2].name == "Green1")
        #expect(result[3].name == "Blue2")
        #expect(result[4].name == "Red2")
        #expect(result[5].name == "Blue3")
    }
    
    // MARK: - Edge Cases
    
    @Test("Returns original order for single team")
    func returnsSingleTeamUnchanged() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 4)
        let players = [
            Player(name: "Blue1", team: teamBlue, cards: []),
            Player(name: "Blue2", team: teamBlue, cards: []),
            Player(name: "Blue3", team: teamBlue, cards: []),
            Player(name: "Blue4", team: teamBlue, cards: [])
        ]
        
        let teamOrder = [teamBlue.id]
        let result = SeatingRules.interleaveByTeams(players, teamOrder: teamOrder)
        
        #expect(result.count == 4)
        for index in players.indices {
            #expect(result[index].name == players[index].name)
        }
    }
    
    @Test("Handles empty players array")
    func handlesEmptyPlayersArray() {
        let players: [Player] = []
        let teamOrder: [UUID] = []
        
        let result = SeatingRules.interleaveByTeams(players, teamOrder: teamOrder)
        
        #expect(result.isEmpty)
    }
    
    @Test("Handles single player")
    func handlesSinglePlayer() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let players = [Player(name: "Blue1", team: teamBlue, cards: [])]
        
        let teamOrder = [teamBlue.id]
        let result = SeatingRules.interleaveByTeams(players, teamOrder: teamOrder)
        
        #expect(result.count == 1)
        #expect(result[0].name == "Blue1")
    }
    
    @Test("Preserves in-team order")
    func preservesInTeamOrder() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 3)
        let players = [
            Player(name: "Blue-First", team: teamBlue, cards: []),
            Player(name: "Blue-Second", team: teamBlue, cards: []),
            Player(name: "Blue-Third", team: teamBlue, cards: [])
        ]
        
        let teamOrder = [teamBlue.id]
        let result = SeatingRules.interleaveByTeams(players, teamOrder: teamOrder)
        
        #expect(result[0].name == "Blue-First")
        #expect(result[1].name == "Blue-Second")
        #expect(result[2].name == "Blue-Third")
    }
    
    // MARK: - Team Order Tests
    
    @Test("Respects team order parameter")
    func respectsTeamOrder() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let teamRed = Team(color: .red, numberOfPlayers: 1)
        
        let players = [
            Player(name: "Blue1", team: teamBlue, cards: []),
            Player(name: "Red1", team: teamRed, cards: [])
        ]
        
        // Try Blue-Red order
        let blueRedOrder = [teamBlue.id, teamRed.id]
        let blueRedResult = SeatingRules.interleaveByTeams(players, teamOrder: blueRedOrder)
        
        #expect(blueRedResult[0].name == "Blue1")
        #expect(blueRedResult[1].name == "Red1")
        
        // Try Red-Blue order
        let redBlueOrder = [teamRed.id, teamBlue.id]
        let redBlueResult = SeatingRules.interleaveByTeams(players, teamOrder: redBlueOrder)
        
        #expect(redBlueResult[0].name == "Red1")
        #expect(redBlueResult[1].name == "Blue1")
    }
    
    @Test("Filters out teams with no players from teamOrder")
    func filtersEmptyTeams() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 2)
        let teamRed = Team(color: .red, numberOfPlayers: 0)  // No players
        let teamGreen = Team(color: .green, numberOfPlayers: 2)
        
        let players = [
            Player(name: "Blue1", team: teamBlue, cards: []),
            Player(name: "Blue2", team: teamBlue, cards: []),
            Player(name: "Green1", team: teamGreen, cards: []),
            Player(name: "Green2", team: teamGreen, cards: [])
        ]
        
        // Include red team in order even though it has no players
        let teamOrder = [teamBlue.id, teamRed.id, teamGreen.id]
        let result = SeatingRules.interleaveByTeams(players, teamOrder: teamOrder)
        
        #expect(result.count == 4)
        #expect(result[0].name == "Blue1")
        #expect(result[1].name == "Green1")
        #expect(result[2].name == "Blue2")
        #expect(result[3].name == "Green2")
    }
    
    // MARK: - Large Team Tests
    
    @Test("Handles maximum players per team")
    func handlesMaximumPlayersPerTeam() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 6)
        let teamRed = Team(color: .red, numberOfPlayers: 6)
        
        var players: [Player] = []
        for playerNumber in 1...6 {
            players.append(Player(name: "Blue\(playerNumber)", team: teamBlue, cards: []))
        }
        for playerNumber in 1...6 {
            players.append(Player(name: "Red\(playerNumber)", team: teamRed, cards: []))
        }
        
        let teamOrder = [teamBlue.id, teamRed.id]
        let result = SeatingRules.interleaveByTeams(players, teamOrder: teamOrder)
        
        #expect(result.count == 12)
        
        // Check interleaving pattern
        for pairIndex in 0..<6 {
            #expect(result[pairIndex * 2].name == "Blue\(pairIndex + 1)")
            #expect(result[pairIndex * 2 + 1].name == "Red\(pairIndex + 1)")
        }
    }
    
    @Test("Handles one player per team across multiple teams")
    func handlesOnePlayerPerTeamMultipleTeams() {
        let teamBlue = Team(color: .blue, numberOfPlayers: 1)
        let teamRed = Team(color: .red, numberOfPlayers: 1)
        let teamGreen = Team(color: .green, numberOfPlayers: 1)
        
        let players = [
            Player(name: "Blue1", team: teamBlue, cards: []),
            Player(name: "Red1", team: teamRed, cards: []),
            Player(name: "Green1", team: teamGreen, cards: [])
        ]
        
        let teamOrder = [teamBlue.id, teamRed.id, teamGreen.id]
        let result = SeatingRules.interleaveByTeams(players, teamOrder: teamOrder)
        
        #expect(result.count == 3)
        #expect(result[0].name == "Blue1")
        #expect(result[1].name == "Red1")
        #expect(result[2].name == "Green1")
    }
}
