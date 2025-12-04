//
//  HardAIStrategyHelper.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 02/12/2025.
//

import Foundation

/// Helper functions specific to Hard AI Strategy for advanced sequence analysis
enum HardAIStrategyHelper {

    // MARK: - Position Selection Helpers

    /// Finds position that completes a sequence
    static func findPositionToCompleteSequence(
        positions: [Position],
        teamColor: TeamColor,
        gameState: GameState
    ) -> Position? {
        for position in positions where wouldCompleteSequence(
            at: position,
            teamColor: teamColor,
            gameState: gameState
        ) {
            return position
        }
        return nil
    }

    /// Finds position that blocks opponent sequence
    static func findPositionToBlockSequence(
        positions: [Position],
        gameState: GameState
    ) -> Position? {
        let currentTeam = gameState.currentPlayer?.team.color

        for position in positions {
            for player in gameState.players where player.team.color != currentTeam {
                if wouldBlockSequenceCompletion(
                    at: position,
                    opponentColor: player.team.color,
                    gameState: gameState
                ) {
                    return position
                }
            }
        }

        return nil
    }

    /// Finds position that creates multiple sequence opportunities (fork)
    static func findForkPosition(
        positions: [Position],
        teamColor: TeamColor,
        gameState: GameState
    ) -> Position? {
        var bestPosition: Position?
        var maxPotentialSequences = 0

        for position in positions {
            let potentialSequences = countPotentialSequences(
                at: position,
                teamColor: teamColor,
                gameState: gameState
            )

            if potentialSequences > maxPotentialSequences {
                maxPotentialSequences = potentialSequences
                bestPosition = position
            }
        }

        return maxPotentialSequences >= 2 ? bestPosition : nil
    }

    /// Finds best position to extend sequences using adjacent chip counting
    static func findBestExtendingPosition(
        positions: [Position],
        teamColor: TeamColor,
        gameState: GameState,
        strategy: AIStrategy
    ) -> Position? {
        return positions.max { pos1, pos2 in
            strategy.countAdjacentChips(at: pos1, teamColor: teamColor, in: gameState) <
            strategy.countAdjacentChips(at: pos2, teamColor: teamColor, in: gameState)
        }
    }

    /// Finds strategic position (center board, creating opportunities)
    static func findStrategicPosition(
        positions: [Position],
        gameState: GameState,
        strategy: AIStrategy
    ) -> Position? {
        // Prefer positions closer to center
        return positions.min { pos1, pos2 in
            let dist1 = strategy.distanceFromCenter(pos1)
            let dist2 = strategy.distanceFromCenter(pos2)
            return dist1 < dist2
        }
    }

    // MARK: - Utility Helpers

    /// Checks if placing a chip would complete a sequence
    static func wouldCompleteSequence(
        at position: Position,
        teamColor: TeamColor,
        gameState: GameState
    ) -> Bool {
        let directions: [(Int, Int)] = [
            (0, 1),   // horizontal
            (1, 0),   // vertical
            (1, 1),   // diagonal \
            (1, -1)   // diagonal /
        ]

        for direction in directions {
            let count = countChipsInLine(
                from: position,
                direction: direction,
                teamColor: teamColor,
                gameState: gameState
            )

            if count >= GameConstants.sequenceLength - 1 {
                return true
            }
        }

        return false
    }

    /// Checks if position would block opponent from completing sequence
    static func wouldBlockSequenceCompletion(
        at position: Position,
        opponentColor: TeamColor,
        gameState: GameState
    ) -> Bool {
        let directions: [(Int, Int)] = [
            (0, 1), (1, 0), (1, 1), (1, -1)
        ]

        for direction in directions {
            let count = countChipsInLine(
                from: position,
                direction: direction,
                teamColor: opponentColor,
                gameState: gameState
            )

            // If opponent needs just one more chip to complete
            if count == GameConstants.sequenceLength - 1 {
                return true
            }
        }

        return false
    }

    /// Counts potential sequences that could be formed through this position
    static func countPotentialSequences(
        at position: Position,
        teamColor: TeamColor,
        gameState: GameState
    ) -> Int {
        let directions: [(Int, Int)] = [
            (0, 1), (1, 0), (1, 1), (1, -1)
        ]

        var potentialCount = 0

        for direction in directions {
            let count = countChipsInLine(
                from: position,
                direction: direction,
                teamColor: teamColor,
                gameState: gameState
            )

            if count >= 2 {
                potentialCount += 1
            }
        }

        return potentialCount
    }

    /// Finds positions where removing a chip would break an opponent's sequence of exactly 4 chips
    /// (One chip away from completing a sequence, but not yet completed)
    static func findCriticalOpponentChips(
        opponentColor: TeamColor,
        gameState: GameState
    ) -> [Position] {
        var criticalPositions: [Position] = []
        let directions: [(Int, Int)] = [
            (0, 1), (1, 0), (1, 1), (1, -1)
        ]

        for rowIndex in 0..<GameConstants.boardRows {
            for colIndex in 0..<GameConstants.boardColumns {
                let position = Position(row: rowIndex, col: colIndex)
                let tile = gameState.boardTiles[rowIndex][colIndex]

                // Skip if not opponent's chip or if protected in sequence
                guard tile.isChipOn,
                      tile.chip?.color == opponentColor,
                      !gameState.tilesInSequences.contains(tile.id) else {
                    continue
                }

                // Check if removing this chip would break a line of 4
                for direction in directions {
                    let count = countChipsInLine(
                        from: position,
                        direction: direction,
                        teamColor: opponentColor,
                        gameState: gameState
                    )

                    // Exactly 4 chips means opponent needs one more to complete
                    if count == 4 {
                        criticalPositions.append(position)
                        break // Found critical chip, no need to check other directions
                    }
                }
            }
        }

        return criticalPositions
    }

    /// Counts chips of a team in a line through a position
    static func countChipsInLine(
        from position: Position,
        direction: (Int, Int),
        teamColor: TeamColor,
        gameState: GameState
    ) -> Int {
        var count = 1 // Count the position itself

        // Check forward direction
        var currentRow = position.row + direction.0
        var currentCol = position.col + direction.1

        while currentRow >= 0 && currentRow < GameConstants.boardRows &&
              currentCol >= 0 && currentCol < GameConstants.boardColumns {
            let tile = gameState.boardTiles[currentRow][currentCol]
            let currentPos = Position(row: currentRow, col: currentCol)

            if tile.isChipOn && tile.chip?.color == teamColor {
                // Own team's chip
                count += 1
            } else if currentPos.isCorner {
                // Corner acts as wildcard - counts for any team
                count += 1
            } else {
                // Different color chip or empty non-corner tile
                break
            }

            currentRow += direction.0
            currentCol += direction.1
        }

        // Check backward direction
        currentRow = position.row - direction.0
        currentCol = position.col - direction.1

        while currentRow >= 0 && currentRow < GameConstants.boardRows &&
              currentCol >= 0 && currentCol < GameConstants.boardColumns {
            let tile = gameState.boardTiles[currentRow][currentCol]
            let currentPos = Position(row: currentRow, col: currentCol)

            if tile.isChipOn && tile.chip?.color == teamColor {
                // Own team's chip
                count += 1
            } else if currentPos.isCorner {
                // Corner acts as wildcard - counts for any team
                count += 1
            } else {
                // Different color chip or empty non-corner tile
                break
            }

            currentRow -= direction.0
            currentCol -= direction.1
        }

        return count
    }
}
