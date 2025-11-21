//
//  SecondaryButtonStyle.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color("TextPrimary"))
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color("AccentPrimary").opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.buttonCornerRadius,
                                        style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: GameConstants.UISizing.buttonCornerRadius).stroke(Color("AccentPrimary"), lineWidth: GameConstants.UISizing.universalBorderWidth))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview("SecondaryButtonStyle - Default") {
    VStack(spacing: 20) {
        Button("Cancel") { }
            .buttonStyle(SecondaryButtonStyle())
        
        Button("Options") { }
            .buttonStyle(SecondaryButtonStyle())
        
        Button("Learn More") { }
            .buttonStyle(SecondaryButtonStyle())
    }
    .padding()
}

#Preview("SecondaryButtonStyle - With Icons") {
    VStack(spacing: 20) {
        Button {
            // Action
        } label: {
            Label("Back", systemImage: "chevron.left")
        }
        .buttonStyle(SecondaryButtonStyle())
        
        Button {
            // Action
        } label: {
            Label("Help", systemImage: "questionmark.circle")
        }
        .buttonStyle(SecondaryButtonStyle())
    }
    .padding()
}

#Preview("SecondaryButtonStyle - Compare with Primary") {
    VStack(spacing: 20) {
        Button("Primary Action") { }
            .buttonStyle(PrimaryButtonStyle())
        
        Button("Secondary Action") { }
            .buttonStyle(SecondaryButtonStyle())
    }
    .padding()
}
