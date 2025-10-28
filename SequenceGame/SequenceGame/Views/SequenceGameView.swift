//
//  SequenceGameView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 22/10/2025.
//

import SwiftUI

struct SequenceGameView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var numberOfPlayers: Int = 2
    @State var numberOfTeams: Int = 2
    @State private var maxCardsPerPlayer: Int = 7
    @State private var players: [Player] = []
    @State private var teams: [Team] = []
    @State private var turn: Turn = .init(player: Player(name: "Player 1", team: Team(color: .blue, numberOfPlayers: 2) ))
    @State private var currentPlayer: Player?
    @State private var team1CoinsPlaced: Int = 0
    @State private var team2CoinsPlaced: Int = 0
    @State private var gameOverViewOverlay: GameOverviewOverlay?
    @State private var isOverlayPresent: Bool = false
    let colorNames: [Color] = GameConstants.teamColors
    let dealDeck: Deck = .init()
    var body: some View {
        ScrollView(showsIndicators: true) {
            ZStack {
                VStack {
                    Button("Current Player: \(currentPlayer?.name ?? "No Player")") {
                        if gameOverViewOverlay != nil {
                            isOverlayPresent = true
                        }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ThemeColor.textOnAccent)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(ThemeColor.accentPrimary)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                    .padding(.top, 8)
                    if let currentPlayer = currentPlayer {
                        SequenceBoardView(currentPlayer: $currentPlayer)
                            .padding(12)
                            .background(ThemeColor.boardFelt)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(ThemeColor.border, lineWidth: 1))
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 12)
                            .padding(.top, 10)
                    }
                    HStack {
                        if let currentPlayer = currentPlayer, !currentPlayer.cards.isEmpty {
                            ForEach(currentPlayer.cards) {card in
                                CardFaceView(card: card)
                                    .frame(width: 40, height: 60)
                                    .border(Color.gray)
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
                    setupGame()
                }
                .onTapGesture {
                    isOverlayPresent = false
                }
                VStack {
                    if gameOverViewOverlay != nil {
                        gameOverViewOverlay
                    }
                    Spacer()
                }
                
            }
        }
    }
    
    func setupGame() {
        dealDeck.shuffle()
        maxCardsPerPlayer = cardsPerPlayer(for: numberOfPlayers)
        print(maxCardsPerPlayer)
        for teamIndex in 0..<numberOfTeams {
            teams.append(Team(color: colorNames[teamIndex], numberOfPlayers: numberOfPlayers))
            for index in 0..<numberOfPlayers {
                var cards: [Card] = []
                print(teams[teamIndex])
                for _ in 0..<maxCardsPerPlayer {
                    cards.append(dealDeck.drawCard() ?? Card(cardFace: .ace, suit: .hearts))
                }
                self.players.append(Player(name: "Player\(index)", team: teams[teamIndex], cards: cards))
                print(self.players[index])
            }
        }
        
        turn = Turn(player: players[0])
        currentPlayer = players[0]  // Set the current player
        team1CoinsPlaced = 0
        team2CoinsPlaced = 0
        gameOverViewOverlay = GameOverviewOverlay(team1CoinsPlaced: team1CoinsPlaced, team2CoinsPlaced: team2CoinsPlaced, isVisible: $isOverlayPresent, playerName: turn.player.name)
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
    }
}
