//
//  MultiplayerHandView.swift
//  SequenceGame
//
//  Hand view for multiplayer iPhone players.
//  Mirrors single-player HandView layout but drives selection via MultiplayerClient
//  instead of GameState, since the local player's cards are managed by the client.
//

import SwiftUI

/// Displays the local player's hand during a multiplayer game.
///
/// Card selection and deselection are forwarded to `MultiplayerClient`
/// rather than the local `GameState`, keeping the host as the single source of truth.
struct MultiplayerHandView: View {

    @ObservedObject var client: MultiplayerClient

    var body: some View {
        GeometryReader { geo in
            let availableWidth = geo.size.width
            let cards = client.myCards
            let cardSize = calculateCardSize(availableWidth: availableWidth, cardCount: cards.count)

            HStack {
                HStack(spacing: GameConstants.handSpacing) {
                    ForEach(cards) { card in
                        let isSelected = client.selectedCardId == card.id
                        ZStack {
                            CardFaceView(card: card)
                                .frame(width: cardSize.width, height: cardSize.height)

                            RoundedRectangle(cornerRadius: GameConstants.handCardCornerRadius)
                                .stroke(isSelected ? ThemeColor.accentGolden : .clear, lineWidth: GameConstants.handCardBorderWidth)
                                .frame(width: cardSize.width, height: cardSize.height)
                        }
                        .contentShape(Rectangle())
                        .offset(y: isSelected ? GameConstants.handCardSelectedOffset : 0)
                        .scaleEffect(isSelected ? GameConstants.handCardSelectedScale : 1.0)
                        .shadow(
                            color: .black.opacity(isSelected ? GameConstants.handCardShadowOpacity : 0.0),
                            radius: GameConstants.handCardShadowRadius,
                            y: GameConstants.handCardShadowY
                        )
                        .zIndex(isSelected ? 1 : 0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: client.selectedCardId)
                        .onTapGesture {
                            guard client.isMyTurn else { return }
                            if isSelected {
                                client.deselectCard()
                            } else {
                                client.selectCard(card.id)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.vertical, GameConstants.handVerticalInsets)
            .padding(.horizontal, GameConstants.handHorizontalInsets / 2)
            .background(ThemeColor.boardFelt)
            .clipShape(RoundedRectangle(cornerRadius: GameConstants.universalCornerRadius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: GameConstants.universalCornerRadius).stroke(ThemeColor.border, lineWidth: GameConstants.universalBorderWidth))
        }
    }

    private func calculateCardSize(availableWidth: CGFloat, cardCount: Int) -> (width: CGFloat, height: CGFloat) {
        let minWidth = GameConstants.handMinCardWidth
        let maxWidth = GameConstants.handMaxCardWidth
        let aspect = GameConstants.handCardAspect
        let spacing = GameConstants.handSpacing
        let insets = GameConstants.handHorizontalInsets
        guard cardCount > 0 else { return (minWidth, minWidth * aspect) }
        let inner = max(0, availableWidth - insets)
        let totalSpacing = spacing * CGFloat(max(0, cardCount - 1))
        let raw = (inner - totalSpacing) / CGFloat(cardCount)
        let width = min(max(raw, minWidth), maxWidth)
        return (width, width * aspect)
    }
}

#Preview("MultiplayerHandView") {
    let sessionManager = MultipeerSessionManager(displayName: "Preview")
    let client = MultiplayerClient(sessionManager: sessionManager, localPlayerId: UUID())
    MultiplayerHandView(client: client)
        .frame(height: 100)
}
