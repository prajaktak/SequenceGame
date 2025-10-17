//
//  Chip.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 22/10/2025.
//

import Foundation
import SwiftUI

struct Chip {
    var color: Color
    var positionRow: Int = 0
    var positionColumn: Int = 0
    var isPlaced: Bool = false
    
    mutating func place(at row: Int, column: Int) {
        self.isPlaced = true
        self.positionRow = row
        self.positionColumn = column
    }
    
    init(color: Color) {
        self.color = color
    }
}
