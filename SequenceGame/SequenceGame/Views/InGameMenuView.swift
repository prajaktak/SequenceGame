//
//  InGameMenuView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 24/11/2025.
//

import SwiftUI

/// The in-game menu presented as a sheet during active gameplay.
///
/// Provides quick access to game actions (Resume, Restart, New Game) and
/// navigation to Help and Settings screens. Includes a confirmation dialog
/// for the Restart action to prevent accidental data loss.
///
/// Presented via `.sheet()` modifier when the menu button in GameView is tapped.
struct InGameMenuView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.dismiss) var dismiss
    
    @State private var showRestartConfirmation = false
    @State private var showRestartError = false
    var onNewGame: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [ThemeColor.backgroundMenu, ThemeColor.backgroundMenu.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: GameConstants.UISizing.largeSpacing) {
                        // Header
                        VStack(spacing: GameConstants.UISizing.overlayContentSpacing) {
                            Image(systemName: "line.3.horizontal.circle.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [ThemeColor.accentPrimary, ThemeColor.accentSecondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Game Menu")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(ThemeColor.textPrimary)
                                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                        }
                        .padding(.top, GameConstants.UISizing.boardTopPadding)
                        
                        // Main Actions
                        VStack(spacing: GameConstants.UISizing.verticalSpacing) {
                            // Resume Button
                            InGameMenuButtonView(
                                title: "Resume",
                                subtitle: "Continue playing",
                                icon: "play.circle.fill",
                                gradient: [ThemeColor.accentPrimary, ThemeColor.accentSecondary]
                            ) {
                                dismiss()
                            }
                            
                            // Restart Button
                            InGameMenuButtonView(
                                title: "Restart",
                                subtitle: "Start over with same players",
                                icon: "arrow.clockwise.circle.fill",
                                gradient: [ThemeColor.accentPrimary, ThemeColor.accentTertiary]
                            ) {
                                showRestartConfirmation = true
                            }
                            
                            // New Game Button
                            InGameMenuButtonView(
                                title: "New Game",
                                subtitle: "Configure new players",
                                icon: "plus.circle.fill",
                                gradient: [ThemeColor.accentPrimary, ThemeColor.accentSecondary]
                            ) {
                               onNewGame()
                            }
                        }
                        .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
                        
                        Divider()
                            .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
                        
                        // Navigation Section
                        VStack(spacing: GameConstants.UISizing.verticalSpacing) {
                            MenuButtonView(
                                title: "How to Play",
                                subtitle: "Game rules and tips",
                                iconSystemName: "questionmark.circle.fill",
                                gradient: [ThemeColor.accentPrimary, ThemeColor.accentSecondary]
                            ) { HelpView() }
                            
                            MenuButtonView(
                                title: "Settings",
                                subtitle: "Preferences and options",
                                iconSystemName: "gearshape.circle.fill",
                                gradient: [ThemeColor.accentSecondary, ThemeColor.accentTertiary]
                            ) { SettingsView() }
                        }
                        .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Restart Game?", isPresented: $showRestartConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Restart", role: .destructive) {
                    do {
        try gameState.restartGame()
        dismiss()
    } catch {
        showRestartError = true
    }
                }
            } message: {
                Text("Current progress will be lost. Start over with the same players?")
            }
        }
        .alert("Cannot Restart Game", isPresented: $showRestartError) {
    Button("OK") {
        onNewGame()
    }
} message: {
    Text("Can not restart game due to technical issue. Please start new game")
}
    }
}

#Preview {
    InGameMenuView(onNewGame: {
        print("New Game tapped")
    })
        .environmentObject(GameState())
}
