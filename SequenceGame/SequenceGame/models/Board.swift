//
//  Board.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 22/10/2025.
//
import Foundation

class Board {
    var row: Int
    var col: Int
    var boardTiles: [[BoardTile]] = []
    
    init(row: Int, col: Int) {
        self.row = row
        self.col = col
        for _ in 0..<row {
            var rowTiles: [BoardTile] = []
            for _ in 0..<col {
                rowTiles.append(BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil))
            }
            boardTiles.append(rowTiles)
        }
    }
}
