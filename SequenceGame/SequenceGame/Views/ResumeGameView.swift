//
//  ResumeGameView.swift
//  SequenceGame
//
//  Created on [today's date]
//

import SwiftUI

/// A view that loads and resumes a previously saved game.
///
/// This view checks for a saved game, loads it, restores the game state,
/// and navigates to `GameView` to continue the game.
struct ResumeGameView: View {
    // MARK: - Environment
    
    /// The game state that will be restored from the saved game
    @EnvironmentObject var gameState: GameState
    
    /// Navigation environment for dismissing this view
    @Environment(\.dismiss) var dismiss
    
    // MARK: - State
    
    /// Tracks whether the game is being loaded
    @State private var isLoading = true
    
    /// Tracks if an error occurred during loading
    @State private var loadError: Error?
    
    /// Controls showing an error alert
    @State private var showErrorAlert = false
    
    /// Controls navigation to GameView after successful load
    @State private var navigateToGame = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Loading UI
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading saved game...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Hidden NavigationLink that gets triggered programmatically
            // Only include it when we're ready to navigate to prevent interference
            if !isLoading && navigateToGame {
                NavigationLink(
                    destination: GameView(isResuming: true),
                    isActive: $navigateToGame
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            await loadSavedGame()
        }
        .onDisappear {
            // Reset state when view disappears to prevent interference
            isLoading = true
            navigateToGame = false
        }
        .alert("Failed to Load Game", isPresented: $showErrorAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(loadError?.localizedDescription ?? "Unable to load saved game")
        }
    }
    
    // MARK: - Game Loading
    
    /// Loads the saved game and restores it to GameState.
    ///
    /// This method:
    /// 1. Checks if a saved game exists
    /// 2. Loads the snapshot from disk
    /// 3. Restores it to GameState
    /// 4. Sets isLoading to false to trigger navigation
    private func loadSavedGame() async {
        print("🔄 ResumeGameView: Starting to load saved game")
        
        // Check if saved game exists
        guard GamePersistence.hasSavedGame() else {
            print("⚠️ ResumeGameView: No saved game found")
            // No saved game - dismiss this view
            await MainActor.run {
                dismiss()
            }
            return
        }
        
        print("✅ ResumeGameView: Saved game found, loading...")
        
        // Load the saved game
        let result = GamePersistence.loadGame()
        
        await MainActor.run {
            switch result {
            case .success(let snapshot):
                print("✅ ResumeGameView: Game loaded successfully, restoring state...")
                // Restore game state from snapshot
                gameState.restore(from: snapshot)
                print("✅ ResumeGameView: State restored, navigating to GameView...")
                isLoading = false
                // Small delay to ensure UI updates, then trigger navigation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    print("🚀 ResumeGameView: Triggering navigation to GameView")
                    navigateToGame = true
                }
                
            case .failure(let error):
                print("❌ ResumeGameView: Failed to load game: \(error.localizedDescription)")
                // Handle error
                loadError = error
                showErrorAlert = true
            }
        }
    }
}
