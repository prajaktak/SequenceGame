//
//  BoardTile.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 22/10/2025.
//
import Foundation

struct BoardTile: Codable, Identifiable {
    var id = UUID()
    var card: Card?
    var isEmpty: Bool
    var isChipOn: Bool
    var chip: Chip?
}
