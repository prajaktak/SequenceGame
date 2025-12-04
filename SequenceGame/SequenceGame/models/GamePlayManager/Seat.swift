//
//  Seat.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 29/10/2025.
//

import Foundation

struct Seat: Identifiable {
    var id = UUID()
    var index: Int
    let angleRadian: CGFloat
    let angleDegree: Double
}
