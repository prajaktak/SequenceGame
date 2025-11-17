//
//  ShimmerSequence.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 13/11/2025.
//

import SwiftUI

public struct Shimmer: ViewModifier {
    var teamColor: Color
    @State var isInitialState: Bool = true
    
    public func body(content: Content) -> some View {
        content
            .mask {
                LinearGradient(
                    gradient: .init(colors: [teamColor.opacity(0.0),
                                             teamColor.opacity(0.15),
                                             teamColor.opacity(0.35),
                                             teamColor.opacity(0.15),
                                             teamColor.opacity(0.0)]),
                    startPoint: (isInitialState ? .init(x: -0.3, y: -0.3) : .init(x: 1, y: 1)),
                    endPoint: (isInitialState ? .init(x: 0, y: 0) : .init(x: 1.3, y: 1.3))
                )
            }
            .animation(.linear(duration: 1.5).delay(0.25).repeatForever(autoreverses: false), value: isInitialState)
            .onAppear {
                isInitialState = false
            }
    }
}

#Preview("Shimmering Sequence Highlight - Blue") {
    ZStack {
        // Background to see the highlight better
        RoundedRectangle(cornerRadius: 4)
            .fill(.blue.opacity(0.2))
            .border(.blue, width: 2)
            .frame(width: 50, height: 80)
    }
    .modifier(Shimmer(teamColor: .blue))
}

#Preview("Shimmering Sequence Highlight - Green") {
    ZStack {
        // Background to see the highlight better
        RoundedRectangle(cornerRadius: 4)
            .fill(.green.opacity(0.2))
            .border(.blue, width: 2)
            .frame(width: 50, height: 80)
    }
    .modifier(Shimmer(teamColor: .green))
}

#Preview("Shimmering Sequence Highlight - Red") {
    ZStack {
        // Background to see the highlight better
        RoundedRectangle(cornerRadius: 4)
            .fill(.blue.opacity(0.2))
            .border(.red, width: 2)
            .frame(width: 50, height: 80)
    }
    .modifier(Shimmer(teamColor: .red))
}
