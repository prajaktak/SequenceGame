//
//  MultiplayerPositionSelectorView.swift
//  SequenceGame
//
//  Shown on iPhone when a card is selected and valid positions are available.
//  Displays a list of tappable position buttons (e.g. "Row 3, Column 5").
//  Tapping a position sends .selectPosition to the host; the confirmation
//  sheet appears after the host echoes back the pendingPosition.
//

import SwiftUI

/// iPhone view showing tappable position buttons for the currently selected card.
///
/// Appears after the player selects a card and the host broadcasts `validPositions`.
/// Each button sends `.selectPosition` to the host, which then echoes back a
/// `pendingPosition` and triggers `MultiplayerConfirmPlacementView`.
struct MultiplayerPositionSelectorView: View {

    // MARK: - Input

    /// Valid positions for the currently selected card.
    let validPositions: [Position]

    /// The card ID the player selected (passed through to confirmation sheet).
    let selectedCardId: UUID

    /// The client used to send actions to the host.
    @ObservedObject var client: MultiplayerClient

    // MARK: - State

    /// The position the player tapped; drives the confirmation sheet.
    @State private var pendingPosition: Position?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColor.backgroundMenu.ignoresSafeArea()

                if validPositions.isEmpty {
                    emptyState
                } else {
                    positionList
                }
            }
            .navigationTitle("Choose Position")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColor.backgroundMenu, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(item: $pendingPosition) { position in
                MultiplayerConfirmPlacementView(
                    position: position,
                    cardId: selectedCardId,
                    client: client
                )
                .presentationDetents([.medium])
            }
            .onChange(of: client.latestBroadcast?.pendingPosition) { newPending in
                pendingPosition = newPending
            }
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        VStack(spacing: GameConstants.overlayContentSpacing) {
            Image(systemName: "mappin.slash.circle")
                .font(.system(size: 48))
                .foregroundStyle(ThemeColor.textPrimary.opacity(0.4))
            Text("No valid positions for this card.")
                .font(.subheadline)
                .foregroundStyle(ThemeColor.textPrimary.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }

    private var positionList: some View {
        ScrollView {
            LazyVStack(spacing: GameConstants.overlayContentSpacing) {
                ForEach(validPositions, id: \.self) { position in
                    positionButton(for: position)
                }
            }
            .padding(GameConstants.horizontalPadding)
        }
    }

    private func positionButton(for position: Position) -> some View {
        let label = HStack {
            Image(systemName: "mappin.circle.fill")
                .foregroundStyle(ThemeColor.accentPrimary)
                .font(.title3)
            Text("Row \(position.row + 1), Column \(position.col + 1)")
                .font(.system(.body, design: .rounded).weight(.medium))
                .foregroundStyle(ThemeColor.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(ThemeColor.textPrimary.opacity(0.4))
        }
        .padding(GameConstants.verticalSpacing)
        .background(ThemeColor.accentPrimary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: GameConstants.largeCornerRadius))
        return Button(action: { selectPosition(position) }, label: { label })
    }

    // MARK: - Actions

    private func selectPosition(_ position: Position) {
        client.selectPosition(position)
        // The sheet will open once the host echoes back pendingPosition
        // via onChange(of: client.latestBroadcast?.pendingPosition).
    }
}

extension Position: Identifiable {
    public var id: String { "\(row)-\(col)" }
}

#Preview("MultiplayerPositionSelectorView") {
    let sessionManager = MultipeerSessionManager(displayName: "Preview")
    let client = MultiplayerClient(sessionManager: sessionManager, localPlayerId: UUID())
    MultiplayerPositionSelectorView(
        validPositions: [Position(row: 2, col: 3), Position(row: 5, col: 7), Position(row: 8, col: 1)],
        selectedCardId: UUID(),
        client: client
    )
}
