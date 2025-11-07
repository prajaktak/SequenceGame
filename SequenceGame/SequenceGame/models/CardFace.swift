//
//  CardFace.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//

import Foundation

enum CardFace: Equatable, CaseIterable {
    case ace, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king, empty
    
    var displayValue: String {
        switch self {
        case .ace: return "A"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .six: return "6"
        case .seven: return "7"
        case .eight: return "8"
        case .nine: return "9"
        case .ten: return "10"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        case .empty: return "E"
        }
    }
    var imageCount: Int {
            switch self {
            case .ace: return 1
            case .two: return 2
            case .three: return 3
            case .four: return 4
            case .five: return 5
            case .six: return 6
            case .seven: return 7
            case .eight: return 8
            case .nine: return 9
            case .ten: return 10
            case .jack, .queen, .king: return 0 // Depends on your design
            case .empty: return 0
            }
        }
}
