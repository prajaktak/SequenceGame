//
//  MediumAIStrategy.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 01/12/2025.
//

import Foundation

struct MediumAIStrategy: AIStrategy {

    func selectCard(from cards: [Card], gameState: GameState) -> UUID? {
        guard let teamColor = gameState.currentPlayer?.team.color else {
            return cards.randomElement()?.id
        }

        // 1. Prioritize two-eyed Jacks (wild cards)
        let twoEyedJacks = cards.filter { card in
            card.cardFace == .jack && (card.suit == .clubs || card.suit == .diamonds)
        }

        if !twoEyedJacks.isEmpty,
           let jack = twoEyedJacks.randomElement(),
           !gameState.computePlayableTiles(for: jack).isEmpty {
            print("🧠 Medium AI: Using two-eyed Jack strategically")
            return jack.id
        }

        // 2. Look for cards that can extend sequences
        let sequenceExtenders = findSequenceExtendingCards(
            from: cards,
            gameState: gameState,
            teamColor: teamColor
        )
        if !sequenceExtenders.isEmpty {
            print("🧠 Medium AI: Found sequence-extending card")
            return sequenceExtenders.randomElement()?.id
        }

        // 3. Fallback to random playable card
        let playableCards = cards.filter { card in
            !gameState.computePlayableTiles(for: card).isEmpty
        }

        print("🧠 Medium AI: Using random playable card")
        return playableCards.randomElement()?.id
    }

    func selectPosition(
        for card: Card,
        validPositions: [Position],
        gameState: GameState
    ) -> Position? {
        guard let teamColor = gameState.currentPlayer?.team.color else {
            return validPositions.randomElement()
        }

        // 1. Find positions that extend own sequences
        let sequencePositions = validPositions.filter { position in
            countAdjacentChips(at: position, teamColor: teamColor, in: gameState) > 0
        }

        if !sequencePositions.isEmpty {
            // Choose position with most adjacent chips
            let bestPosition = sequencePositions.max { pos1, pos2 in
                countAdjacentChips(at: pos1, teamColor: teamColor, in: gameState) <
                countAdjacentChips(at: pos2, teamColor: teamColor, in: gameState)
            }
            print("🧠 Medium AI: Extending sequence")
            return bestPosition
        }

        // 2. Find positions that block opponents
        let blockingPositions = validPositions.filter { position in
            wouldBlockOpponent(
                at: position,
                in: gameState,
                currentTeam: teamColor,
                minimumThreshold: 2
            )
        }

        if !blockingPositions.isEmpty {
            print("🧠 Medium AI: Blocking opponent")
            return blockingPositions.randomElement()
        }

        // 3. Fallback to random
        print("🧠 Medium AI: Random position")
        return validPositions.randomElement()
    }
}
