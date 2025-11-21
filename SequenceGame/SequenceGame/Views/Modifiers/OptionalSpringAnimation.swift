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

#Preview("OptionalSpringAnimation - Enabled") {
    struct PreviewView: View {
        @State private var isExpanded = false
        
        var body: some View {
            VStack(spacing: 30) {
                Text("Animation Enabled")
                    .font(.headline)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue)
                    .frame(width: isExpanded ? 200 : 100, height: 100)
                    .modifier(OptionalSpringAnimation(enabled: true, value: isExpanded))
                
                Button("Toggle") {
                    isExpanded.toggle()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
    
    return PreviewView()
}

#Preview("OptionalSpringAnimation - Disabled") {
    struct PreviewView: View {
        @State private var isExpanded = false
        
        var body: some View {
            VStack(spacing: 30) {
                Text("Animation Disabled")
                    .font(.headline)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(.red)
                    .frame(width: isExpanded ? 200 : 100, height: 100)
                    .modifier(OptionalSpringAnimation(enabled: false, value: isExpanded))
                
                Button("Toggle") {
                    isExpanded.toggle()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
    
    return PreviewView()
}
