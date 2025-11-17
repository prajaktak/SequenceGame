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
    @State private var sequenceAnimationTrigger: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            // Single source of truth for sizing
            let borderThickness = GameConstants.UISizing.boardBorderThickness
            let contentInsets = EdgeInsets(
                top: GameConstants.UISizing.boardContentInsetTop,
                leading: GameConstants.UISizing.boardContentInsetLeading,
                bottom: GameConstants.UISizing.boardContentInsetBottom,
                trailing: GameConstants.UISizing.boardContentInsetTrailing
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
            .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.boardCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GameConstants.UISizing.boardCornerRadius, style: .continuous)
                    .stroke(ThemeColor.boardFelt, lineWidth: borderThickness)
            )
            .onChange(of: gameState.detectedSequence.count) { oldValue, newValue in
                if newValue > oldValue {
                    // New sequence detected - trigger animation
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        sequenceAnimationTrigger += 1
                    }
                }
            }
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
        
        let aspectRatio = GameConstants.UISizing.cardAspectRatio
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
    private func isTileInSequence(row: Int, column: Int) -> Bool {
        let tile = gameState.boardTiles[row][column]
        return gameState.detectedSequence.contains { sequence in
            sequence.tiles.contains { $0.id == tile.id }
        }
    }
    
    /// Returns the team color for a tile if it's part of a sequence
    private func teamColorForSequenceTile(row: Int, column: Int) -> Color? {
        let tile = gameState.boardTiles[row][column]
        for sequence in gameState.detectedSequence  where sequence.tiles.contains(where: { $0.id == tile.id }) {
                return sequence.teamColor
        }
        return nil
    }
    
    @ViewBuilder
    private func sequenceHighlight(_ isInSequence: Bool, teamColor: Color) -> some View {
        if isInSequence {
            ZStack {
                // Background to see the highlight better
                RoundedRectangle(cornerRadius: 4)
                    .fill(teamColor.opacity(0.4))
                    .border(teamColor, width: 4)
                    .shadow(color: teamColor.opacity(0.8), radius: 4)
            }
            .modifier(Shimmer(teamColor: teamColor))
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func tileCell(row: Int, column: Int, tileSize: (width: CGFloat, height: CGFloat)) -> some View {
        let isInSequence = isTileInSequence(row: row, column: column)
        let sequenceTeamColor = teamColorForSequenceTile(row: row, column: column) ?? .blue
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
            .overlay {
                if isValid {
                    Circle()
                        .fill(ThemeColor.accentGolden.opacity(0.85))
                        .frame(width: tileSize.width * 0.4, height: tileSize.width * 0.4)
                        .shadow(color: ThemeColor.accentGolden.opacity(0.7), radius: 6, y: 2)
                        .overlay(
                            Circle()
                                .stroke(ThemeColor.accentGolden, lineWidth: 2)
                                .frame(width: tileSize.width * 0.4, height: tileSize.width * 0.4)
                        )
                }
            }
            .opacity(isValid ? 1 : 0.8)
        } else if let card = tile.card {
            let teamColor = currentPlayer?.team.color ?? .blue
            TileView(
                card: card,
                color: tile.chip?.color ?? .blue,
                isChipVisible: tile.chip?.isPlaced ?? false
            )
            .frame(width: tileSize.width, height: tileSize.height)
            .contentShape(Rectangle())
            .border(teamColor.opacity(isValid ? 1 : 0), width: 3)
            .overlay {
                if isValid {
                    let shimmerBorderSettings = ShimmerBorderSettings(
                        teamColor: teamColor,
                        frameWidth: tileSize.width,
                        frameHeight: tileSize.height,
                        dashArray: [tileSize.width, 3*tileSize.height],
                        dashPhasePositive: CGFloat(3.0*(tileSize.height)+25),
                        dashPhaseNegative: CGFloat(-(3.0*(tileSize.height)+25)),
                        animationDuration: 0.1,
                        borderWidth: 3)
                    ShimmerBorder(shimmerBorderSetting: shimmerBorderSettings) {
                        Color.clear
                            .frame(width: tileSize.width, height: tileSize.height)
                    }
                }
            }
            .overlay {
                // Add sequence highlight overlay
                sequenceHighlight(isInSequence, teamColor: sequenceTeamColor)
                    .opacity(isInSequence ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isInSequence)
            }
            .onTapGesture {
                guard isValid else { return }
                guard let selectedId = gameState.selectedCardId else { return }
                defer { gameState.clearSelection() }
                withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                    gameState.performPlay(atPos: (row, column), using: selectedId)
                }
            }
        }
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
