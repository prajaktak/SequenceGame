//
//  PlayerLobbyView.swift
//  SequenceGame
//
//  iPhone lobby screen shown while the player waits to be assigned by the host.
//  The phone browses for the host iPad via MultipeerConnectivity, shows
//  connection status, and displays assigned name/team once the game starts.
//

import SwiftUI
import MultipeerConnectivity

/// iPhone lobby: browses for the host iPad and shows connection status.
struct PlayerLobbyView: View {

    // MARK: - Dependencies

    @StateObject private var sessionManager: MultipeerSessionManager
    @StateObject private var client: MultiplayerClient

    // MARK: - State

    @State private var connectionStatus: String = "Searching for host…"

    /// Triggers navigation to the in-game view once the host starts the game.
    @State private var isGameActive: Bool = false

    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    init(localPlayerId: UUID = UUID()) {
        // Append a short device-unique suffix so two iPhones with the same
        // name ("iPhone") produce distinct peer display names in the host session map.
        let deviceSuffix = UIDevice.current.identifierForVendor?.uuidString.prefix(8) ?? UUID().uuidString.prefix(8)
        let uniqueDisplayName = "\(UIDevice.current.name)|\(deviceSuffix)"
        let manager = MultipeerSessionManager(displayName: uniqueDisplayName)
        _sessionManager = StateObject(wrappedValue: manager)
        _client = StateObject(wrappedValue: MultiplayerClient(
            sessionManager: manager,
            localPlayerId: localPlayerId
        ))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColor.backgroundMenu.ignoresSafeArea()

                VStack(spacing: GameConstants.largeSpacing) {
                    Spacer()
                    statusIcon
                    statusText
                    playerAssignmentSection
                    Spacer()
                    gameReadyContent
                }
                .padding(.horizontal, GameConstants.horizontalPadding)
            }
            .navigationTitle("Join Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColor.backgroundMenu, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        sessionManager.stopBrowsing()
                        dismiss()
                    }
                    .foregroundStyle(ThemeColor.textPrimary)
                }
            }
            .onAppear { sessionManager.startBrowsing() }
            .onDisappear { sessionManager.stopBrowsing() }
            .onChange(of: sessionManager.connectedPeers) { updateStatus() }
            .onReceive(sessionManager.$receivedData) { pair in
                if let pair { client.handleReceivedData(pair.data) }
            }
            .onChange(of: client.latestBroadcast) { broadcast in
                if broadcast != nil { isGameActive = true }
            }
            .navigationDestination(isPresented: $isGameActive) {
                MultiplayerPlayerView(client: client)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    // MARK: - Subviews

    private var statusIcon: some View {
        ZStack {
            if sessionManager.connectedPeers.isEmpty {
                ProgressView()
                    .scaleEffect(2)
                    .tint(ThemeColor.accentPrimary)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(ThemeColor.accentSecondary)
            }
        }
        .frame(height: 80)
    }

    private var statusText: some View {
        VStack(spacing: GameConstants.overlayContentSpacing) {
            Text(connectionStatus)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(ThemeColor.textPrimary)
                .multilineTextAlignment(.center)
            Text(sessionManager.connectedPeers.isEmpty
                 ? "Make sure the iPad is nearby and hosting a game."
                 : "You are connected! Waiting for the host to start the game.")
                .font(.caption)
                .foregroundStyle(ThemeColor.textPrimary.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private var playerAssignmentSection: some View {
        if let broadcast = client.latestBroadcast,
           let myInfo = broadcast.playerInfoList.first(where: { $0.id == broadcast.receivingPlayerId }) {
            VStack(spacing: GameConstants.overlayContentSpacing) {
                Text("You are playing as")
                    .font(.caption)
                    .foregroundStyle(ThemeColor.textPrimary.opacity(0.6))
                Text(myInfo.name)
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(ThemeColor.textPrimary)
                Text(myInfo.teamColor.accessibilityName + " Team")
                    .font(.subheadline)
                    .foregroundStyle(ThemeColor.getTeamColor(for: myInfo.teamColor))
            }
            .padding(GameConstants.verticalSpacing)
            .frame(maxWidth: .infinity)
            .background(ThemeColor.accentPrimary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: GameConstants.largeCornerRadius))
        }
    }

    @ViewBuilder
    private var gameReadyContent: some View {
        if client.latestBroadcast != nil {
            Text("Game starting…")
                .font(.headline)
                .foregroundStyle(ThemeColor.accentPrimary)
                .padding(.bottom, GameConstants.verticalSpacing)
        }
    }

    // MARK: - Logic

    private func updateStatus() {
        if sessionManager.connectedPeers.isEmpty {
            connectionStatus = "Searching for host…"
        } else {
            connectionStatus = "Connected to \(sessionManager.connectedPeers[0].displayName)"
        }
    }
}

#Preview("PlayerLobbyView – Searching") {
    PlayerLobbyView()
}
