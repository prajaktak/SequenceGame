//
//  ScatterItemKind.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 03/12/2025.
//

import SwiftUI

enum Kind {
    case chip(Color, CGFloat)         // color, size
    case card(Color, String, CGFloat) // border color, SF Symbol suit, height
}
