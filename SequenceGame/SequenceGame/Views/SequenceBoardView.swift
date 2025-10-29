//
//  SequenceBoardView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//

import SwiftUI

struct SequenceBoardView: View {
    @EnvironmentObject var gameState: GameState
    @Environment(\.colorScheme) private var colorScheme
    var numberOfRows: Int = GameConstants.boardRows
    var numberOfColumns: Int = GameConstants.boardColumns
    var cardsPlaced = 0
    var emptyTiles = 0
    @State var tappedTile: (Int, Int)?
    @Binding var currentPlayer: Player?
    var body: some View {
        HStack {
            VStack {
                ForEach(0..<numberOfRows, id: \.self) { row in
                    HStack {
                        ForEach(0..<numberOfColumns, id: \.self) { column in
                            let tile = gameState.boardTiles[row][column]
                            // Valid position for currently selected card (read-only)
                            let isValid = gameState.validPositionsForSelectedCard.contains { $0.row == row && $0.col == column }
                            tileCell(row: row, column: column, tile: tile, isValid: isValid)
                        }
                    }
                }
            }
            .padding(15)
        }
        .edgesIgnoringSafeArea(.bottom)
        .edgesIgnoringSafeArea(.top)
        .border(Color.black, width: 10)
        .background(colorScheme == .dark ? Color("woodDark") : Color("wood"))
    }
    
    func isEmptyTile(_ row: Int, _ column: Int) -> Bool {
        let position = (row: row, col: column)
        return GameConstants.cornerPositions.contains { $0.row == position.row && $0.col == position.col }
    }
    
    func placeChip(color: Color) {
        
    }
    
    @ViewBuilder
    private func validHighlight(_ isValid: Bool) -> some View {
        if isValid {
            Circle()
                .fill(ThemeColor.accentGolden.opacity(0.7))
                .frame(width: 18, height: 18)
                .shadow(color: ThemeColor.accentGolden.opacity(0.5), radius: 4, y: 1)
        } else {
            EmptyView()
        }
    }
    @ViewBuilder
    private func tileCell(row: Int, column: Int, tile: BoardTile, isValid: Bool) -> some View {
        if tile.isEmpty {
            TileView(isCard: false, card: nil, color: .blue, isChipVisible: false)
        } else if let card = tile.card {
            if let chip = tile.chip, chip.isPlaced {
                // Tile with chip: allow tapping if one-eyed jack is selected and this tile is valid
                TileView(card: card, color: chip.color, isChipVisible: true)
                    .scaleEffect(chip.isPlaced ? 1.0 : 0.95)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: chip.isPlaced)
                    .contentShape(Rectangle())
                    .overlay {
                        validHighlight(isValid)
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
                    .contentShape(Rectangle())
                    .overlay {
                        validHighlight(isValid)
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
}
