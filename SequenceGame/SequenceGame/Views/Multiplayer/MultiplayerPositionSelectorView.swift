//
//  MultiplayerPositionSelectorView.swift
//  SequenceGame
//
//  Shown on iPhone when a card is selected and valid positions are available.
//  Displays a list of tappable position buttons (e.g. "Row 3, Column 5").
//  Tapping a position sends .confirmPlacement directly to the host —
//  no nested sheet is used, avoiding a SwiftUI sheet-inside-sheet limitation.
//

import SwiftUI

/// iPhone view showing tappable position buttons for the currently selected card.
///
/// Appears after the player selects a card and the host broadcasts `validPositions`.
/// Tapping a position immediately sends `.confirmPlacement` to the host, which
/// executes the play and broadcasts updated state. The parent sheet dismisses
/// automatically once `selectedCardId` becomes nil in the next broadcast.
struct MultiplayerPositionSelectorView: View {

    // MARK: - Input

    /// Valid positions for the currently selected card.
    let validPositions: [Position]

    /// The card ID the player selected.
    let selectedCardId: UUID

    /// The client used to send actions to the host.
    @ObservedObject var client: MultiplayerClient

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
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(ThemeColor.accentSecondary.opacity(0.7))
        }
        .padding(GameConstants.verticalSpacing)
        .background(ThemeColor.accentPrimary.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: GameConstants.largeCornerRadius))
        return Button(action: { confirmPosition(position) }, label: { label })
    }

    // MARK: - Actions

    private func confirmPosition(_ position: Position) {
        // Send confirmPlacement directly — avoids a nested sheet (sheet-inside-sheet
        // is unreliable in SwiftUI). The host executes the play and broadcasts the
        // updated state; the parent sheet dismisses once selectedCardId becomes nil.
        client.confirmPlacement(position: position, cardId: selectedCardId)
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
