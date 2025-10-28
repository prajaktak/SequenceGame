//
//  SequenceGameView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 22/10/2025.
//

import SwiftUI

struct SequenceGameView: View {
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
    let colorNames: [Color] = [.blue, .green, .red]
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
                    .foregroundStyle(.black)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                    if let currentPlayer = currentPlayer {
                        SequenceBoardView(currentPlayer: $currentPlayer)
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
                }
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
        switch players {
        case 2:
            return 7
        case 3, 4:
            return 6
        case 6:
            return 5
        case 8, 9:
            return 4
        case 10, 12:
            return 3
        default:
            return 0 // Or handle invalid input as needed
        }
    }
}

#Preview {
    NavigationStack {
        SequenceGameView()
            .navigationTitle("Sequcence Game")
            .navigationBarTitleDisplayMode(.inline)
    }
}
