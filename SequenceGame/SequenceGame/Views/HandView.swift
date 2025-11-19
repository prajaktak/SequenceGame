//
//  HandView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 2025-11-06.
//

import SwiftUI

/// Displays the current player's hand of cards at the bottom of the game screen.
///
/// `HandView` shows cards in a horizontal scrollable layout with:
/// - Adaptive card sizing based on available width and card count
/// - Visual selection state (highlighted border, scale, and offset)
/// - Tap gestures for card selection/deselection
/// - Accessibility labels for VoiceOver support
///
/// The view automatically calculates optimal card dimensions to fit within the available
/// space while respecting minimum and maximum size constraints from `GameConstants`.
struct HandView: View {
    /// The game state containing the current player and their cards.
    @EnvironmentObject var gameState: GameState

    // MARK: - Layout Configuration
    
    /// Layout configuration values with defaults from GameConstants.
    /// These can be overridden at initialization for custom layouts or testing.
    
    var horizontalInsets: CGFloat = GameConstants.UISizing.handHorizontalInsets
    var verticalInsets: CGFloat = GameConstants.UISizing.handVerticalInsets
    var spacing: CGFloat = GameConstants.UISizing.handSpacing
    var minWidth: CGFloat = GameConstants.UISizing.handMinCardWidth
    var maxWidth: CGFloat = GameConstants.UISizing.handMaxCardWidth
    var aspect: CGFloat = GameConstants.UISizing.handCardAspect

    // MARK: - Body
    
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
                            let accessibilityLabel = "\(handCard.cardFace.accessibilityName) of \(handCard.suit.accessibilityName)"
                            let isSelected = handCard.id == gameState.selectedCardId

                            ZStack {
                                CardFaceView(card: handCard)
                                    .frame(width: size.width, height: size.height)

                                RoundedRectangle(cornerRadius: GameConstants.UISizing.handCardCornerRadius)
                                    .stroke(isSelected ? ThemeColor.accentGolden : .clear, lineWidth: GameConstants.UISizing.handCardBorderWidth)
                                    .frame(width: size.width, height: size.height)
                            }
                            .contentShape(Rectangle())
                            .offset(y: isSelected ? GameConstants.UISizing.handCardSelectedOffset : 0)
                            .scaleEffect(isSelected ? GameConstants.UISizing.handCardSelectedScale : 1.0)
                            .shadow(color: .black.opacity(isSelected ? GameConstants.UISizing.handCardShadowOpacity : 0.0),
                                    radius: GameConstants.UISizing.handCardShadowRadius,
                                    y: GameConstants.UISizing.handCardShadowY)
                            .zIndex(isSelected ? 1 : 0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: gameState.selectedCardId)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(accessibilityLabel)
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

    // MARK: - Helper Methods
    
    /// Calculates optimal card dimensions based on available width and number of cards.
    ///
    /// Distributes available space evenly among cards while respecting minimum and maximum
    /// size constraints. Maintains the configured aspect ratio for card height.
    ///
    /// - Parameters:
    ///   - availableWidth: Total horizontal space available for the card layout
    ///   - cardCount: Number of cards to display
    ///
    /// - Returns: A tuple containing the calculated width and height for each card
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
