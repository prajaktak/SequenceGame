//
//  ShimmeringNameView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 30/10/2025.
//

import SwiftUI

struct ShimmeringNameView: View {
    let name: String
    let baseColor: Color                 // use ThemeColor.textOnAccent
    let highlightColor: Color            // use borderColor
    @State private var shimmerOffset: CGFloat = -60
    @State private var textWidth: CGFloat = 160

    var body: some View {
        ZStack {
            // Base (matches your current style)
            Text(name)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(baseColor)
                .background(
                    GeometryReader { proxy in
                        Color.clear.onAppear { textWidth = proxy.size.width }
                    }
                )

            // Moving highlight (same gradient + motion you used)
            Text(name)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.clear)
                .overlay(
                    LinearGradient(
                        colors: [.clear, highlightColor.opacity(0.60), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 100)
                    .offset(x: shimmerOffset)
                )
                .mask(
                    Text(name)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                )
        }
        .onAppear {
            withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: false)) {
                shimmerOffset = textWidth + 60
            }
        }
    }
}
#Preview("ShimmeringName") {
    ShimmeringNameView(
        name: "Prajakta",
        baseColor: ThemeColor.textOnAccent,
        highlightColor: ThemeColor.overlayTeamGreen
    )
    .padding(20)
    .background(ThemeColor.backgroundGame)
}
