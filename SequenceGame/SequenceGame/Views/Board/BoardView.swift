//
//  BoardView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 06/11/2025.
//

import SwiftUI

struct BoardView: View {
    @EnvironmentObject var gameState: GameState
    @Binding var currentPlayer: Player?
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            // Single source of truth for sizing
            let borderThickness = GameConstants.boardBorderThickness
            let contentInsets = EdgeInsets(
                top: GameConstants.boardContentInsetTop,
                leading: GameConstants.boardContentInsetLeading,
                bottom: GameConstants.boardContentInsetBottom,
                trailing: GameConstants.boardContentInsetTrailing
            )
            
            // Compute available drawing area by subtracting border and content insets once
            let availableWidth = geometry.size.width - (borderThickness * 2) - (contentInsets.leading + contentInsets.trailing)
            let availableHeight = geometry.size.height - (borderThickness * 2) - (contentInsets.top + contentInsets.bottom)
            
            let tileSize = calculateTileSize(
                availableWidth: availableWidth,
                availableHeight: availableHeight
            )
            let gridWidth = tileSize.width * CGFloat(GameConstants.boardColumns)
            let gridHeight = tileSize.height * CGFloat(GameConstants.boardRows)
            
            // Grid constrained to computed size; container provides background/border
            VStack(spacing: 0) {
                ForEach(0..<GameConstants.boardRows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<GameConstants.boardColumns, id: \.self) { column in
                            tileCell(row: row, column: column, tileSize: tileSize)
                        }
                    }
                }
            }
            .frame(width: gridWidth, height: gridHeight)
            .padding(contentInsets)
            .background(colorScheme == .dark ? Color("woodDark") : Color("wood"))
            .clipShape(RoundedRectangle(cornerRadius: GameConstants.boardCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GameConstants.boardCornerRadius, style: .continuous)
                    .stroke(ThemeColor.boardFelt, lineWidth: borderThickness)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .accessibilityIdentifier("gameBoard")
        }
    }
    private func calculateTileSize(availableWidth: CGFloat, availableHeight: CGFloat) -> (width: CGFloat, height: CGFloat) {
        let numberOfColumns = CGFloat(GameConstants.boardColumns)
        let numberOfRows = CGFloat(GameConstants.boardRows)
        
        let calculatedTileWidth = availableWidth / numberOfColumns
        let calculatedTileHeight = availableHeight / numberOfRows
        
        // Maintain card aspect ratio (1:1.6)
        let tileWidth: CGFloat
        let tileHeight: CGFloat
        
        let aspectRatio = GameConstants.cardAspectRatio
        if calculatedTileWidth * aspectRatio <= calculatedTileHeight {
            tileWidth = calculatedTileWidth
            tileHeight = calculatedTileWidth * aspectRatio
        } else {
            tileHeight = calculatedTileHeight
            tileWidth = calculatedTileHeight / aspectRatio
        }
        
        return (width: tileWidth, height: tileHeight)
    }
    
    /// Checks if a tile at the given position is part of any detected sequence
    ///
    /// Uses the cached `tilesInSequences` set from GameState for O(1) lookup performance
    /// instead of O(n×m) nested array searches.
    private func isTileInSequence(row: Int, column: Int) -> Bool {
        let tile = gameState.boardTiles[row][column]
        return gameState.tilesInSequences.contains(tile.id)
    }
    
    /// Returns the team color for a tile if it's part of a sequence
    private func teamColorForSequenceTile(row: Int, column: Int) -> Color? {
        let tile = gameState.boardTiles[row][column]
        for sequence in gameState.detectedSequence  where sequence.tiles.contains(where: { $0.id == tile.id }) {
            return ThemeColor.getTeamColor(for: sequence.teamColor)
        }
        return nil
    }
    
    @ViewBuilder
    private func sequenceHighlight(_ isInSequence: Bool, teamColor: Color, tileSize: (width: CGFloat, height: CGFloat)) -> some View {
        if isInSequence {
            // Calculate perimeter for dash animation
            let perimeter = 2.0 * (tileSize.width + tileSize.height)

            let shimmerBorderSettings = ShimmerBorderSettings(
                teamColor: teamColor,
                frameWidth: tileSize.width,
                frameHeight: tileSize.height,
                dashArray: [tileSize.width / 2, perimeter - tileSize.width / 2],
                dashPhasePositive: perimeter,
                dashPhaseNegative: -perimeter,
                animationDuration: 3.0,
                borderWidth: 2
            )

            ZStack {
                // Background fill with shimmer effect
                ZStack {
                    // Base colored background
                    RoundedRectangle(cornerRadius: 2)
                        .fill(teamColor.opacity(0.25))

                    // Shimmer overlay on background
                    RoundedRectangle(cornerRadius: 2)
                        .fill(teamColor.opacity(0.5))
                        .modifier(Shimmer(teamColor: teamColor))
                }
                .border(teamColor, width: 2)
                // Animated shimmer border on top
                ShimmerBorder(shimmerBorderSetting: shimmerBorderSettings) {
                    Color.clear
                        
                }
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func tileCell(row: Int, column: Int, tileSize: (width: CGFloat, height: CGFloat)) -> some View {
        let isInSequence = isTileInSequence(row: row, column: column)
        let sequenceTeamColor = teamColorForSequenceTile(row: row, column: column) ?? ThemeColor.teamBlue
        let tile = gameState.boardTiles[row][column]
        let isValid = gameState.validPositionsForSelectedCard.contains { $0.row == row && $0.col == column }
        
        if tile.isEmpty {
            // Render empty tile using the same TileView to keep sizes consistent
            TileView(
                isCard: false,
                card: nil,
                color: .secondary,
                isChipVisible: false
            )
            .frame(width: tileSize.width, height: tileSize.height)
            .contentShape(Rectangle())
            .accessibilityLabel("Empty corner tile") 
            .accessibilityAddTraits(.isStaticText)
            .opacity(0.8)
        } else if let card = tile.card {
            let teamColor = ThemeColor.getTeamColor(for: currentPlayer?.team.color ?? .blue)
            TileView(
                card: card,
                color: ThemeColor.getTeamColor(for: tile.chip?.color ?? .blue),
                isChipVisible: tile.chip?.isPlaced ?? false
            )
            .frame(width: tileSize.width, height: tileSize.height)
            .contentShape(Rectangle())
            .border(teamColor.opacity(isValid ? 1 : 0), width: 3)
            .accessibilityLabel(accessibilityLabelForTile(row: row, column: column))
            .accessibilityHint(isValid ? "Double tap to place chip" : "")
            .accessibilityAddTraits(isValid ? .isButton : [])
            .overlay {
                if isValid {
                    ValidTileForCardIndicator(teamColor: teamColor, tileSize: tileSize)
                }
            }
            .overlay {
                // Add sequence highlight overlay
                sequenceHighlight(isInSequence, teamColor: sequenceTeamColor, tileSize: tileSize)
                    .opacity(isInSequence ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isInSequence)
            }
            .onTapGesture {
                // Prevent tile interaction when game is over
                guard gameState.overlayMode != .gameOver else { return }
                guard isValid else { return }
                guard let selectedId = gameState.selectedCardId else { return }
                defer { gameState.clearSelection() }
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    gameState.performPlay(atPos: Position(row: row, col: column), using: selectedId)
                }
            }
        }
    }
    // Helper function to generate accessibility label
    private func accessibilityLabelForTile(row: Int, column: Int) -> String {
        let tile = gameState.boardTiles[row][column]
        var components: [String] = []
        
        // Card information
        if tile.isEmpty {
            components.append("Empty tile")
        } else if let card = tile.card {
            components.append("\(card.cardFace.accessibilityName) of \(card.suit.accessibilityName)")
        }
        
        // Chip information
        if let chip = tile.chip, chip.isPlaced {
            _ = chip.color.stringValue.replacingOccurrences(of: "team", with: "")
            components.append("\(chip.color.accessibilityName) team chip")
        } else {
            components.append("No chip")
        }
        
        // Sequence status
        if isTileInSequence(row: row, column: column) {
            components.append("Part of sequence")
        }
        
        // Valid move indicator
        let isValid = gameState.validPositionsForSelectedCard.contains { $0.row == row && $0.col == column }
        if isValid {
            components.append("Valid move")
        }
        
        // Position (optional)
        components.append("Row \(row + 1), Column \(column + 1)")
        
        return components.joined(separator: ", ")
    }
}
#Preview {
    let gameState = GameState()
    gameState.startGame(with: [
        Player(name: "Player 1", team: Team(color: .blue, numberOfPlayers: 2), cards: []),
        Player(name: "Player 2", team: Team(color: .red, numberOfPlayers: 2), cards: [])
    ])
    
    return BoardView(currentPlayer: .constant(nil))
        .environmentObject(gameState)
        .frame(width: 400, height: 640)
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

    return BoardView(currentPlayer: .constant(gameState.currentPlayer))
        .environmentObject(gameState)
        .frame(height: 520)
}
