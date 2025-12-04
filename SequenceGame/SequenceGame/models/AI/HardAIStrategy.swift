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

        // 3. Prioritize cards that extend sequences (MOVED UP - regular cards first)
        if let extendingCard = findBestSequenceExtendingCard(
            from: cards,
            gameState: gameState,
            teamColor: teamColor
        ) {
            print("🧠📈 Hard AI: Extending sequence")
            return extendingCard.id
        }

        // 4. Block opponent's developing sequences (MOVED UP - regular cards first)
        if let blockingCard = findOpponentBlockingCard(from: cards, gameState: gameState) {
            print("🧠🚧 Hard AI: Blocking opponent development")
            return blockingCard.id
        }

        // 5. Strategic one-eyed Jack usage ONLY for critical threats (MOVED DOWN + improved)
        // Only use if opponent has 4 in a row (one away from completing)
        if let oneEyedJack = findStrategicOneEyedJack(from: cards, gameState: gameState) {
            print("🧠👁️ Hard AI: Using one-eyed Jack to break opponent's 4-chip sequence")
            return oneEyedJack.id
        }

        // 6. Use two-eyed Jacks as last resort wildcard (MOVED DOWN + improved)
        // Only use when no better regular card is available
        let twoEyedJacks = cards.filter { card in
            card.cardFace == .jack && (card.suit == .clubs || card.suit == .diamonds)
        }
        if !twoEyedJacks.isEmpty,
           let bestJack = findBestTwoEyedJackOpportunity(
               jacks: twoEyedJacks,
               gameState: gameState,
               teamColor: teamColor
           ) {
            print("🧠🃏 Hard AI: Using two-eyed Jack as wildcard")
            return bestJack.id
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

        // Special handling for one-eyed Jack: Target critical opponent chips
        if card.cardFace == .jack && (card.suit == .hearts || card.suit == .spades) {
            // Find opponent chips that are part of 4-chip sequences
            let opponents = gameState.players.filter { $0.team.color != teamColor }

            for opponent in opponents {
                let criticalChips = HardAIStrategyHelper.findCriticalOpponentChips(
                    opponentColor: opponent.team.color,
                    gameState: gameState
                )

                // Find the best critical chip that's in our valid positions
                if let bestTarget = criticalChips.first(where: { validPositions.contains($0) }) {
                    print("🧠💥 Hard AI: Removing critical chip from 4-chip sequence!")
                    return bestTarget
                }
            }

            // If no critical chips, just pick any valid position (shouldn't happen if logic is correct)
            return validPositions.randomElement()
        }

        // Regular card or two-eyed Jack position selection

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
                // Use dynamic requiredSequencesToWin based on player count
                if currentSequences + 1 >= gameState.requiredSequencesToWin {
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

            // If opponent is one sequence away from winning (use dynamic requiredSequencesToWin)
            if opponentSequences >= gameState.requiredSequencesToWin - 1 {
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
    /// ONLY targets chips in sequences of exactly 4 (one away from completing)
    private func findStrategicOneEyedJack(from cards: [Card], gameState: GameState) -> Card? {
        let oneEyedJacks = cards.filter { card in
            card.cardFace == .jack && (card.suit == .hearts || card.suit == .spades)
        }

        guard !oneEyedJacks.isEmpty else { return nil }

        // Find opponent chips that are part of 4-chip sequences (critical threat)
        let currentTeam = gameState.currentPlayer?.team.color
        let opponents = gameState.players.filter { $0.team.color != currentTeam }

        // Check each opponent
        for opponent in opponents {
            let criticalChips = HardAIStrategyHelper.findCriticalOpponentChips(
                opponentColor: opponent.team.color,
                gameState: gameState
            )

            // If opponent has chips in 4-chip sequences, target them
            if !criticalChips.isEmpty {
                // Prioritize chips that are central to multiple potential sequences
                let bestTarget = criticalChips.max { pos1, pos2 in
                    let count1 = HardAIStrategyHelper.countPotentialSequences(
                        at: pos1,
                        teamColor: opponent.team.color,
                        gameState: gameState
                    )
                    let count2 = HardAIStrategyHelper.countPotentialSequences(
                        at: pos2,
                        teamColor: opponent.team.color,
                        gameState: gameState
                    )
                    return count1 < count2
                }

                if bestTarget != nil {
                    return oneEyedJacks.first
                }
            }
        }

        return nil
    }

    /// Finds best opportunity for two-eyed Jack
    /// ONLY uses when can complete sequence or extend to 3+ chips (save as wildcard)
    private func findBestTwoEyedJackOpportunity(
        jacks: [Card],
        gameState: GameState,
        teamColor: TeamColor
    ) -> Card? {
        guard let jack = jacks.first else { return nil }

        let positions = gameState.computePlayableTiles(for: jack)

        // Priority 1: Use to complete a sequence (4 → 5 chips)
        for position in positions where HardAIStrategyHelper.wouldCompleteSequence(
            at: position,
            teamColor: teamColor,
            gameState: gameState
        ) {
            return jack
        }

        // Priority 2: Use to extend to 3+ chips (strong position)
        for position in positions where countAdjacentChips(
            at: position,
            teamColor: teamColor,
            in: gameState
        ) >= 3 {
            return jack
        }

        // Don't use for 2 or fewer adjacent chips - save the wildcard for better opportunities
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
