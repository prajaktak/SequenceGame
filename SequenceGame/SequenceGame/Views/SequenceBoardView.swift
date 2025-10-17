//
//  SequenceBoardView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//

import SwiftUI

struct SequenceBoardView: View {
    @State private var boardTiles: [[BoardTile]] = Board(row: 10, col: 10).boardTiles
    var numberOfRows: Int = 10
    var numberOfColumns: Int = 10
    var cardsPlaced = 0
    var emptyTiles = 0
    var body: some View {
        HStack {
            Text("********* Sequence *********")
                .frame(width: 10, height: 542, alignment: .center)
                .background(Color.secondary)
                .padding(.leading, 10)
                .padding(.trailing, 2)
            VStack {
                ForEach(0..<numberOfRows, id: \.self) { row in
                    HStack {
                        ForEach(0..<numberOfColumns, id: \.self) { column in
                            let tile = boardTiles[row][column]
                            if tile.isEmpty {
                                TileView(isCard: false, card: nil)
                            } else if let card = tile.card {
                                TileView(card: card)
                            }
                        }
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 20)
            Text("********* Sequence *********")
                .frame(width: 10, height: 542, alignment: .center)
                .background(Color.secondary)
                .padding(.trailing, 10)
                .padding(.leading, 2)
        }
        .edgesIgnoringSafeArea(.bottom)
        .edgesIgnoringSafeArea(.top)
        .border(Color.secondary, width: 10)
        .onAppear {
            setupBoard()
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
                    rowTiles.append(BoardTile(card: nil, isEmpty: true))
                } else if !tempDeck1.cards.isEmpty {
                    rowTiles.append(BoardTile(card: tempDeck1.drawCard(), isEmpty: false))
                } else if !tempDeck2.cards.isEmpty {
                    rowTiles.append(BoardTile(card: tempDeck2.drawCard(), isEmpty: false))
                } else {
                    rowTiles.append(BoardTile(card: nil, isEmpty: true))
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
}

#Preview {
    SequenceBoardView()
}
