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
    @State var numberOfPlayers: Int
    @State var numberOfTeams: Int
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
    
    init(numberOfPlayers: Int = 2, numberOfTeams: Int = 2) {
        _numberOfPlayers = State(initialValue: numberOfPlayers)
        _numberOfTeams = State(initialValue: numberOfTeams)
    }
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Step 1: Turn Banner (fixed size at top)
                if let currentPlayerResolved = gameState.currentPlayer {
                    TurnBannerView(
                        playerName: currentPlayerResolved.name,
                        teamColor: currentPlayerResolved.team.color
                    )
                    .padding(.top, 8)
                }
                
                // Step 2: Game Board (expands to fill available space)
                if gameState.currentPlayer != nil {
                    let teamOrder = teams.map { $0.id }
                    let ordered = SeatingRules.interleaveByTeams(gameState.players, teamOrder: teamOrder)
                    let currentPlayerIndex = gameState.currentPlayerIndex
                    let anchoredPlayers: [Player] = (!ordered.isEmpty && currentPlayerIndex < ordered.count)
                        ? (Array(ordered[currentPlayerIndex...]) + Array(ordered[..<currentPlayerIndex]))
                        : ordered
                    
                    ZStack {
                        SequenceBoardView(currentPlayer: .constant(gameState.currentPlayer))
                        SeatingRingOverlay(
                            seats: seats,
                            players: anchoredPlayers,
                            currentPlayerIndex: 0
                        )
                        .allowsHitTesting(false)
                        .opacity(gameState.hasSelection ? 0 : 1)
                        .allowsHitTesting(!gameState.hasSelection)
                    }
                    .padding(6)
                    .background(ThemeColor.boardFelt)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(ThemeColor.border, lineWidth: 1))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 12)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Expand to fill space
                }
                
                // Step 3: Player Hand (fixed size at bottom)
                HStack {
                        if let currentPlayer = gameState.currentPlayer, !currentPlayer.cards.isEmpty {
                            // Sizing: clamp width, compute height from aspect
                            let minCardWidth: CGFloat = 44
                            let maxCardWidth: CGFloat = 64
                            let baseCardWidth: CGFloat = 52
                            let cardWidth = max(minCardWidth, min(maxCardWidth, baseCardWidth))
                            let cardHeight = cardWidth * 1.5

                            ForEach(currentPlayer.cards) { handCard in
                                let isSelected = handCard.id == gameState.selectedCardId

                                ZStack {
                                    CardFaceView(card: handCard)
                                        .frame(width: cardWidth, height: cardHeight)

                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(isSelected ? ThemeColor.accentGolden : .clear, lineWidth: 2)
                                        .frame(width: cardWidth, height: cardHeight)
                                }
                                .contentShape(Rectangle())
                                .offset(y: isSelected ? -8 : 0)
                                .scaleEffect(isSelected ? 1.06 : 1.0)
                                .shadow(color: .black.opacity(isSelected ? 0.25 : 0.0), radius: 6, y: 3)
                                .zIndex(isSelected ? 1 : 0)
                                .modifier(OptionalSpringAnimation(enabled: !UIAccessibility.isReduceMotionEnabled,
                                    value: gameState.selectedCardId))
                                .accessibilityElement(children: .ignore) // Provide custom label/traits
                                .accessibilityLabel("\(handCard.cardFace) of \(handCard.suit)")
                                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : [.isButton])
//                                .accessibilityAddTraits([.button] + (isSelected ? [.isSelected] : []))
                                .accessibilityHint(isSelected ? "Tap to deselect" : "Tap to select")
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
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                    .frame(maxWidth: .infinity)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .padding(.horizontal, 16)
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
            .overlay {
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
