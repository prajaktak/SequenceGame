//
//  Chip.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 22/10/2025.
//

import Foundation

struct Chip: Codable {
    var color: TeamColor
    var positionRow: Int = 0
    var positionColumn: Int = 0
    var isPlaced: Bool = false
    
    mutating func place(at row: Int, column: Int) {
        self.isPlaced = true
        self.positionRow = row
        self.positionColumn = column
    }
    
    init(color: TeamColor) {
        self.color = color
    }
    init(color: TeamColor, positionRow: Int, positionColumn: Int, isPlaced: Bool) {
        self.color = color
        self.positionRow = positionRow
        self.positionColumn = positionColumn
        self.isPlaced = isPlaced
    }
}
