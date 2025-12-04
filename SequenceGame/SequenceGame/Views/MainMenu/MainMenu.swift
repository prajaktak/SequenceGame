//
//  MainMenu.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct MainMenu: View {
    @State private var scatterItems: [ScatterItem] = []
    @State private var hasSavedGame = false
    
    @AppStorage("isOnboardingCompleted") private var isOnboardingCompleted = false
    @State private var showOnboarding = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [ThemeColor.backgroundMenu, ThemeColor.backgroundMenu.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                VStack(spacing: GameConstants.largeSpacing) {
                    // Logo/Title Section
                    MainMenuHeaderView()
                    Spacer()
                    VStack(spacing: GameConstants.verticalSpacing) {
                        // Resume Game button - always visible but disabled when no save exists
                        MenuButtonView(
                            title: "Resume Game",
                            subtitle: "Continue your last game",
                            iconSystemName: "arrow.clockwise.circle.fill",
                            gradient: [ThemeColor.accentSecondary, ThemeColor.accentPrimary],
                            isEnabled: hasSavedGame
                        ) { ResumeGameView() }
                        
                        MenuButtonView(
                            title: "New Game",
                            subtitle: "Start a fresh game",
                            iconSystemName: "play.circle.fill",
                            gradient: [ThemeColor.accentPrimary, ThemeColor.accentSecondary]
                        ) { GameSettingsView() }
                        
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
                            gradient: [ThemeColor.accentPrimary, ThemeColor.accentTertiary]
                        ) { SettingsView() }
                        
                        MenuButtonView(
                            title: "About & Credits",
                            subtitle: "App info and attributions",
                            iconSystemName: "info.circle.fill",
                            gradient: [ThemeColor.accentPrimary, ThemeColor.accentSecondary]
                        ) { CreditsView() }
                    }
                    .padding(.horizontal, GameConstants.horizontalPadding)
                    Spacer()
                    Text("v1.0") // Footer
                        .font(.caption)
                        .foregroundStyle(ThemeColor.textPrimary.opacity(0.5))
                        .padding(.bottom, GameConstants.footerBottomPadding)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColor.backgroundMenu, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                // Check if a saved game exists
                hasSavedGame = GamePersistence.hasSavedGame()
                
                // Skip onboarding if running UI tests
                let isUITesting = CommandLine.arguments.contains("-ui-testing")
                
                // Show onboarding on first launch (unless in UI tests)
                if !isOnboardingCompleted && !isUITesting {
                    // Small delay to let the view appear first
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showOnboarding = true
                    }
                }
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView()
        }
    }
}
#Preview {
    MainMenu()
        .environmentObject(GameState())
}
