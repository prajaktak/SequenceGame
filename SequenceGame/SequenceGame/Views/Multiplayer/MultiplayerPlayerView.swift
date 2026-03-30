//
//  MultiplayerPlayerView.swift
//  SequenceGame
//
//  iPhone in-game root view for a multiplayer player.
//  Shows the player's hand, team scores, turn status, and routes to
//  waiting screen or position selector as appropriate.
//

import SwiftUI

/// Root iPhone in-game view for local multiplayer.
///
/// Derives all display data from `MultiplayerClient.latestBroadcast`.
/// - When it's this player's turn: shows hand + position selector sheet.
/// - When it's another player's turn: shows `MultiplayerWaitingView`.
/// - Shows a discard toast when a dead-card event is broadcast.
struct MultiplayerPlayerView: View {

    // MARK: - Dependencies

    @ObservedObject var client: MultiplayerClient

    // MARK: - State

    @State private var showPositionSelector: Bool = false
    @State private var showDiscardToast: Bool = false

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            ThemeColor.backgroundGame.ignoresSafeArea()

            if client.isMyTurn {
                myTurnContent
            } else {
                waitingContent
            }

            // Discard toast — layered on top of everything.
            if showDiscardToast, let event = client.latestBroadcast?.lastDiscardEvent {
                MultiplayerDiscardToastView(event: event)
                    .padding(.horizontal, GameConstants.horizontalPadding)
                    .padding(.top, GameConstants.verticalSpacing)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onChange(of: client.latestBroadcast?.lastDiscardEvent) { event in
            if event != nil {
                showDiscardToastBriefly()
            }
        }
        .onChange(of: client.latestBroadcast?.selectedCardId) { cardId in
            showPositionSelector = (cardId != nil) && client.isMyTurn
        }
        .sheet(isPresented: $showPositionSelector) {
            if let cardId = client.selectedCardId {
                MultiplayerPositionSelectorView(
                    validPositions: client.validPositions,
                    selectedCardId: cardId,
                    client: client
                )
                .presentationDetents([.medium, .large])
            }
        }
    }

    // MARK: - Subviews

    private var myTurnContent: some View {
        VStack(spacing: 0) {
            teamScoresBar
            turnBanner
            Spacer()
            handSection
        }
    }

    private var waitingContent: some View {
        Group {
            if let broadcast = client.latestBroadcast,
               let currentInfo = broadcast.playerInfoList.first(where: { $0.id == broadcast.currentPlayerId }) {
                MultiplayerWaitingView(
                    currentPlayerName: currentInfo.name,
                    currentPlayerTeamColor: currentInfo.teamColor
                )
            } else {
                MultiplayerWaitingView(
                    currentPlayerName: "Other player",
                    currentPlayerTeamColor: .blue
                )
            }
        }
    }

    private var teamScoresBar: some View {
        HStack(spacing: GameConstants.handSpacing) {
            ForEach(Array(client.teamScores.keys.sorted()), id: \.self) { teamKey in
                let score = client.teamScores[teamKey] ?? 0
                Text("\(teamKey.capitalized): \(score)")
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(ThemeColor.textOnAccent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(ThemeColor.accentPrimary.opacity(0.8))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, GameConstants.horizontalPadding)
        .padding(.top, GameConstants.overlayContentSpacing)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var turnBanner: some View {
        HStack {
            Image(systemName: "star.circle.fill")
                .foregroundStyle(ThemeColor.accentSecondary)
            Text("Your Turn!")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(ThemeColor.textPrimary)
            Spacer()
            Text("Tap a card to play")
                .font(.caption)
                .foregroundStyle(ThemeColor.textPrimary.opacity(0.6))
        }
        .padding(.horizontal, GameConstants.horizontalPadding)
        .padding(.vertical, GameConstants.overlayContentSpacing)
        .background(ThemeColor.accentSecondary.opacity(0.12))
    }

    private var handSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: GameConstants.handSpacing) {
                ForEach(client.myCards) { card in
                    cardButton(for: card)
                }
            }
            .padding(.horizontal, GameConstants.horizontalPadding)
            .padding(.vertical, GameConstants.verticalSpacing)
        }
        .frame(height: GameConstants.handMaxCardWidth * GameConstants.handCardAspect + GameConstants.verticalSpacing * 2)
        .background(ThemeColor.backgroundMenu)
    }

    private func cardButton(for card: Card) -> some View {
        let isSelected = client.selectedCardId == card.id
        let cardLabel = CardFaceView(card: card)
            .frame(
                width: GameConstants.handMaxCardWidth,
                height: GameConstants.handMaxCardWidth * GameConstants.handCardAspect
            )
            .clipShape(RoundedRectangle(cornerRadius: GameConstants.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: GameConstants.cardCornerRadius)
                    .stroke(isSelected ? ThemeColor.accentPrimary : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        return Button(action: { selectCard(card) }, label: { cardLabel })
            .disabled(!client.isMyTurn)
    }

    // MARK: - Actions

    private func selectCard(_ card: Card) {
        if client.selectedCardId == card.id {
            client.deselectCard()
        } else {
            client.selectCard(card.id)
        }
    }

    private func showDiscardToastBriefly() {
        withAnimation { showDiscardToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { showDiscardToast = false }
        }
    }
}

#Preview("MultiplayerPlayerView – My Turn") {
    let sessionManager = MultipeerSessionManager(displayName: "Preview")
    let client = MultiplayerClient(sessionManager: sessionManager, localPlayerId: UUID())
    MultiplayerPlayerView(client: client)
}
