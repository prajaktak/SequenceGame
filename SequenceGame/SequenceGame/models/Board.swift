//
//  Board.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 22/10/2025.
//
import Foundation

struct Board {
    let row: Int
    let col: Int
    var boardTiles: [[BoardTile]]
    
    init(row: Int = GameConstants.boardRows, col: Int = GameConstants.boardColumns) {
        self.row = row
        self.col = col
        var initialTiles: [[BoardTile]] = []
        for _ in 0..<row {
            var rowTiles: [BoardTile] = []
            for _ in 0..<col {
                rowTiles.append(BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil))
            }
            initialTiles.append(rowTiles)
        }
        self.boardTiles = initialTiles
    }
}
