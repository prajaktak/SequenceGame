//
//  SoundEffect.swift
//  SequenceGame
//

import Foundation

enum SoundEffect: String {
    case cardSelect = "card_select"
    case chipPlace = "chip_place"
    case sequenceComplete = "sequence_complete"
    case turnChange = "turn_change"
    case gameWin = "game_win"
    
    var filename: String {
        return "\(rawValue).mp3"
    }
}
