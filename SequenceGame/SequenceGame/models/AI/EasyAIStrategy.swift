//
//  AIEasyStrategy.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 01/12/2025.
//
import Foundation

struct EasyAIStrategy: AIStrategy {
    
    func selectCard(from cards: [Card], gameState: GameState) -> UUID? {
        // Filter cards that have at least one valid position
        let playableCards = cards.filter { card in
            let validPositions = gameState.computePlayableTiles(for: card)
            return !validPositions.isEmpty
        }
        
        // If no playable cards, return nil (dead card situation)
        guard !playableCards.isEmpty else {
            return nil
        }
        
        // Randomly select from playable cards
        return playableCards.randomElement()?.id
    }
    
    func selectPosition(
        for card: Card,
        validPositions: [Position],
        gameState: GameState
    ) -> Position? {
        // Simply return a random valid position
        return validPositions.randomElement()
    }
}
