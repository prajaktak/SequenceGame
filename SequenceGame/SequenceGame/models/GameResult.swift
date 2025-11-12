//
//  GameResult.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 12/11/2025.
//

import Foundation
import SwiftUI

enum GameResult {
    case ongoing                    // Game continues
    case win(team: Color)          // A team has won
}
