//
//  ScatteredItem.swift
//  SequenceGame
//
//  Supporting type for MainMenu scattered header visuals
//

import SwiftUI

struct ScatterItem: Identifiable {
    let id = UUID()
    let kind: Kind
    let offset: CGSize
    let rotation: Angle
    let shadowOpacity: Double
}
