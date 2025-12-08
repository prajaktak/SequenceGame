//
//  ReplayRecorder.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 08/12/2025.
//

import Foundation

/// Records game moves for replay functionality
final class ReplayRecorder: Codable, Equatable {
    private(set) var moves: [GameMove]
    private(set) var moveCounter: Int

    init() {
        self.moves = []
        self.moveCounter = 0
    }

    /// Records a new move in the game
    func recordMove(
        position: Position,
        card: Card,
        playerInfo: PlayerMoveInfo,
        moveType: MoveType,
        sequencesCompleted: Int
    ) {
        moveCounter += 1
        let move = GameMove(
            moveNumber: moveCounter,
            position: position,
            card: card,
            playerId: playerInfo.playerId,
            playerName: playerInfo.playerName,
            teamColor: playerInfo.teamColor,
            moveType: moveType,
            sequencesCompleted: sequencesCompleted
        )
        moves.append(move)
    }

    /// Clears all recorded moves
    func clearMoves() {
        moves.removeAll()
        moveCounter = 0
    }

    /// Returns the total number of moves recorded
    var totalMoves: Int {
        return moves.count
    }

    static func == (lhs: ReplayRecorder, rhs: ReplayRecorder) -> Bool {
        return lhs.moves == rhs.moves && lhs.moveCounter == rhs.moveCounter
    }
}
