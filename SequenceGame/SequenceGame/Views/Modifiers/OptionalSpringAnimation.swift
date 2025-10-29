//
//  OptionalSpringAnimation.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 05/11/2025.
//

import SwiftUI

struct OptionalSpringAnimation<Value: Equatable>: ViewModifier {
    let enabled: Bool
    let value: Value

    func body(content: Content) -> some View {
        if enabled {
            content.animation(.spring(response: 0.25, dampingFraction: 0.8), value: value)
        } else {
            content
        }
    }
}
