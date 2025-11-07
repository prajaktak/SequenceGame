//
//  SequenceDetector.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 10/11/2025.
//

import Foundation
import SwiftUI

struct SequenceDetector {
    var board: Board
    var currentLocation: (row: Int, col: Int)
    var forPlayer: Player
    var numberofChipsInSequence: Int = 0
    
    func getChipColoer(atPosition: (row: Int, col: Int)) -> Color? {
        guard !board.boardTiles[atPosition.row][atPosition.col].isEmpty else {
            return .clear
        }
        
        if board.boardTiles[atPosition.row][atPosition.col].isChipOn {
            return board.boardTiles[atPosition.row][atPosition.col].chip?.color
        }
        return .clear
    }
    mutating func detectSequence(atPosition: (row: Int, col: Int), forPlayer: Player) -> Bool {
        var isSequenceCompleteHorizonatally: Bool = false
        var isSequenceCompleteVertically: Bool = false
        var isSequenceCompleteDiagonally: Bool = false
        var isSequenceCompleteantiAntidiagonally: Bool = false
        guard !board.boardTiles[atPosition.row][atPosition.col].isEmpty else {
            return false
        }
       
        // detecting sequence in one
        isSequenceCompleteHorizonatally = detectSequenceHorizonatally(atPosition: atPosition, forPlayer: forPlayer)
        
        // detecting sequence in one column
        isSequenceCompleteVertically = detectSequenceVertically(atPosition: atPosition, forPlayer: forPlayer)
        
        // detecting sequence digonally
        isSequenceCompleteDiagonally = detectSequenceDiagonally(atPosition: atPosition, forPlayer: forPlayer)
        
        // detecting sequence antidigonally
        isSequenceCompleteantiAntidiagonally = detectSequenceAntidiagonal(atPosition: atPosition, forPlayer: forPlayer)
        
        // true when any one sequence detected. false when no sequence detected.
        return isSequenceCompleteDiagonally || isSequenceCompleteHorizonatally || isSequenceCompleteVertically || isSequenceCompleteantiAntidiagonally
    }
    mutating func detectSequenceHorizonatally(atPosition: (row: Int, col: Int), forPlayer: Player) -> Bool {
        numberofChipsInSequence = 1
        var col = atPosition.col - 1
        while col >= 0  && getChipColoer(atPosition: atPosition) == getChipColoer(atPosition: (row: atPosition.row, col: col)) {
            numberofChipsInSequence += 1
            col -= 1
        }
        col = atPosition.col + 1
        while col < board.col && getChipColoer(atPosition: atPosition) == getChipColoer(atPosition: (row: atPosition.row, col: col)) {
            numberofChipsInSequence += 1
            col += 1
        }
        if numberofChipsInSequence >= 5 {
            return true
        }
        return false
    }
    mutating func detectSequenceVertically(atPosition: (row: Int, col: Int), forPlayer: Player) -> Bool {
        numberofChipsInSequence = 1
        var row = atPosition.row - 1
        while row >= 0  && getChipColoer(atPosition: atPosition) == getChipColoer(atPosition: (row: row, col: atPosition.col)) {
            numberofChipsInSequence += 1
            row -= 1
        }
        row = atPosition.row + 1
        while row < board.row && getChipColoer(atPosition: atPosition) == getChipColoer(atPosition: (row: row, col: atPosition.col)) {
            numberofChipsInSequence += 1
            row += 1
        }
        if numberofChipsInSequence >= 5 {
            return true
        }
        return false
    }
    mutating func detectSequenceDiagonally(atPosition: (row: Int, col: Int), forPlayer: Player) -> Bool {
        
        numberofChipsInSequence = 1
        var row = atPosition.row - 1
        var col = atPosition.col - 1
        while row >= 0  && col >= 0  && getChipColoer(atPosition: atPosition) == getChipColoer(atPosition: (row: row, col: col)) {
            numberofChipsInSequence += 1
            row -= 1
            col -= 1
        }
        row = atPosition.row + 1
        col = atPosition.col + 1
        while  row < board.row && col < board.col  && getChipColoer(atPosition: atPosition) == getChipColoer(atPosition: (row: row, col: col)) {
            numberofChipsInSequence += 1
            row += 1
            col += 1
        }
        
        if numberofChipsInSequence >= 5 {
            return true
        }
        
        return false
    }
    mutating func detectSequenceAntidiagonal(atPosition: (row: Int, col: Int), forPlayer: Player) -> Bool {
        numberofChipsInSequence = 1
        var row = atPosition.row - 1
        var col = atPosition.col + 1
        while row >= 0 && col < board.col &&
                getChipColoer(atPosition: atPosition) == getChipColoer(atPosition: (row: row, col: col)) {
            numberofChipsInSequence += 1
            row -= 1
            col += 1
        }
        row = atPosition.row + 1
        col = atPosition.col - 1
        while row < board.row && col >= 0 &&
                getChipColoer(atPosition: atPosition) == getChipColoer(atPosition: (row: row, col: col)) {
            numberofChipsInSequence += 1
            row += 1
            col -= 1
        }
        if numberofChipsInSequence >= 5 {
            return true
        }
        
        return false
    }
}
