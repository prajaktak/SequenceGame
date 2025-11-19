//
//  Team.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 23/10/2025.
//

import Foundation
//import SwiftUI

struct Team: Identifiable {
    var id = UUID()
    var color: TeamColor
    var numberOfPlayers: Int
}
