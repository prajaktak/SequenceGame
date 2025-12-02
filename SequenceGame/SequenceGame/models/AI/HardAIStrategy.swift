//
//  HardAIStrategy.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 01/12/2025.
//

import Foundation

/// Advanced AI strategy that makes optimal strategic decisions
struct HardAIStrategy: AIStrategy {

    // MARK: - Card Selection

    func selectCard(from cards: [Card], gameState: GameState) -> UUID? {
        guard let teamColor = gameState.currentPlayer?.team.color else {
            return cards.randomElement()?.id
        }

        // 1. HIGHEST PRIORITY: Check if we can win with any card
        if let winningCard = findWinningCard(from: cards, gameState: gameState) {
            print("🧠🔥 Hard AI: Found WINNING move!")
            return winningCard.id
        }

        // 2. CRITICAL: Block opponent from winning
        if let blockingCard = findCriticalBlockingCard(from: cards, gameState: gameState) {
            print("🧠🛡️ Hard AI: BLOCKING opponent's winning move!")
            return blockingCard.id
        }

        // 3. Strategic one-eyed Jack usage (remove key opponent chips)
        if let oneEyedJack = findStrategicOneEyedJack(from: cards, gameState: gameState) {
            print("🧠👁️ Hard AI: Using one-eyed Jack to remove threat")
            return oneEyedJack.id
        }

        // 4. Build toward sequences with two-eyed Jacks
        let twoEyedJacks = cards.filter { card in
            card.cardFace == .jack && (card.suit == .clubs || card.suit == .diamonds)
        }
        if !twoEyedJacks.isEmpty,
           let bestJack = findBestTwoEyedJackOpportunity(
               jacks: twoEyedJacks,
               gameState: gameState,
               teamColor: teamColor
           ) {
            print("🧠🃏 Hard AI: Using two-eyed Jack strategically")
            return bestJack.id
        }

        // 5. Prioritize cards that extend sequences
        if let extendingCard = findBestSequenceExtendingCard(
            from: cards,
            gameState: gameState,
            teamColor: teamColor
        ) {
            print("🧠📈 Hard AI: Extending sequence")
            return extendingCard.id
        }

        // 6. Block opponent's developing sequences
        if let blockingCard = findOpponentBlockingCard(from: cards, gameState: gameState) {
            print("🧠🚧 Hard AI: Blocking opponent development")
            return blockingCard.id
        }

        // 7. Fallback to any playable card
        let playableCards = cards.filter { !gameState.computePlayableTiles(for: $0).isEmpty }
        print("🧠🎲 Hard AI: Playing random card")
        return playableCards.randomElement()?.id
    }

    // MARK: - Position Selection

    func selectPosition(
        for card: Card,
        validPositions: [Position],
        gameState: GameState
    ) -> Position? {
        guard let teamColor = gameState.currentPlayer?.team.color else {
            return validPositions.randomElement()
        }

        // 1. Complete a sequence (WINNING MOVE)
        if let winningPosition = HardAIStrategyHelper.findPositionToCompleteSequence(
            positions: validPositions,
            teamColor: teamColor,
            gameState: gameState
        ) {
            print("🧠🏆 Hard AI: Completing sequence!")
            return winningPosition
        }

        // 2. Block opponent from completing sequence
        if let blockingPosition = HardAIStrategyHelper.findPositionToBlockSequence(
            positions: validPositions,
            gameState: gameState
        ) {
            print("🧠🛡️ Hard AI: Blocking opponent's sequence!")
            return blockingPosition
        }

        // 3. Create multiple sequence opportunities (fork)
        if let forkPosition = HardAIStrategyHelper.findForkPosition(
            positions: validPositions,
            teamColor: teamColor,
            gameState: gameState
        ) {
            print("🧠🔱 Hard AI: Creating fork!")
            return forkPosition
        }

        // 4. Extend existing sequences
        if let extendingPosition = HardAIStrategyHelper.findBestExtendingPosition(
            positions: validPositions,
            teamColor: teamColor,
            gameState: gameState,
            strategy: self
        ) {
            print("🧠➡️ Hard AI: Extending sequence")
            return extendingPosition
        }

        // 5. Strategic position (center, corners)
        if let strategicPosition = HardAIStrategyHelper.findStrategicPosition(
            positions: validPositions,
            gameState: gameState,
            strategy: self
        ) {
            print("🧠🎯 Hard AI: Taking strategic position")
            return strategicPosition
        }

        // Fallback
        return validPositions.randomElement()
    }

    // MARK: - Card Selection Helpers

    /// Finds a card that can complete a sequence and win
    private func findWinningCard(from cards: [Card], gameState: GameState) -> Card? {
        guard let teamColor = gameState.currentPlayer?.team.color else { return nil }

        for card in cards {
            let positions = gameState.computePlayableTiles(for: card)
            for position in positions where HardAIStrategyHelper.wouldCompleteSequence(
                at: position,
                teamColor: teamColor,
                gameState: gameState
            ) {
                // Check if this would give us enough sequences to win
                let currentSequences = countTeamSequences(
                    teamColor: teamColor,
                    gameState: gameState
                )
                if currentSequences + 1 >= GameConstants.sequencesToWin {
                    return card
                }
            }
        }
        return nil
    }

    /// Finds a card that can block opponent from winning
    private func findCriticalBlockingCard(from cards: [Card], gameState: GameState) -> Card? {
        let currentTeam = gameState.currentPlayer?.team.color
        let opponents = gameState.players.filter { $0.team.color != currentTeam }

        for opponent in opponents {
            let opponentColor = opponent.team.color
            let opponentSequences = countTeamSequences(
                teamColor: opponentColor,
                gameState: gameState
            )

            // If opponent is one sequence away from winning
            if opponentSequences >= GameConstants.sequencesToWin - 1 {
                // Find card that can block their potential winning position
                for card in cards {
                    let positions = gameState.computePlayableTiles(for: card)
                    for position in positions where HardAIStrategyHelper.wouldBlockSequenceCompletion(
                        at: position,
                        opponentColor: opponentColor,
                        gameState: gameState
                    ) {
                        return card
                    }
                }
            }
        }
        return nil
    }

    /// Finds one-eyed Jack to remove strategic opponent chip
    private func findStrategicOneEyedJack(from cards: [Card], gameState: GameState) -> Card? {
        let oneEyedJacks = cards.filter { card in
            card.cardFace == .jack && (card.suit == .hearts || card.suit == .spades)
        }

        guard !oneEyedJacks.isEmpty else { return nil }

        // Find opponent chips that are close to forming sequences
        let currentTeam = gameState.currentPlayer?.team.color

        for rowIndex in 0..<GameConstants.boardRows {
            for colIndex in 0..<GameConstants.boardColumns {
                let position = Position(row: rowIndex, col: colIndex)
                let tile = gameState.boardTiles[rowIndex][colIndex]

                // Skip if no chip or it's our chip
                guard tile.isChipOn,
                      let chipColor = tile.chip?.color,
                      chipColor != currentTeam else { continue }

                // Skip if in a completed sequence (protected)
                if isInCompletedSequence(position: position, gameState: gameState) {
                    continue
                }

                // Check if removing this chip would break opponent's potential sequence
                let adjacentOpponentChips = countAdjacentChips(
                    at: position,
                    teamColor: chipColor,
                    in: gameState
                )

                if adjacentOpponentChips >= 2 {
                    return oneEyedJacks.first
                }
            }
        }

        return nil
    }

    /// Finds best opportunity for two-eyed Jack
    private func findBestTwoEyedJackOpportunity(
        jacks: [Card],
        gameState: GameState,
        teamColor: TeamColor
    ) -> Card? {
        guard let jack = jacks.first else { return nil }

        let positions = gameState.computePlayableTiles(for: jack)

        // Check if any position would complete or extend a sequence
        for position in positions {
            if HardAIStrategyHelper.wouldCompleteSequence(
                at: position,
                teamColor: teamColor,
                gameState: gameState
            ) {
                return jack
            }
            if countAdjacentChips(at: position, teamColor: teamColor, in: gameState) >= 2 {
                return jack
            }
        }

        return nil
    }

    /// Finds best card for extending sequences
    private func findBestSequenceExtendingCard(
        from cards: [Card],
        gameState: GameState,
        teamColor: TeamColor
    ) -> Card? {
        var bestCard: Card?
        var maxAdjacent = 0

        for card in cards {
            let positions = gameState.computePlayableTiles(for: card)
            for position in positions {
                let adjacent = countAdjacentChips(
                    at: position,
                    teamColor: teamColor,
                    in: gameState
                )
                if adjacent > maxAdjacent {
                    maxAdjacent = adjacent
                    bestCard = card
                }
            }
        }

        return maxAdjacent >= 1 ? bestCard : nil
    }

    /// Finds card to block opponent development
    private func findOpponentBlockingCard(from cards: [Card], gameState: GameState) -> Card? {
        let currentTeam = gameState.currentPlayer?.team.color

        for card in cards {
            let positions = gameState.computePlayableTiles(for: card)
            for position in positions {
                // Check if position would disrupt opponent sequences
                for player in gameState.players where player.team.color != currentTeam {
                    let adjacentCount = countAdjacentChips(
                        at: position,
                        teamColor: player.team.color,
                        in: gameState
                    )
                    if adjacentCount >= 2 {
                        return card
                    }
                }
            }
        }

        return nil
    }
}
