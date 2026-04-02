//
//  MultiplayerModeSelectionView.swift
//  SequenceGame
//
//  Entry screen for local multiplayer.
//  Lets the user choose whether this device is the host (iPad) or a player (iPhone).
//

import SwiftUI

/// Entry point for local multiplayer — choose Host or Join.
struct MultiplayerModeSelectionView: View {

    // MARK: - Device Detection

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [ThemeColor.backgroundMenu, ThemeColor.backgroundMenu.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: GameConstants.largeSpacing) {
                headerSection
                Spacer()
                buttonStack
                Spacer()
            }
            .padding(.horizontal, GameConstants.horizontalPadding)
        }
        .navigationTitle("Multiplayer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(ThemeColor.backgroundMenu, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: GameConstants.overlayContentSpacing) {
            Image(systemName: "person.2.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(ThemeColor.accentPrimary)
                .padding(.top, GameConstants.largeSpacing)

            Text("Local Multiplayer")
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(ThemeColor.textPrimary)

            Text("Play on the same Wi-Fi or Bluetooth network.\nNo internet required.")
                .font(.subheadline)
                .foregroundStyle(ThemeColor.textPrimary.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }

    private var buttonStack: some View {
        VStack(spacing: GameConstants.verticalSpacing) {
            MenuButtonView(
                title: "Host a Game",
                subtitle: isIPad ? "Set up a game on this iPad" : "Only available on iPad",
                iconSystemName: "desktopcomputer",
                gradient: [ThemeColor.accentPrimary, ThemeColor.accentSecondary],
                isEnabled: isIPad
            ) {
                HostLobbyView()
            }

            MenuButtonView(
                title: "Join a Game",
                subtitle: isIPad ? "Only available on iPhone" : "Connect to a host iPad as a player",
                iconSystemName: "iphone",
                gradient: [ThemeColor.accentSecondary, ThemeColor.accentTertiary],
                isEnabled: !isIPad
            ) {
                PlayerLobbyView()
            }
        }
    }
}

#Preview("MultiplayerModeSelectionView") {
    NavigationStack {
        MultiplayerModeSelectionView()
    }
    .environmentObject(GameState())
}
