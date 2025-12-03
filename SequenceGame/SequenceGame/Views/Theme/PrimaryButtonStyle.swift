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
            .clipShape(RoundedRectangle(cornerRadius: GameConstants.buttonCornerRadius,
                                        style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: GameConstants.buttonCornerRadius).stroke(Color("Border"), lineWidth: GameConstants.universalBorderWidth))
            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview("PrimaryButtonStyle - Default") {
    VStack(spacing: 20) {
        Button("Start Game") { }
            .buttonStyle(PrimaryButtonStyle())
        
        Button("Continue") { }
            .buttonStyle(PrimaryButtonStyle())
        
        Button("Settings") { }
            .buttonStyle(PrimaryButtonStyle())
    }
    .padding()
}

#Preview("PrimaryButtonStyle - With Icons") {
    VStack(spacing: 20) {
        Button {
            // Action
        } label: {
            Label("New Game", systemImage: "plus.circle.fill")
        }
        .buttonStyle(PrimaryButtonStyle())
        
        Button {
            // Action
        } label: {
            Label("Resume", systemImage: "play.fill")
        }
        .buttonStyle(PrimaryButtonStyle())
    }
    .padding()
}
