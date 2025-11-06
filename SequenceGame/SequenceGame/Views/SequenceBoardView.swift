//
//  SequenceBoardView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//

import SwiftUI

struct SequenceBoardView: View {
    @EnvironmentObject var gameState: GameState
    @EnvironmentObject var gameState: GameState
    @Environment(\.colorScheme) private var colorScheme
    var numberOfRows: Int = GameConstants.boardRows
    var numberOfColumns: Int = GameConstants.boardColumns
    var cardsPlaced = 0
    var emptyTiles = 0
    @State var tappedTile: (Int, Int)?
    @Binding var currentPlayer: Player?
    var body: some View {
        GeometryReader { geometry in
            // Calculate available width (accounting for padding and border)
            let horizontalPadding: CGFloat = 4 * 2  // 4 points on each side (reduced from 8)
            let borderWidth: CGFloat = 2 * 2  // 2 points border on each side (reduced from 4)
            let outerPadding: CGFloat = 6 * 2  // 6 points outer padding from SequenceGameView (reduced from 12)
            let availableWidth = geometry.size.width - horizontalPadding - borderWidth - outerPadding
            let availableHeight = geometry.size.height
            
            // Account for spacing between tiles
            // Default SwiftUI HStack/VStack spacing is ~8 points, but we'll use 0 for tight packing
            let tileSpacing: CGFloat = 0
            let horizontalSpacing = tileSpacing * CGFloat(numberOfColumns - 1)  // 9 gaps for 10 columns
            let verticalSpacing = tileSpacing * CGFloat(numberOfRows - 1)  // 9 gaps for 10 rows
            
            // Calculate tile size to fit 10 columns - account for spacing between tiles
            let calculatedTileWidth = max(28, min((availableWidth - horizontalSpacing) / CGFloat(numberOfColumns), 38))
            let calculatedTileHeight = calculatedTileWidth * 1.6  // Maintain card aspect ratio
            
            // Verify height fits - if not, adjust tile size proportionally
            let totalHeightNeeded = (calculatedTileHeight * CGFloat(numberOfRows)) + verticalSpacing
            let availableHeightForTiles = availableHeight - (horizontalPadding + borderWidth)
            let adjustedTileHeight = totalHeightNeeded > availableHeightForTiles 
                ? (availableHeightForTiles - verticalSpacing) / CGFloat(numberOfRows)
                : calculatedTileHeight
            let finalTileWidth = adjustedTileHeight / 1.6  // Maintain aspect ratio
            let finalCalculatedTileWidth = max(28, min(finalTileWidth, 38))
            let finalCalculatedTileHeight = finalCalculatedTileWidth * 1.6
            HStack(spacing: tileSpacing) {
                Spacer()
                VStack(spacing: tileSpacing) {
                    ForEach(0..<numberOfRows, id: \.self) { row in
                        HStack(spacing: tileSpacing) {
                            ForEach(0..<numberOfColumns, id: \.self) { column in
                                let tile = gameState.boardTiles[row][column]
                                let isValid = gameState.validPositionsForSelectedCard.contains { $0.row == row && $0.col == column }
                                tileCell(
                                    row: row,
                                    column: column,
                                    tile: tile,
                                    isValid: isValid,
                                    tileWidth: finalCalculatedTileWidth,
                                    tileHeight: finalCalculatedTileHeight
                                )
                            }
                        }
                    }
                }
                .padding(4)  // Reduced from 8
                Spacer()
            }
//            .edgesIgnoringSafeArea(.bottom)
//            .edgesIgnoringSafeArea(.top)
            .border(Color.black, width: 2)  // Reduced from 4
            .background(colorScheme == .dark ? Color("woodDark") : Color("wood"))
        }
    }
    
    func isEmptyTile(_ row: Int, _ column: Int) -> Bool {
        let position = (row: row, col: column)
        return GameConstants.cornerPositions.contains { $0.row == position.row && $0.col == position.col }
    }
    
    func placeChip(color: Color) {
        
    }
    
    @ViewBuilder
    private func validHighlight(_ isValid: Bool, tileSize: CGFloat) -> some View {
        if isValid {
            Circle()
                .fill(ThemeColor.accentGolden.opacity(0.7))
                .frame(width: tileSize * 0.4, height: tileSize * 0.4)  // Scale with tile
                .shadow(color: ThemeColor.accentGolden.opacity(0.5), radius: 4, y: 1)
        } else {
            EmptyView()
        }
    }
    @ViewBuilder
    private func tileCell(
        row: Int,
        column: Int,
        tile: BoardTile,
        isValid: Bool,
        tileWidth: CGFloat,
        tileHeight: CGFloat
    ) -> some View {
        if tile.isEmpty {
            TileView(isCard: false, card: nil, color: .blue, isChipVisible: false)
                .frame(width: tileWidth, height: tileHeight)
        } else if let card = tile.card {
            if let chip = tile.chip, chip.isPlaced {
                // Tile with chip: allow tapping if one-eyed jack is selected and this tile is valid
                TileView(card: card, color: chip.color, isChipVisible: true)
                    .frame(width: tileWidth, height: tileHeight)
                    .scaleEffect(chip.isPlaced ? 1.0 : 0.95)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: chip.isPlaced)
                    .contentShape(Rectangle())
                    .overlay {
                        validHighlight(isValid, tileSize: tileWidth)
                            .opacity(isValid ? 1 : 0)
                            .scaleEffect(isValid ? 1 : 0.92)
                            .animation(.easeOut(duration: 0.2), value: isValid)
                    }
                    .onTapGesture {
                        guard isValid else { return }
                        guard let selectedId = gameState.selectedCardId else { return }
                        defer { gameState.clearSelection() }
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            gameState.performPlay(atPos: (row, column), using: selectedId)
                        }
                    }
            } else {
                // Empty tile: allow tapping if card selected and this tile is valid
                TileView(card: card, color: .blue, isChipVisible: false)
                    .frame(width: tileWidth, height: tileHeight)
                    .contentShape(Rectangle())
                    .overlay {
                        validHighlight(isValid, tileSize: tileWidth)
                            .opacity(isValid ? 1 : 0)
                            .scaleEffect(isValid ? 1 : 0.92)
                            .animation(.easeOut(duration: 0.2), value: isValid)
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
}

#Preview {
    SequenceBoardView(currentPlayer: .constant(nil))
        .environmentObject(GameState())
        .environmentObject(GameState())
}
