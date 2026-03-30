//
//  MultiplayerConfirmPlacementView.swift
//  SequenceGame
//
//  Sheet shown on the iPhone after the player taps a position.
//  Asks "Place chip at Row X, Col Y?" with Confirm / Cancel.
//

import SwiftUI

/// Confirmation sheet shown when the iPhone player has selected a position.
///
/// Presents the row and column the player tapped and sends either
/// `.confirmPlacement` or `.cancelPlacement` to the host via `client`.
struct MultiplayerConfirmPlacementView: View {

    // MARK: - Input

    /// The position the player selected on the position selector.
    let position: Position

    /// The card ID that was selected (needed for confirmPlacement action).
    let cardId: UUID

    /// The client used to send actions to the host.
    @ObservedObject var client: MultiplayerClient

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColor.backgroundMenu.ignoresSafeArea()

                VStack(spacing: GameConstants.largeSpacing) {
                    placementPreview
                    actionButtons
                }
                .padding(GameConstants.horizontalPadding)
            }
            .navigationTitle("Confirm Placement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColor.backgroundMenu, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Subviews

    private var placementPreview: some View {
        VStack(spacing: GameConstants.overlayContentSpacing) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(ThemeColor.accentPrimary)

            Text("Place chip at")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))

            Text("Row \(position.row + 1), Column \(position.col + 1)")
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(ThemeColor.textPrimary)
        }
        .padding(.top, GameConstants.largeSpacing)
    }

    private var actionButtons: some View {
        VStack(spacing: GameConstants.verticalSpacing) {
            Button(action: confirmPlacement) {
                Label("Place Chip", systemImage: "checkmark.circle.fill")
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

            Button(action: cancelPlacement) {
                Label("Cancel", systemImage: "xmark.circle")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(ThemeColor.textPrimary)
                    .frame(maxWidth: .infinity, minHeight: GameConstants.secondaryButtonHeight)
                    .background(ThemeColor.accentPrimary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: GameConstants.largeCornerRadius))
            }
        }
    }

    // MARK: - Actions

    private func confirmPlacement() {
        client.confirmPlacement(position: position, cardId: cardId)
        dismiss()
    }

    private func cancelPlacement() {
        client.cancelPlacement()
        dismiss()
    }
}

#Preview("MultiplayerConfirmPlacementView") {
    let sessionManager = MultipeerSessionManager(displayName: "Preview")
    let client = MultiplayerClient(sessionManager: sessionManager, localPlayerId: UUID())
    MultiplayerConfirmPlacementView(
        position: Position(row: 3, col: 5),
        cardId: UUID(),
        client: client
    )
}
