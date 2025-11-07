//
//  HandView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 2025-11-06.
//

import SwiftUI

struct HandView: View {
    @EnvironmentObject var gameState: GameState

    // Layout configuration (defaults keep call sites simple; can be overridden)
    var horizontalInsets: CGFloat = 24    // total (both sides combined)
    var verticalInsets: CGFloat = 8
    var spacing: CGFloat = 8
    var minWidth: CGFloat = 44
    var maxWidth: CGFloat = 54
    var aspect: CGFloat = 1.5

    var body: some View {
        GeometryReader { geo in
            let availableWidth = geo.size.width

            HStack {
                if let currentPlayer = gameState.currentPlayer, !currentPlayer.cards.isEmpty {
                    let cards = currentPlayer.cards
                    let size = calculateCardSize(
                        availableWidth: availableWidth,
                        cardCount: cards.count
                    )

                    HStack(spacing: spacing) {
                        ForEach(cards) { handCard in
                            let isSelected = handCard.id == gameState.selectedCardId

                            ZStack {
                                CardFaceView(card: handCard)
                                    .frame(width: size.width, height: size.height)

                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(isSelected ? ThemeColor.accentGolden : .clear, lineWidth: 2)
                                    .frame(width: size.width, height: size.height)
                            }
                            .contentShape(Rectangle())
                            .offset(y: isSelected ? -8 : 0)
                            .scaleEffect(isSelected ? 1.06 : 1.0)
                            .shadow(color: .black.opacity(isSelected ? 0.25 : 0.0), radius: 6, y: 3)
                            .zIndex(isSelected ? 1 : 0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: gameState.selectedCardId)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("\(handCard.cardFace) of \(handCard.suit)")
                            .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : [.isButton])
                            .onTapGesture {
                                if isSelected {
                                    gameState.clearSelection()
                                } else {
                                    gameState.selectCard(handCard.id)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.vertical, verticalInsets)
            .padding(.horizontal, horizontalInsets / 2) // split total across sides
            .background(ThemeColor.boardFelt)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(ThemeColor.border, lineWidth: 1))
            .accessibilityIdentifier("playerHand")
        }
    }

    // Single sizing helper internal to HandView
    private func calculateCardSize(
        availableWidth: CGFloat,
        cardCount: Int
    ) -> (width: CGFloat, height: CGFloat) {
        guard cardCount > 0 else { return (minWidth, minWidth * aspect) }
        let inner = max(0, availableWidth - horizontalInsets)
        let totalSpacing = spacing * CGFloat(max(0, cardCount - 1))
        let raw = (inner - totalSpacing) / CGFloat(cardCount)
        let width = min(max(raw, minWidth), maxWidth)
        return (width, width * aspect)
    }
}

#Preview {
    // Hard-coded preview data
    let teamBlue = Team(color: .blue, numberOfPlayers: 2)
    let teamRed = Team(color: .red, numberOfPlayers: 2)
    let player1 = Player(
        name: "T1-P1",
        team: teamBlue,
        cards: [
            Card(cardFace: .queen, suit: .clubs),
            Card(cardFace: .eight, suit: .diamonds),
            Card(cardFace: .four, suit: .hearts),
            Card(cardFace: .two, suit: .hearts),
            Card(cardFace: .nine, suit: .spades)
        ]
    )
    let player2 = Player(name: "T1-P2", team: teamBlue, cards: [])
    let player3 = Player(name: "T2-P1", team: teamRed, cards: [])
    let player4 = Player(name: "T2-P2", team: teamRed, cards: [])
    
    let gameState = GameState()
    gameState.startGame(with: [player1, player2, player3, player4])
    
    return HandView()
        .environmentObject(gameState)
        .frame(width: 420, height: 130)
}
