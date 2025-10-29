//
//  SequenceGameView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 22/10/2025.
//

import SwiftUI

struct SequenceGameView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.colorScheme) private var colorScheme
    @State var numberOfPlayers: Int = 2
    @State var numberOfTeams: Int = 2
    @State private var maxCardsPerPlayer: Int = 7
    @State private var players: [Player] = []
    @State private var teams: [Team] = []
    @State private var turn: Turn = .init(player: Player(name: "Player 1", team: Team(color: .blue, numberOfPlayers: 2) ))
    //    @State private var currentPlayer: Player?
    @State private var team1CoinsPlaced: Int = 0
    @State private var team2CoinsPlaced: Int = 0
    @State private var isOverlayPresent: Bool = false
    @State private var overlayDismissWork: DispatchWorkItem?
    @State private var seats: [Seat] = []
    let colorNames: [Color] = GameConstants.teamColors
    var body: some View {
        ScrollView(showsIndicators: true) {
            ZStack {
                VStack {
                    if let currentPlayerResolved = gameState.currentPlayer {
                        TurnBannerView(
                            playerName: currentPlayerResolved.name,
                            teamColor: currentPlayerResolved.team.color
                        )
                        .padding(.top, 8)
                    }
                    if gameState.currentPlayer != nil {
                        let teamOrder = teams.map { $0.id }
                        let ordered = SeatingRules.interleaveByTeams(gameState.players, teamOrder: teamOrder)
                        let idx = gameState.currentPlayerIndex
                        let anchoredPlayers: [Player] = (!ordered.isEmpty && idx < ordered.count)
                            ? (Array(ordered[idx...]) + Array(ordered[..<idx]))
                            : ordered

                        ZStack {
                            SequenceBoardView(currentPlayer: .constant(gameState.currentPlayer))
                            SeatingRingOverlay(
                                seats: seats,
                                players: anchoredPlayers,            // use anchored list
                                currentPlayerIndex: 0               // anchored bottom is index 0
                            )
                            .allowsHitTesting(false)
                            .opacity(gameState.hasSelection ? 0 : 1)
                            .allowsHitTesting(!gameState.hasSelection)
                        }
                        .padding(12)
                        .background(ThemeColor.boardFelt)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(ThemeColor.border, lineWidth: 1))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 12)
                        .padding(.top, 10)
                    }
                    HStack {
                        if let currentPlayer = gameState.currentPlayer, !currentPlayer.cards.isEmpty {
                            let cardWidth: CGFloat = 40
                            let cardHeight: CGFloat = 60

                            ForEach(currentPlayer.cards) { handCard in
                                let isSelected = handCard.id == gameState.selectedCardId

                                ZStack {
                                    CardFaceView(card: handCard)
                                        .frame(width: cardWidth, height: cardHeight)

                                    // Stroke sized exactly to the card
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(isSelected ? ThemeColor.accentGolden : .clear, lineWidth: 2)
                                        .frame(width: cardWidth, height: cardHeight)
                                }
                                .contentShape(Rectangle())                  // makes whole area tappable
                                .offset(y: isSelected ? -8 : 0)
                                .scaleEffect(isSelected ? 1.06 : 1.0)
                                .shadow(color: .black.opacity(isSelected ? 0.25 : 0.0), radius: 6, y: 3)
                                .zIndex(isSelected ? 1 : 0)
                                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: gameState.selectedCardId)
                                .onTapGesture {
                                    if isSelected {
                                        gameState.clearSelection()
                                    } else {
                                        gameState.selectCard(handCard.id)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(ThemeColor.boardFelt)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(ThemeColor.border, lineWidth: 1))
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: 800)
                .onAppear {
                    // Start game; overlay visibility is driven by overlayMode changes
                    setupGame()
                }
                // Show overlay when mode changes (e.g., .deadCard)
                .onChange(of: gameState.overlayMode) { _, newMode in
                    // Always show overlay when mode changes
                    isOverlayPresent = true
                    // Cancel any previously scheduled dismiss
                    overlayDismissWork?.cancel()
                    overlayDismissWork = nil
                    // Schedule auto-dismiss only for non-deadCard modes
                    if newMode != .deadCard {
                        let work = DispatchWorkItem { isOverlayPresent = false }
                        overlayDismissWork = work
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: work)
                    }
                }
                // Centered overlay
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
                    .overlay(alignment: .center) {
                        if gameState.overlayMode == .deadCard {
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture { gameState.replaceCurrentlySelectedDeadCard() }
                        }
                    }
                }
                
            }
        }
    }
    
    func setupGame() {
        players.removeAll()
        teams.removeAll()
        seats.removeAll()
        
        let totalPlayers = numberOfTeams * numberOfPlayers
        maxCardsPerPlayer = cardsPerPlayer(for: totalPlayers)
        
        // Build local players from team selections (no dealing here)
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
        
        // Hand off to GameState (shuffles, seeds board, deals, sets current player)
        gameState.startGame(with: players)
        
        // Seats depend only on player count
        seats = SeatingLayout.computeSeats(for: gameState.players.count)
        
        team1CoinsPlaced = 0
        team2CoinsPlaced = 0
    }
    
    func cardsPerPlayer(for players: Int) -> Int {
        return GameConstants.cardsPerPlayer(playerCount: players)
    }
}

#Preview {
    NavigationStack {
        SequenceGameView()
            .navigationTitle("Sequcence Game")
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(GameState())
    }
}
