//
//  SeatingRules.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 29/10/2025.
//

import Foundation

enum SeatingRules {
    // Round‑robin interleave by team, preserving in‑team order.
    // teamOrder defines the order teams appear around the table.
    static func interleaveByTeams(_ players: [Player], teamOrder: [UUID]) -> [Player] {
        // Bucket players by team in input order
        var teamIdToQueue: [UUID: [Player]] = [:]
        for player in players {
            teamIdToQueue[player.team.id, default: []].append(player)
        }

        // Keep only teams that actually have players, in provided order
        let activeTeamIds = teamOrder.filter { (teamIdToQueue[$0]?.isEmpty == false) }
        guard activeTeamIds.count >= 2 else { return players }

        var result: [Player] = []
        result.reserveCapacity(players.count)

        // Drain each team one by one in a loop until all empty
        var appendedInPass = true
        while appendedInPass {
            appendedInPass = false
            for teamId in activeTeamIds {
                if var queue = teamIdToQueue[teamId], !queue.isEmpty {
                    result.append(queue.removeFirst())
                    teamIdToQueue[teamId] = queue
                    appendedInPass = true
                }
            }
        }
        return result
    }
}
