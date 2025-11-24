//
//  MainMenu.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct MainMenu: View {
    @State private var scatterItems: [ScatterItem] = []
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [ThemeColor.backgroundMenu, ThemeColor.backgroundMenu.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                    .ignoresSafeArea()
                VStack(spacing: GameConstants.UISizing.largeSpacing) {
                    // Logo/Title Section
                    MainMenuHeaderView()
                    Spacer()
                    VStack(spacing: GameConstants.UISizing.verticalSpacing) {
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
                    .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
                    Spacer()
                    Text("v1.0") // Footer
                        .font(.caption)
                        .foregroundStyle(ThemeColor.textPrimary.opacity(0.5))
                        .padding(.bottom, GameConstants.UISizing.footerBottomPadding)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColor.backgroundMenu, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    MainMenu()
        .environmentObject(GameState())
}
