//
//  HostLobbyView.swift
//  SequenceGame
//
//  iPad lobby screen for hosting a multiplayer game.
//  Shows connected peers, lets the host assign team/name to each peer, and
//  starts the game when ready.
//

import SwiftUI
import MultipeerConnectivity

/// iPad lobby where the host waits for iPhone players to connect,
/// assigns them names and teams, and starts the game.
struct HostLobbyView: View {

    // MARK: - Dependencies

    @StateObject private var sessionManager = MultipeerSessionManager(displayName: UIDevice.current.name)
    @StateObject private var coordinator: MultiplayerCoordinator

    // MARK: - State

    /// Editable player names keyed by peer display name.
    @State private var peerNames: [String: String] = [:]

    /// Assigned TeamColor keyed by peer display name.
    @State private var peerTeams: [String: TeamColor] = [:]

    /// Whether the host is ready to start (all peers assigned).
    @State private var isStartEnabled: Bool = false

    /// Triggers navigation to the game board once the game has started.
    @State private var isGameActive: Bool = false

    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    init() {
        let manager = MultipeerSessionManager(displayName: UIDevice.current.name)
        _sessionManager = StateObject(wrappedValue: manager)
        _coordinator = StateObject(wrappedValue: MultiplayerCoordinator(sessionManager: manager))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColor.backgroundMenu.ignoresSafeArea()

                VStack(spacing: GameConstants.largeSpacing) {
                    headerSection
                    peersSection
                    Spacer()
                    startButton
                }
                .padding(.horizontal, GameConstants.horizontalPadding)
                .padding(.vertical, GameConstants.verticalSpacing)
            }
            .navigationTitle("Host Lobby")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColor.backgroundMenu, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        sessionManager.stopAdvertising()
                        dismiss()
                    }
                    .foregroundStyle(ThemeColor.textPrimary)
                }
            }
            .onAppear { sessionManager.startAdvertising() }
            .onDisappear { sessionManager.stopAdvertising() }
            .onChange(of: sessionManager.connectedPeers) { updatePeerDefaults() }
            .onChange(of: peerNames) { updateStartEnabled() }
            .onChange(of: peerTeams) { updateStartEnabled() }
            .navigationDestination(isPresented: $isGameActive) {
                MultiplayerBoardHostView(coordinator: coordinator)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: GameConstants.overlayContentSpacing) {
            Image(systemName: "wifi.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(ThemeColor.accentPrimary)
            Text("Waiting for players to join…")
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(ThemeColor.textPrimary)
            Text("Make sure all devices are on the same Wi-Fi or Bluetooth network.")
                .font(.caption)
                .foregroundStyle(ThemeColor.textPrimary.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.top, GameConstants.verticalSpacing)
    }

    private var peersSection: some View {
        VStack(alignment: .leading, spacing: GameConstants.verticalSpacing) {
            Label("Connected Players (\(sessionManager.connectedPeers.count))", systemImage: "person.2.fill")
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundStyle(ThemeColor.textPrimary)

            if sessionManager.connectedPeers.isEmpty {
                Text("No players connected yet.")
                    .font(.caption)
                    .foregroundStyle(ThemeColor.textPrimary.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(GameConstants.verticalSpacing)
                    .background(ThemeColor.accentPrimary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: GameConstants.largeCornerRadius))
            } else {
                ForEach(sessionManager.connectedPeers, id: \.displayName) { peer in
                    peerRow(for: peer)
                }
            }
        }
    }

    private func peerRow(for peer: MCPeerID) -> some View {
        let peerName = peer.displayName
        let bindingName = Binding(
            get: { peerNames[peerName] ?? peerName },
            set: { peerNames[peerName] = $0 }
        )
        let bindingTeam = Binding(
            get: { peerTeams[peerName] ?? .blue },
            set: { peerTeams[peerName] = $0 }
        )
        return HStack(spacing: GameConstants.handSpacing) {
            Image(systemName: "iphone")
                .foregroundStyle(ThemeColor.accentSecondary)
                .frame(width: 28)

            TextField("Player name", text: bindingName)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity)

            Picker("Team", selection: bindingTeam) {
                Text("Blue").tag(TeamColor.blue)
                Text("Green").tag(TeamColor.green)
                Text("Red").tag(TeamColor.red)
            }
            .pickerStyle(.menu)
            .frame(width: 80)
        }
        .padding(GameConstants.overlayContentSpacing)
        .background(ThemeColor.accentPrimary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: GameConstants.largeCornerRadius))
    }

    private var startButton: some View {
        Button(action: startGame) {
            Label("Start Game", systemImage: "play.circle.fill")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(ThemeColor.textOnAccent)
                .frame(maxWidth: .infinity, minHeight: GameConstants.secondaryButtonHeight)
                .background(
                    LinearGradient(
                        colors: [ThemeColor.accentPrimary, ThemeColor.accentSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: GameConstants.largeCornerRadius))
        }
        .disabled(!isStartEnabled)
        .opacity(isStartEnabled ? 1.0 : 0.4)
        .padding(.bottom, GameConstants.verticalSpacing)
    }

    // MARK: - Logic

    /// Populate default name/team for newly connected peers.
    private func updatePeerDefaults() {
        for peer in sessionManager.connectedPeers {
            let key = peer.displayName
            if peerNames[key] == nil {
                // Peer display name is a vendor UUID — default to "Player N" so the
                // host sees a readable name (editable before starting the game).
                let playerNumber = (peerNames.count) + 1
                peerNames[key] = "Player \(playerNumber)"
            }
            if peerTeams[key] == nil {
                peerTeams[key] = .blue
            }
        }
        // Remove entries for disconnected peers.
        let connectedKeys = Set(sessionManager.connectedPeers.map { $0.displayName })
        peerNames = peerNames.filter { connectedKeys.contains($0.key) }
        peerTeams = peerTeams.filter { connectedKeys.contains($0.key) }
        updateStartEnabled()
    }

    private func updateStartEnabled() {
        isStartEnabled = !sessionManager.connectedPeers.isEmpty
    }

    private func startGame() {
        var players: [Player] = []
        var usedColors: [TeamColor: Int] = [:]

        for peer in sessionManager.connectedPeers {
            let key = peer.displayName
            let name = peerNames[key] ?? key
            let color = peerTeams[key] ?? .blue
            let count = (usedColors[color] ?? 0) + 1
            usedColors[color] = count
            let team = Team(color: color, numberOfPlayers: count)
            var player = Player(name: name, team: team)
            player.peerID = key
            coordinator.assign(peerId: key, to: player.id)
            players.append(player)
        }

        coordinator.startGame(players: players)
        isGameActive = true
    }
}

#Preview("HostLobbyView – No peers") {
    HostLobbyView()
        .environmentObject(GameState())
}
