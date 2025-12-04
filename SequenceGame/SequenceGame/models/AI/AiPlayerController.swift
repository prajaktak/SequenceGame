//
//  AiPlayerController.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 01/12/2025.
//

import Foundation

/// Manages AI player turn execution
struct AIPlayerController {
    let strategy: AIStrategy
    let difficulty: AIDifficulty
    
    /// Creates controller with appropriate strategy for difficulty
    init(difficulty: AIDifficulty) {
        self.difficulty = difficulty
        switch difficulty {
        case .easy:
            self.strategy = EasyAIStrategy()
        case .medium:
            self.strategy = MediumAIStrategy()
        case .hard:
            self.strategy = HardAIStrategy()
        }
    }
    
    /// Executes an AI turn asynchronously with thinking delay
    /// - Parameter gameState: The current game state
    func executeTurnAsync(in gameState: GameState) async -> Bool {
        print("🤖 AI (\(difficulty.rawValue)): Starting turn...")
        
        // Add thinking delay to make AI feel more natural
        try? await Task.sleep(nanoseconds: UInt64(difficulty.thinkingDelay * 1_000_000_000))
        
        return executeTurn(in: gameState)
    }
    
    /// Executes an AI turn synchronously
    /// - Parameter gameState: The current game state
    /// - Returns: true if move was made successfully, false otherwise
    func executeTurn(in gameState: GameState) -> Bool {
        // CRITICAL: Don't execute AI turn if game is already over
        guard gameState.overlayMode != .gameOver else {
            print("❌ AI Controller: Game is over, cannot execute turn")
            return false
        }

        guard let currentPlayer = gameState.currentPlayer,
              currentPlayer.isAI else {
            print("❌ AI Controller: Current player is not AI")
            return false
        }
        
        // Step 1: Select a card
        guard let selectedCardId = strategy.selectCard(
            from: currentPlayer.cards,
            gameState: gameState
        ) else {
            print("❌ AI Controller: Could not select a card")
            return handleDeadCard(in: gameState)
        }
        
        // Step 2: Find valid positions for the card
        guard let selectedCard = currentPlayer.cards.first(where: { $0.id == selectedCardId }) else {
            print("❌ AI Controller: Selected card not found in hand")
            return false
        }
        gameState.overlayMode = .cardSelected
        let validPositions = gameState.computePlayableTiles(for: selectedCard)
        guard !validPositions.isEmpty else {
            print("❌ AI Controller: No valid positions for selected card")
            gameState.overlayMode = .deadCard
            return handleDeadCard(in: gameState)
        }
        
        // Step 3: Select a position
        guard let selectedPosition = strategy.selectPosition(
            for: selectedCard,
            validPositions: validPositions,
            gameState: gameState
        ) else {
            print("❌ AI Controller: Could not select a position")
            return false
        }
        
        // Step 4: Execute the play        
        gameState.performPlay(atPos: selectedPosition, using: selectedCardId)
        
        print("✅ AI Controller: Successfully executed move")
        return true
    }
    
    /// Handles dead card situation
    /// A dead card occurs when a player has a card with no valid positions to play
    private func handleDeadCard(in gameState: GameState) -> Bool {
        guard let currentPlayer = gameState.currentPlayer else {
            print("❌ AI Controller: No current player for dead card handling")
            return false
        }
        
        print("🎴 AI Controller: Handling dead card situation")
        
        // Find a dead card (card with no valid positions)
        let deadCard = currentPlayer.cards.first { card in
            let validPositions = gameState.computePlayableTiles(for: card)
            return validPositions.isEmpty
        }
        
        guard let cardToDiscard = deadCard else {
            print("⚠️ AI Controller: No dead card found, but handleDeadCard was called")
            return false
        }
        
        print("🎴 AI Controller: Discarding dead card: \(cardToDiscard.suit) \(cardToDiscard.cardFace)")
        
        // Trigger dead card handling in game state
        // This should discard the card and draw a new one
        gameState.replaceDeadCard(cardToDiscard.id)
        
        return true
    }
}
