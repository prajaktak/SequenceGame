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
    var numberOfChipsInSequence: Int = 0
    
    func getChipColor(atPosition: (rowIndex: Int, colIndex: Int)) -> Color? {
        if GameConstants.cornerPositions.contains(where: { $0.row == atPosition.rowIndex && $0.col == atPosition.colIndex }) {
            return .clear
        }
        
        if board.boardTiles[atPosition.rowIndex][atPosition.colIndex].isEmpty && !board.boardTiles[atPosition.rowIndex][atPosition.colIndex].isCornerTile(atPosition: (rowIndex: atPosition.rowIndex, columnIndex: atPosition.colIndex)) {
            return nil
        }
        
        if board.boardTiles[atPosition.rowIndex][atPosition.colIndex].isChipOn {
            return board.boardTiles[atPosition.rowIndex][atPosition.colIndex].chip?.color
        }
        
        return nil
    }
    mutating func detectSequence(atPosition: (rowIndex: Int, colIndex: Int), forPlayer: Player) -> Bool {
        var isSequenceCompleteHorizontally: Bool = false
        var isSequenceCompleteVertically: Bool = false
        var isSequenceCompleteDiagonally: Bool = false
        var isSequenceCompleteAntidiagonally: Bool = false
        
        if board.boardTiles[atPosition.rowIndex][atPosition.colIndex].isEmpty && !board.boardTiles[atPosition.rowIndex][atPosition.colIndex].isCornerTile(atPosition: (rowIndex: atPosition.rowIndex, columnIndex: atPosition.colIndex)) {
            return false
        }
        // detecting sequence in one row
        isSequenceCompleteHorizontally = detectSequenceHorizontally(atPosition: atPosition, forPlayer: forPlayer)
        
        // detecting sequence in one column
        isSequenceCompleteVertically = detectSequenceVertically(atPosition: atPosition, forPlayer: forPlayer)
        
        // detecting sequence diagonally
        isSequenceCompleteDiagonally = detectSequenceDiagonally(atPosition: atPosition, forPlayer: forPlayer)
        
        // detecting sequence antidiagonally
        isSequenceCompleteAntidiagonally = detectSequenceAntidiagonal(atPosition: atPosition, forPlayer: forPlayer)
        
        // true when any one sequence detected. false when no sequence detected.
        return isSequenceCompleteDiagonally || isSequenceCompleteHorizontally || isSequenceCompleteVertically || isSequenceCompleteAntidiagonally
    }
    mutating func detectSequenceHorizontally(atPosition: (rowIndex: Int, colIndex: Int), forPlayer: Player) -> Bool {
        // Start counting with the center chip (position 1)
        numberOfChipsInSequence = 1
        
        // Get the color of the starting chip to match against
        var colorToCompare = getChipColor(atPosition: atPosition)
        
        // For horizontal detection, column index varies. Start checking left (previous column) first
        var aColumnIndex = atPosition.colIndex - 1
        
        // If starting position is a corner (wild space), find the first non-corner chip
        // to determine the sequence color we're looking for
        if colorToCompare == .clear && aColumnIndex >= 0 {
            colorToCompare = getChipColor(atPosition: (rowIndex: atPosition.rowIndex, colIndex: aColumnIndex))
        } else if colorToCompare == .clear {
            colorToCompare = getChipColor(atPosition: (rowIndex: atPosition.rowIndex, colIndex: atPosition.colIndex + 1))
        }
        
        // Check chips to the left (previous columns) until reaching border or finding different color chip
        while aColumnIndex >= 0 && colorToCompare != nil && (colorToCompare == getChipColor(atPosition: (rowIndex: atPosition.rowIndex, colIndex: aColumnIndex)) || getChipColor(atPosition: (rowIndex: atPosition.rowIndex, colIndex: aColumnIndex)) == .clear) {
            numberOfChipsInSequence += 1
            aColumnIndex -= 1
        }
        
        // Check chips to the right (next columns) until reaching border or finding different color chip
        aColumnIndex = atPosition.colIndex + 1
        while aColumnIndex < board.col && colorToCompare != nil && (colorToCompare == getChipColor(atPosition: (rowIndex: atPosition.rowIndex, colIndex: aColumnIndex)) || getChipColor(atPosition: (rowIndex: atPosition.rowIndex, colIndex: aColumnIndex)) == .clear) {
            numberOfChipsInSequence += 1
            aColumnIndex += 1
        }
        
        // Verify sequence has at least 5 chips and matches the player's team color
        if numberOfChipsInSequence >= 5 && colorToCompare == forPlayer.team.color {
            return true
        }
        
        return false
    }
    mutating func detectSequenceVertically(atPosition: (rowIndex: Int, colIndex: Int), forPlayer: Player) -> Bool {
        // Get the color of the starting chip to match against
        var colorToCompare = getChipColor(atPosition: atPosition)
        // Start counting with the center chip (position 1)
        numberOfChipsInSequence = 1
        // For vertical detection, row index varies. Start checking up (previous row) first
        var aRowIndex = atPosition.rowIndex - 1
        
        // If starting position is a corner (wild space), find the first non-corner chip
        // to determine the sequence color we're looking for
        if colorToCompare == .clear && aRowIndex >= 0 {
            colorToCompare = getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: atPosition.colIndex))
        } else if colorToCompare == .clear {
            colorToCompare = getChipColor(atPosition: (rowIndex: atPosition.rowIndex + 1, colIndex: atPosition.colIndex))
        }
        
        // Check chips above (previous rows) until reaching border or finding different color chip
        while aRowIndex >= 0 && colorToCompare != nil && (colorToCompare == getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: atPosition.colIndex)) || getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: atPosition.colIndex)) == .clear) {
            numberOfChipsInSequence += 1
            aRowIndex -= 1
        }
        
        // Check chips below (next rows) until reaching border or finding different color chip
        aRowIndex = atPosition.rowIndex + 1
        while aRowIndex < board.row && colorToCompare != nil && (colorToCompare == getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: atPosition.colIndex)) || getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: atPosition.colIndex)) == .clear) {
            numberOfChipsInSequence += 1
            aRowIndex += 1
        }
        
        // Verify sequence has at least 5 chips and matches the player's team color
        if numberOfChipsInSequence >= 5 && colorToCompare == forPlayer.team.color {
            return true
        }
        return false
    }
    mutating func detectSequenceDiagonally(atPosition: (rowIndex: Int, colIndex: Int), forPlayer: Player) -> Bool {
        // Get the color of the starting chip to match against
        var colorToCompare = getChipColor(atPosition: atPosition)
        // Start counting with the center chip (position 1)
        numberOfChipsInSequence = 1
        // For diagonal detection (top-left to bottom-right), both row and column indices vary
        // Start checking top-left (previous row and column) first
        var aRowIndex = atPosition.rowIndex - 1
        var aColumnIndex = atPosition.colIndex - 1
        
        // If starting position is a corner (wild space), find the first non-corner chip
        // to determine the sequence color we're looking for
        if colorToCompare == .clear && aRowIndex >= 0 && aColumnIndex >= 0 {
            colorToCompare = getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex))
        } else if colorToCompare == .clear {
            if atPosition.rowIndex + 1 < board.row && atPosition.colIndex + 1 < board.col {
                colorToCompare = getChipColor(atPosition: (rowIndex: atPosition.rowIndex + 1, colIndex: atPosition.colIndex + 1))
            } else {
                colorToCompare = nil
            }
        }
        
        // Check chips in top-left direction until reaching border or finding different color chip
        while aRowIndex >= 0 && aColumnIndex >= 0 && colorToCompare != nil && (colorToCompare == getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex)) || getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex)) == .clear) {
            numberOfChipsInSequence += 1
            aRowIndex -= 1
            aColumnIndex -= 1
        }
        
        // Check chips in bottom-right direction until reaching border or finding different color chip
        aRowIndex = atPosition.rowIndex + 1
        aColumnIndex = atPosition.colIndex + 1
        while aRowIndex < board.row && aColumnIndex < board.col && colorToCompare != nil && (colorToCompare == getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex)) || getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex)) == .clear) {
            numberOfChipsInSequence += 1
            aRowIndex += 1
            aColumnIndex += 1
        }
        
        // Verify sequence has at least 5 chips and matches the player's team color
        if numberOfChipsInSequence >= 5 && colorToCompare == forPlayer.team.color {
            return true
        }
        return false
    }
    mutating func detectSequenceAntidiagonal(atPosition: (rowIndex: Int, colIndex: Int), forPlayer: Player) -> Bool {
        // Get the color of the starting chip to match against
        var colorToCompare = getChipColor(atPosition: atPosition)
        // Start counting with the center chip (position 1)
        numberOfChipsInSequence = 1
        // For antidiagonal detection (top-right to bottom-left), both row and column indices vary
        // Start checking top-right (previous row, next column) first
        var aRowIndex = atPosition.rowIndex - 1
        var aColumnIndex = atPosition.colIndex + 1
        
        // If starting position is a corner (wild space), find the first non-corner chip
        // to determine the sequence color we're looking for
        if colorToCompare == .clear && aRowIndex >= 0 && aColumnIndex < board.col {
            colorToCompare = getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex))
        } else if colorToCompare == .clear {
            if atPosition.rowIndex + 1 < board.row && atPosition.colIndex - 1 >= 0 {
                colorToCompare = getChipColor(atPosition: (rowIndex: atPosition.rowIndex + 1, colIndex: atPosition.colIndex - 1))
            } else {
                colorToCompare = nil
            }
        }
        
        // Check chips in top-right direction until reaching border or finding different color chip
        while aRowIndex >= 0 && aColumnIndex < board.col && colorToCompare != nil &&
                (colorToCompare == getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex)) || getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex)) == .clear) {
            numberOfChipsInSequence += 1
            aRowIndex -= 1
            aColumnIndex += 1
        }
        
        // Check chips in bottom-left direction until reaching border or finding different color chip
        aRowIndex = atPosition.rowIndex + 1
        aColumnIndex = atPosition.colIndex - 1
        while aRowIndex < board.row && aColumnIndex >= 0 && colorToCompare != nil &&
                (colorToCompare == getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex)) || getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex)) == .clear) {
            numberOfChipsInSequence += 1
            aRowIndex += 1
            aColumnIndex -= 1
        }
        
        // Verify sequence has at least 5 chips and matches the player's team color
        if numberOfChipsInSequence >= 5 && colorToCompare == forPlayer.team.color {
            return true
        }
        return false
    }
}
