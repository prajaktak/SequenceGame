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
    
    /// Flag to track if navigation has been triggered (prevents resetting navigateToGame)
    @State private var hasNavigated = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [ThemeColor.backgroundMenu, ThemeColor.backgroundMenu.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Loading UI
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(ThemeColor.accentPrimary)
                    Text("Loading saved game...")
                        .font(.headline)
                        .foregroundColor(ThemeColor.textPrimary)
                } else {
                    Text("Game loaded!")
                        .font(.headline)
                        .foregroundColor(ThemeColor.textPrimary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Resume Game")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToGame) {
            GameView(isResuming: true)
        }
        .task {
            await loadSavedGame()
        }
        .onDisappear {
            // Don't reset navigateToGame here - it controls navigation and resetting it
            // causes navigation to be cancelled, creating a loop
            // Only reset isLoading for when we come back to this view
            if !hasNavigated {
                isLoading = true
            }
        }
        .onAppear {
            // Only reset if we're coming back to this view AND we haven't navigated yet
            // If hasNavigated is true, don't reset navigateToGame (navigation is in progress)
            if navigateToGame && !hasNavigated {
                navigateToGame = false
            }
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
    /// 4. Triggers navigation to GameView
    private func loadSavedGame() async {
        // Check if saved game exists
        guard GamePersistence.hasSavedGame() else {
            // No saved game - dismiss this view
            await MainActor.run {
                dismiss()
            }
            return
        }
        
        // Load the saved game
        let result = GamePersistence.loadGame()
        
        await MainActor.run {
            switch result {
            case .success(let snapshot):
                gameState.restore(from: snapshot)
                isLoading = false
                hasNavigated = true
                navigateToGame = true
                
            case .failure(let error):
                // Handle error
                loadError = error
                showErrorAlert = true
            }
        }
    }
}
