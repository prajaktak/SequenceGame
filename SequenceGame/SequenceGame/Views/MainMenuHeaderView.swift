//
//  MainMenuHeaderView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 29/10/2025.
//

import SwiftUI

struct MainMenuHeaderView: View {
    @State private var scatterItems: [ScatterItem] = []

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                ForEach(scatterItems) { item in
                    switch item.kind {
                    case .chip(let color, let size):
                        Circle()
                            .fill(color)
                            .frame(width: size, height: size)
                            .shadow(color: .black.opacity(item.shadowOpacity), radius: 4, x: 2, y: 2)
                            .offset(item.offset)
                            .rotationEffect(item.rotation)
                    case .card(let borderColor, let suitSymbol, let size):
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white)
                            .frame(width: size * 0.75, height: size)
                            .overlay(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8).stroke(borderColor, lineWidth: 2)
                                    Image(systemName: suitSymbol)
                                        .font(.system(size: size * 0.4))
                                        .foregroundStyle(borderColor)
                                }
                            )
                            .shadow(color: .black.opacity(item.shadowOpacity * 0.8), radius: 6, x: 1, y: 3)
                            .offset(item.offset)
                            .rotationEffect(item.rotation)
                    }
                }
            }
            .frame(height: 90)
            .onAppear { generateScatter() }

            Text("Sequence")
                .font(.system(size: 58, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [ThemeColor.accentPrimary, ThemeColor.accentSecondary],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            Text("Classic Board Game")
                .font(.title3.weight(.heavy))
                .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
        }
        .padding(.top, 60)
    }

    private func generateScatter() {
        guard scatterItems.isEmpty else { return }
        let chipColors: [Color] = [ThemeColor.teamBlue, ThemeColor.teamGreen, ThemeColor.accentSecondary, ThemeColor.accentTertiary]
        var generated: [ScatterItem] = (0..<5).map { _ in
            let color = chipColors.randomElement() ?? ThemeColor.teamBlue
            let size = CGFloat(Int.random(in: 26...38))
            let offsetX = CGFloat(Int.random(in: -70...70))
            let offsetY = CGFloat(Int.random(in: -18...30))
            let rotationDegrees = Double(Int.random(in: -40...40))
            return ScatterItem(
                kind: .chip(color, size),
                offset: CGSize(width: offsetX, height: offsetY),
                rotation: .degrees(rotationDegrees),
                shadowOpacity: 0.28
            )
        }
        let card1 = ScatterItem(kind: .card(ThemeColor.accentPrimary, "spade.fill", 62),
                                offset: CGSize(width: -28, height: 8),
                                rotation: .degrees(38),
                                shadowOpacity: 0.22)
        let card2 = ScatterItem(kind: .card(ThemeColor.accentSecondary, "diamond.fill", 56),
                                offset: CGSize(width: 42, height: 18),
                                rotation: .degrees(-22),
                                shadowOpacity: 0.22)
        generated.append(contentsOf: [card1, card2])
        scatterItems = generated
    }
}

#Preview("MainMenuHeaderView") {
    MainMenuHeaderView()
        .padding()
        .background(ThemeColor.backgroundMenu)
}
