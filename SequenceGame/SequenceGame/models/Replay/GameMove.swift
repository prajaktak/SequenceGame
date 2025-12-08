//
//  GameMove.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 08/12/2025.
//

import Foundation

/// Represents a single move in the game for replay purposes
struct GameMove: Codable, Equatable, Identifiable {
    let id: UUID
    let moveNumber: Int
    let position: Position
    let card: Card
    let playerId: UUID
    let playerName: String
    let teamColor: TeamColor
    let moveType: MoveType
    let timestamp: Date
    let sequencesCompleted: Int

    init(
        id: UUID = UUID(),
        moveNumber: Int,
        position: Position,
        card: Card,
        playerId: UUID,
        playerName: String,
        teamColor: TeamColor,
        moveType: MoveType,
        timestamp: Date = Date(),
        sequencesCompleted: Int = 0
    ) {
        self.id = id
        self.moveNumber = moveNumber
        self.position = position
        self.card = card
        self.playerId = playerId
        self.playerName = playerName
        self.teamColor = teamColor
        self.moveType = moveType
        self.timestamp = timestamp
        self.sequencesCompleted = sequencesCompleted
    }
}
