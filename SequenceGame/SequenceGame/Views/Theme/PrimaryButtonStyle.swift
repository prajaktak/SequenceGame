//
//  PrimaryButtonStyle.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color("TextOnAccent"))
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                LinearGradient(colors: [
                    Color("AccentPrimary").opacity(0.95),
                    Color("AccentPrimary")
                ], startPoint: .top, endPoint: .bottom)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color("Border"), lineWidth: 1))
            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
