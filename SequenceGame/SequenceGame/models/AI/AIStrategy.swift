//
//  AIStrategy.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 01/12/2025.
//

import Foundation

protocol AIStrategy {
    /// Selects which card to play from the AI player's hand
    /// - Parameters:
    ///   - cards: The AI player's current hand
    ///   - gameState: Current game state for context
    /// - Returns: The UUID of the selected card, or nil if no valid card
    func selectCard(from cards: [Card], gameState: GameState) -> UUID?

    /// Selects where to place the selected card
    /// - Parameters:
    ///   - card: The card being played
    ///   - validPositions: All valid positions for this card
    ///   - gameState: Current game state for context
    /// - Returns: The chosen position, or nil if no valid position
    func selectPosition(
        for card: Card,
        validPositions: [Position],
        gameState: GameState
    ) -> Position?
}

// MARK: - Common Helper Functions

extension AIStrategy {

    /// Counts adjacent chips of the same team at a given position
    /// - Parameters:
    ///   - position: The board position to check
    ///   - teamColor: The team color to count
    ///   - gameState: Current game state
    /// - Returns: Number of adjacent chips (0-8)
    func countAdjacentChips(
        at position: Position,
        teamColor: TeamColor,
        in gameState: GameState
    ) -> Int {
        let adjacentPositions = [
            position.directionUp(),
            position.directionDown(),
            position.directionLeft(),
            position.directionRight(),
            position.directionUpLeft(),
            position.directionUpRight(),
            position.directionDownLeft(),
            position.directionDownRight()
        ]

        var count = 0

        for adjacentPosition in adjacentPositions {
            // Check bounds
            guard adjacentPosition.isValid(
                rows: GameConstants.boardRows,
                cols: GameConstants.boardColumns
            ) else {
                continue
            }

            let tile = gameState.boardTiles[adjacentPosition.row][adjacentPosition.col]
            if tile.isChipOn, tile.chip?.color == teamColor {
                count += 1
            }
        }

        return count
    }

    /// Finds cards that can extend existing sequences
    /// - Parameters:
    ///   - cards: Cards to search through
    ///   - gameState: Current game state
    ///   - teamColor: The team color to extend sequences for
    /// - Returns: Array of cards that can extend sequences
    func findSequenceExtendingCards(
        from cards: [Card],
        gameState: GameState,
        teamColor: TeamColor
    ) -> [Card] {
        return cards.filter { card in
            let positions = gameState.computePlayableTiles(for: card)
            return positions.contains { position in
                countAdjacentChips(at: position, teamColor: teamColor, in: gameState) > 0
            }
        }
    }

    /// Counts total sequences for a team
    /// - Parameters:
    ///   - teamColor: The team to count sequences for
    ///   - gameState: Current game state
    /// - Returns: Number of completed sequences
    func countTeamSequences(teamColor: TeamColor, gameState: GameState) -> Int {
        return gameState.detectedSequence.filter { $0.teamColor == teamColor }.count
    }

    /// Checks if a position is a corner tile
    /// - Parameter position: Position to check
    /// - Returns: True if position is a corner tile
    func isCorner(position: Position) -> Bool {
        return position.isCorner
    }

    /// Checks if a tile is part of a completed sequence
    /// - Parameters:
    ///   - position: Position to check
    ///   - gameState: Current game state
    /// - Returns: True if tile is in a completed sequence
    func isInCompletedSequence(position: Position, gameState: GameState) -> Bool {
        let tile = gameState.boardTiles[position.row][position.col]
        return gameState.tilesInSequences.contains(tile.id)
    }

    /// Checks if a position would block an opponent from making progress
    /// - Parameters:
    ///   - position: Position to check
    ///   - gameState: Current game state
    ///   - currentTeam: The current team's color (to identify opponents)
    ///   - minimumThreshold: Minimum adjacent opponent chips to consider blocking (default: 2)
    /// - Returns: True if position would block opponent
    func wouldBlockOpponent(
        at position: Position,
        in gameState: GameState,
        currentTeam: TeamColor,
        minimumThreshold: Int = 2
    ) -> Bool {
        // Get opponent teams
        let opponentTeams = gameState.players
            .map { $0.team.color }
            .filter { $0 != currentTeam }

        // Check if any opponent has chips nearby
        for opponentColor in opponentTeams {
            let adjacentCount = countAdjacentChips(
                at: position,
                teamColor: opponentColor,
                in: gameState
            )
            if adjacentCount >= minimumThreshold {
                return true
            }
        }

        return false
    }

    /// Calculates distance from center of board
    /// - Parameter position: Position to calculate distance for
    /// - Returns: Euclidean distance from center
    func distanceFromCenter(_ position: Position) -> Double {
        let centerRow = Double(GameConstants.boardRows) / 2.0
        let centerCol = Double(GameConstants.boardColumns) / 2.0
        let deltaRow = Double(position.row) - centerRow
        let deltaCol = Double(position.col) - centerCol
        return sqrt(deltaRow * deltaRow + deltaCol * deltaCol)
    }
}
