//
//  Board.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 22/10/2025.
//
import Foundation

struct Board: Codable {
    let row: Int
    let col: Int
    var boardTiles: [[BoardTile]]
    
    // MARK: - Initializers
    
    init(row: Int = GameConstants.boardRows, col: Int = GameConstants.boardColumns) {
        self.row = row
        self.col = col
        
        // Task 15: Keeping imperative style for clarity and debuggability.
        // Functional alternative considered: (0..<row).map { _ in (0..<col).map { _ in BoardTile(...) } }
        // Decision: Current code is more readable and maintainable.
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
    
    // MARK: - Codable
    
    /// Coding keys for encoding/decoding
    enum CodingKeys: String, CodingKey {
        case row
        case col
        case boardTiles
    }
    
    /// Encodes the board to the given encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(row, forKey: .row)
        try container.encode(col, forKey: .col)
        try container.encode(boardTiles, forKey: .boardTiles)
    }
    
    /// Decodes a board from the given decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        row = try container.decode(Int.self, forKey: .row)
        col = try container.decode(Int.self, forKey: .col)
        boardTiles = try container.decode([[BoardTile]].self, forKey: .boardTiles)
    }
}
