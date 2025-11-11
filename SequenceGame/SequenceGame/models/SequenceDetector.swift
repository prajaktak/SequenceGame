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
    mutating func detectSequence(atPosition: (rowIndex: Int, colIndex: Int), forPlayer: Player, gameState: GameState) -> Bool {
        var isSequenceCompleteHorizontally: Bool = false
        var isSequenceCompleteVertically: Bool = false
        var isSequenceCompleteDiagonally: Bool = false
        var isSequenceCompleteAntidiagonally: Bool = false
        
        if board.boardTiles[atPosition.rowIndex][atPosition.colIndex].isEmpty && !board.boardTiles[atPosition.rowIndex][atPosition.colIndex].isCornerTile(atPosition: (rowIndex: atPosition.rowIndex, columnIndex: atPosition.colIndex)) {
            return false
        }
        // detecting sequence in one row
        isSequenceCompleteHorizontally = detectSequenceHorizontally(atPosition: atPosition, forPlayer: forPlayer, gameState: gameState)
        
        // detecting sequence in one column
        isSequenceCompleteVertically = detectSequenceVertically(atPosition: atPosition, forPlayer: forPlayer, gameState: gameState)
        
        // detecting sequence diagonally
        isSequenceCompleteDiagonally = detectSequenceDiagonally(atPosition: atPosition, forPlayer: forPlayer, gameState: gameState)
        
        // detecting sequence antidiagonally
        isSequenceCompleteAntidiagonally = detectSequenceAntidiagonal(atPosition: atPosition, forPlayer: forPlayer, gameState: gameState)
        
        // true when any one sequence detected. false when no sequence detected.
        return isSequenceCompleteDiagonally || isSequenceCompleteHorizontally || isSequenceCompleteVertically || isSequenceCompleteAntidiagonally
    }
    mutating func detectSequenceHorizontally(atPosition: (rowIndex: Int, colIndex: Int), forPlayer: Player, gameState: GameState) -> Bool {
        var sequenceHorizontalLeft: [BoardTile] = []
        var sequenceHorizontalRight: [BoardTile] = []
        let sequenceHorizontalCenter: BoardTile = board.boardTiles[atPosition.rowIndex][atPosition.colIndex]
        var sequenceStartColumnIndex: Int = atPosition.colIndex
        // Start counting with the center chip (position 1)
        numberOfChipsInSequence = 1
        
        // For horizontal detection, column index varies. Start checking left (previous column) first
        var aColumnIndex = atPosition.colIndex - 1
    
        // Check chips to the left (previous columns) until reaching border or finding different color chip
        while aColumnIndex >= 0 && (forPlayer.team.color == getChipColor(atPosition: (rowIndex: atPosition.rowIndex, colIndex: aColumnIndex)) || getChipColor(atPosition: (rowIndex: atPosition.rowIndex, colIndex: aColumnIndex)) == .clear) {
            numberOfChipsInSequence += 1
            sequenceHorizontalLeft.append(board.boardTiles[atPosition.rowIndex][aColumnIndex])
            sequenceStartColumnIndex = aColumnIndex
            aColumnIndex -= 1
        }
        
        // Check chips to the right (next columns) until reaching border or finding different color chip
        aColumnIndex = atPosition.colIndex + 1
        while aColumnIndex < board.col && (forPlayer.team.color == getChipColor(atPosition: (rowIndex: atPosition.rowIndex, colIndex: aColumnIndex)) || getChipColor(atPosition: (rowIndex: atPosition.rowIndex, colIndex: aColumnIndex)) == .clear) {
            numberOfChipsInSequence += 1
            sequenceHorizontalRight.append(board.boardTiles[atPosition.rowIndex][aColumnIndex])
            aColumnIndex += 1
        }

        // Verify sequence has at least 5 chips and matches the player's team color
        return validateAndCreateSequence(left: sequenceHorizontalLeft, center: sequenceHorizontalCenter, right: sequenceHorizontalRight, position: (rowIndex: atPosition.rowIndex, columnIndex: sequenceStartColumnIndex), sequenceType: .horizontal, gameState: gameState)
    }
    mutating func detectSequenceVertically(atPosition: (rowIndex: Int, colIndex: Int), forPlayer: Player, gameState: GameState) -> Bool {
        var sequenceVerticalUp: [BoardTile] = []
        var sequenceVerticalDown: [BoardTile] = []
        let sequenceVerticalCenter = board.boardTiles[atPosition.rowIndex][atPosition.colIndex]
        var sequenceStartRowIndex: Int = atPosition.rowIndex

        // Start counting with the center chip (position 1)
        numberOfChipsInSequence = 1
        // For vertical detection, row index varies. Start checking up (previous row) first
        var aRowIndex = atPosition.rowIndex - 1
        
        // Check chips above (previous rows) until reaching border or finding different color chip
        while aRowIndex >= 0  && (forPlayer.team.color == getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: atPosition.colIndex)) || getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: atPosition.colIndex)) == .clear) {
            numberOfChipsInSequence += 1
            sequenceVerticalUp.append(board.boardTiles[aRowIndex][atPosition.colIndex])
            sequenceStartRowIndex = aRowIndex
            aRowIndex -= 1
        }
        
        // Check chips below (next rows) until reaching border or finding different color chip
        aRowIndex = atPosition.rowIndex + 1
        while aRowIndex < board.row && (forPlayer.team.color == getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: atPosition.colIndex)) || getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: atPosition.colIndex)) == .clear) {
            numberOfChipsInSequence += 1
            sequenceVerticalDown.append(board.boardTiles[aRowIndex][atPosition.colIndex])
            aRowIndex += 1
        }
        
        // Verify sequence has at least 5 chips and matches the player's team color
        return validateAndCreateSequence(left: sequenceVerticalUp, center: sequenceVerticalCenter, right: sequenceVerticalDown, position: (rowIndex: sequenceStartRowIndex, columnIndex: atPosition.colIndex), sequenceType: .vertical, gameState: gameState)
    }
    mutating func detectSequenceDiagonally(atPosition: (rowIndex: Int, colIndex: Int), forPlayer: Player, gameState: GameState) -> Bool {
        var sequenceDiagonalLeftUp: [BoardTile] = []
        var sequenceDiagonalRightDown: [BoardTile] = []
        let sequenceDiagonalCenter = board.boardTiles[atPosition.rowIndex][atPosition.colIndex]
        var sequenceStartRowIndex: Int = atPosition.rowIndex
        var sequenceStartColumnIndex: Int = atPosition.colIndex

        // Start counting with the center chip (position 1)
        numberOfChipsInSequence = 1
        // For diagonal detection (top-left to bottom-right), both row and column indices vary
        // Start checking top-left (previous row and column) first
        var aRowIndex = atPosition.rowIndex - 1
        var aColumnIndex = atPosition.colIndex - 1
        
        // Check chips in top-left direction until reaching border or finding different color chip
        while aRowIndex >= 0 && aColumnIndex >= 0 && (forPlayer.team.color == getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex)) || getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex)) == .clear) {
            numberOfChipsInSequence += 1
            sequenceDiagonalLeftUp.append(board.boardTiles[aRowIndex][aColumnIndex])
            sequenceStartRowIndex = aRowIndex
            sequenceStartColumnIndex = aColumnIndex
            aRowIndex -= 1
            aColumnIndex -= 1
        }
        
        // Check chips in bottom-right direction until reaching border or finding different color chip
        aRowIndex = atPosition.rowIndex + 1
        aColumnIndex = atPosition.colIndex + 1
        while aRowIndex < board.row && aColumnIndex < board.col && (forPlayer.team.color == getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex)) || getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex)) == .clear) {
            numberOfChipsInSequence += 1
            sequenceDiagonalRightDown.append(board.boardTiles[aRowIndex][aColumnIndex])
            aRowIndex += 1
            aColumnIndex += 1
        }
        
        // Verify sequence has at least 5 chips and matches the player's team color
        return validateAndCreateSequence(left: sequenceDiagonalLeftUp, center: sequenceDiagonalCenter, right: sequenceDiagonalRightDown, position: (rowIndex: sequenceStartRowIndex, columnIndex: sequenceStartColumnIndex), sequenceType: .diagonal, gameState: gameState)
    }
    mutating func detectSequenceAntidiagonal(atPosition: (rowIndex: Int, colIndex: Int), forPlayer: Player, gameState: GameState) -> Bool {
        var sequenceAntiDiagonalLeftDown: [BoardTile] = []
        var sequenceAntiDiagonalRightUp: [BoardTile] = []
        let sequenceAntiDiagonalCenter = board.boardTiles[atPosition.rowIndex][atPosition.colIndex]
        var sequenceStartRowIndex: Int = atPosition.rowIndex
        var sequenceStartColumnIndex: Int = atPosition.colIndex
       
        // Start counting with the center chip (position 1)
        numberOfChipsInSequence = 1
        // For antidiagonal detection (top-right to bottom-left), both row and column indices vary
        // Start checking top-right (previous row, next column) first
        var aRowIndex = atPosition.rowIndex - 1
        var aColumnIndex = atPosition.colIndex + 1
        
        // Check chips in top-right direction until reaching border or finding different color chip
        while aRowIndex >= 0 && aColumnIndex < board.col &&
                (forPlayer.team.color == getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex)) || getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex)) == .clear) {
            numberOfChipsInSequence += 1
            sequenceAntiDiagonalRightUp.append(board.boardTiles[aRowIndex][aColumnIndex])
            sequenceStartRowIndex = aRowIndex
            sequenceStartColumnIndex = aColumnIndex
            aRowIndex -= 1
            aColumnIndex += 1
        }
        
        // Check chips in bottom-left direction until reaching border or finding different color chip
        aRowIndex = atPosition.rowIndex + 1
        aColumnIndex = atPosition.colIndex - 1
        while aRowIndex < board.row && aColumnIndex >= 0 &&
                (forPlayer.team.color == getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex)) || getChipColor(atPosition: (rowIndex: aRowIndex, colIndex: aColumnIndex)) == .clear) {
            numberOfChipsInSequence += 1
            sequenceAntiDiagonalLeftDown.append(board.boardTiles[aRowIndex][aColumnIndex])
            aRowIndex += 1
            aColumnIndex -= 1
        }
        
        // Verify sequence has at least 5 chips and matches the player's team color
        return validateAndCreateSequence(left: sequenceAntiDiagonalRightUp, center: sequenceAntiDiagonalCenter, right: sequenceAntiDiagonalLeftDown, position: (rowIndex: sequenceStartRowIndex, columnIndex: sequenceStartColumnIndex), sequenceType: .antiDiagonal, gameState: gameState)
    }
    // MARK: - Sequence validation and creation
    mutating func validateAndCreateSequence(
        left: [BoardTile],
        center: BoardTile,
        right: [BoardTile],
        position: (rowIndex: Int, columnIndex: Int),
        sequenceType: SequenceType,
        gameState: GameState) -> Bool {
        guard numberOfChipsInSequence >= 5 else { return false }
        
        let sequenceTiles = createSequence(left: left, center: center, right: right)
        guard !sequenceTiles.isEmpty else { return false }
        
        let sequence = Sequence(
            tiles: sequenceTiles,
            position: (row: position.rowIndex, col: position.columnIndex),
            teamColor: forPlayer.team.color,
            sequenceType: sequenceType
        )
        gameState.detectedSequence.append(sequence)
        return true
    }
    
    // MARK: - Creating a sequence
    func createSequence(left: [BoardTile], center: BoardTile, right: [BoardTile]) -> [BoardTile] {
        if left.isEmpty && right.isEmpty {
            return [center]
        } else if left.isEmpty {
            return  [center] + right
        } else if right.isEmpty {
            return left.reversed() + [center]
        } else {
            return left.reversed() + [center] + right
        }
    }
}
