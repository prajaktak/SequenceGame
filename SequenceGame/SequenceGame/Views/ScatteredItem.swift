//
//  ScatteredItem.swift
//  SequenceGame
//
//  Supporting type for MainMenu scattered header visuals
//

import SwiftUI

struct ScatterItem: Identifiable {
    enum Kind {
        case chip(Color, CGFloat)         // color, size
        case card(Color, String, CGFloat) // border color, SF Symbol suit, height
    }
    let id = UUID()
    let kind: Kind
    let offset: CGSize
    let rotation: Angle
    let shadowOpacity: Double
}

