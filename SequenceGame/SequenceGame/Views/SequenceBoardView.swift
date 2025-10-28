//
//  SequenceBoardView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//

import SwiftUI

struct SequenceBoardView: View {
    @State private var boardTiles: [[BoardTile]] = Board(row: 10, col: 10).boardTiles
    @State private var isBoardInitialized: Bool = false
    var numberOfRows: Int = 10
    var numberOfColumns: Int = 10
    var cardsPlaced = 0
    var emptyTiles = 0
    @State var tappedTile: (Int, Int)?
    @Binding var currentPlayer: Player?
    var body: some View {
        HStack {
            Text("********* Sequence *********")
                .frame(width: 10, height: 542, alignment: .center)
                .background(Color.black)
                .foregroundStyle(.white)
                .padding(.leading, 10)
                .padding(.trailing, 2)
            VStack {
                ForEach(0..<numberOfRows, id: \.self) { row in
                    HStack {
                        ForEach(0..<numberOfColumns, id: \.self) { column in
                            let tile = boardTiles[row][column]
                            if tile.isEmpty {
                                TileView(isCard: false, card: nil, color: .blue, isChipVisible: false)
                            } else if let card = tile.card {
                                if let chip = tile.chip, chip.isPlaced {
                                    TileView(card: card, color: chip.color, isChipVisible: true)
                                } else {
                                    TileView(card: card, color: .blue, isChipVisible: false)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if let currentPlayer = currentPlayer {
                                            let teamColor = currentPlayer.team.color
                                            let chip = Chip(color: teamColor, positionRow: row, positionColumn: column, isPlaced: true)
                                            boardTiles[row][column].chip = chip
                                            boardTiles[row][column].isChipOn = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
            Text("********* Sequence *********")
                .frame(width: 10, height: 542, alignment: .center)
                .background(Color.black)
                .foregroundStyle(.white)
                .padding(.trailing, 10)
                .padding(.leading, 2)
        }
        .edgesIgnoringSafeArea(.bottom)
        .edgesIgnoringSafeArea(.top)
        .border(Color.black, width: 10)
        .background(.wood)
        .onAppear {
            if !isBoardInitialized {
                setupBoard()
                isBoardInitialized = true
            }
        }
    }
    func setupBoard() {
        let tempDeck1 = Deck()
        let tempDeck2 = Deck()
        tempDeck1.shuffle()
        tempDeck2.shuffle()
        var newTiles: [[BoardTile]] = []

        for row in 0..<numberOfRows {
            var rowTiles: [BoardTile] = []
            for column in 0..<numberOfColumns {
                if isEmptyTile(row, column) {
                    rowTiles.append(BoardTile(card: nil, isEmpty: true, isChipOn: false))
                } else if !tempDeck1.cards.isEmpty {
                    rowTiles.append(BoardTile(card: tempDeck1.drawCard(), isEmpty: false, isChipOn: false, chip: nil))
                } else if !tempDeck2.cards.isEmpty {
                    rowTiles.append(BoardTile(card: tempDeck2.drawCard(), isEmpty: false, isChipOn: false, chip: nil))
                } else {
                    rowTiles.append(BoardTile(card: nil, isEmpty: true, isChipOn: false))
                }
            }
            newTiles.append(rowTiles)
        }
        boardTiles = newTiles
    }
    
    func isEmptyTile(_ row: Int, _ column: Int) -> Bool {
        if row == 0 && column == 0 {
            return true
        }
        if row == 0 && column == numberOfColumns-1 {
            return true
        }
        if row == numberOfRows-1 && column == 0 {
            return true
        }
        if row == numberOfRows-1 && column == numberOfColumns-1 {
            return true
        }
        return false
    }
    
    func placeChip(color: Color) {
        
    }
}

#Preview {
    SequenceBoardView(currentPlayer: .constant(nil))
}
