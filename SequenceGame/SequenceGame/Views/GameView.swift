//
//  GameView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 06/11/2025.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.presentationMode) var presentationMode
    @State private var numberOfPlayers: Int
    @State private var numberOfTeams: Int
    @State private var players: [Player] = []
    @State private var teams: [Team] = []
    @State private var seats: [Seat] = []
    @State private var isOverlayPresent: Bool = false
    @State private var overlayDismissWork: DispatchWorkItem?
    
    init(numberOfPlayers: Int = 5, numberOfTeams: Int = 2) {
        _numberOfPlayers = State(initialValue: numberOfPlayers)
        _numberOfTeams = State(initialValue: numberOfTeams)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 3) {
                // Turn Banner
                if let currentPlayer = gameState.currentPlayer {
                    TurnBannerView(
                        playerName: currentPlayer.name,
                        teamColor: currentPlayer.team.color
                    )
                } else {
                    Text("Setting up game...")
                        .padding()
                }
                // Game Board (expands to fill available space)
                if gameState.currentPlayer != nil {
                    let teamOrder = teams.map { $0.id }
                    let ordered = SeatingRules.interleaveByTeams(gameState.players, teamOrder: teamOrder)
                    let currentPlayerIndex = gameState.currentPlayerIndex
                    let anchoredPlayers: [Player] = (!ordered.isEmpty && currentPlayerIndex < ordered.count)
                        ? (Array(ordered[currentPlayerIndex...]) + Array(ordered[..<currentPlayerIndex]))
                        : ordered
                    
                    ZStack {
                        BoardView(currentPlayer: .constant(gameState.currentPlayer))
                        
                        SeatingRingOverlay(
                            seats: seats,
                            players: anchoredPlayers,
                            currentPlayerIndex: 0
                        )
                        .allowsHitTesting(false)
                        .opacity(gameState.hasSelection ? 0 : 1)
                        .animation(.easeInOut(duration: 0.15), value: gameState.hasSelection)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("Loading board...")
                        .foregroundColor(.secondary)
                }
                // Player Hand (separate view)
                HandView()
                    .frame(height: 100)
                    .environmentObject(gameState)
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .navigationTitle("Sequence Game")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Pop to root (MainMenu) by dismissing twice
                        // First dismiss GameView, then GameSettingsView
                        presentationMode.wrappedValue.dismiss()
                        // Use DispatchQueue to dismiss again after a brief delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }, label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(ThemeColor.accentPrimary)
                    })
                }
            }
            .onAppear {
                setupGame()
            }
            .onChange(of: gameState.overlayMode) { _, newMode in
                isOverlayPresent = true
                overlayDismissWork?.cancel()
                overlayDismissWork = nil
                if newMode != .deadCard {
                    let work = DispatchWorkItem { isOverlayPresent = false }
                    overlayDismissWork = work
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: work)
                }
            }
            .overlay(content: {
                // Centered overlay for game events
                if isOverlayPresent, let activePlayer = gameState.currentPlayer {
                    GameOverlayView(
                        playerName: activePlayer.name,
                        teamColor: activePlayer.team.color,
                        borderColor: activePlayer.team.color == ThemeColor.teamGreen ? ThemeColor.overlayTeamGreen :
                            (activePlayer.team.color == ThemeColor.teamBlue ? ThemeColor.overlayTeamBlue : ThemeColor.overlayTeamRed),
                        backgroundColor: activePlayer.team.color == ThemeColor.teamGreen ? ThemeColor.accentPrimary :
                            (activePlayer.team.color == ThemeColor.teamBlue ? ThemeColor.accentSecondary : ThemeColor.accentTertiary),
                        onHelp: { /* present help */ },
                        onClose: { isOverlayPresent = false },
                        mode: gameState.overlayMode
                    )
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isOverlayPresent)
                    .transition(.scale.combined(with: .opacity))
                    .allowsHitTesting(gameState.overlayMode == .deadCard)
                    .overlay(content: {
                        if gameState.overlayMode == .deadCard {
                            Color.clear
                                .contentShape(Rectangle())
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .onTapGesture { gameState.replaceCurrentlySelectedDeadCard() }
                        }
                    })
                }
            })
        }
    }
    
    private func setupGame() {
        players.removeAll()
        teams.removeAll()
        
        let colorNames: [Color] = GameConstants.teamColors
        
        // Build teams and players
        for teamIndex in 0..<numberOfTeams {
            teams.append(Team(color: colorNames[teamIndex], numberOfPlayers: numberOfPlayers))
            for index in 0..<numberOfPlayers {
                let displayIndex = index + 1
                let playerName = "T\(teamIndex + 1)-P\(displayIndex)"
                players.append(Player(name: playerName, team: teams[teamIndex], cards: []))
            }
        }
        
        // Interleave by team
        let teamOrder = teams.map { $0.id }
        players = SeatingRules.interleaveByTeams(players, teamOrder: teamOrder)
        
        // Hand off to GameState
        gameState.startGame(with: players)
        
        // Seats depend only on player count
        seats = SeatingLayout.computeSeats(for: gameState.players.count)
    }
}

#Preview {
    GameView()
        .environmentObject(GameState())
}
