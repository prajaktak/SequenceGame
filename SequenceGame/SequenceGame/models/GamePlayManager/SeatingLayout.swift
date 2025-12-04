//
//  SeatingLayout.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 29/10/2025.
//
import Foundation

enum SeatingLayout {
    static func computeSeats(for numberOfPlayers: Int) -> [Seat] {
        guard numberOfPlayers > 0 else { return [] }
        let startDeg: Double = -90
        let step = 360.0 / Double(numberOfPlayers)
        return (0..<numberOfPlayers).map { idx in
            let degrees = startDeg + (step * Double(idx))
            let radians = CGFloat(degrees * .pi / 180.0)
            return Seat(index: idx + 1, angleRadian: radians, angleDegree: degrees)
        }
    }
}
