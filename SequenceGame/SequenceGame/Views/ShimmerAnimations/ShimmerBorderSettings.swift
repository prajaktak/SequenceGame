//
//  ShimmerBorderSettings.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 16/11/2025.
//

import Foundation
import SwiftUI

public struct ShimmerBorderSettings {
    public var teamColor: Color
    public var frameWidth: CGFloat
    public var frameHeight: CGFloat
    public var dashArray: [CGFloat] = [10, 10]
    public var dashPhasePositive: CGFloat = 0
    public var dashPhaseNegative: CGFloat = 0
    public var animationDuration: Double = 0.1
    public var borderWidth: CGFloat = 1
    
}
