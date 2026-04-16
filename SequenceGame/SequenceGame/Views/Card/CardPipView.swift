//
//  CardPipView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//

import SwiftUI

struct CardPipsView: View {
    let card: Card

    var body: some View {
        GeometryReader { geometry in
            let pipSize = min(geometry.size.width * 0.9, geometry.size.height * 0.85)
            let rankFontSize = pipSize * 0.45

            // Diamonds fill less of their SF Symbol bounding box than the other suits,
            // so scale them up to match the visual size of hearts/spades/clubs.
            let imageScale: CGFloat = card.suit == .diamonds ? 1.2 : 1.0

            ZStack {
                Image(systemName: card.suit.systemImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: pipSize, height: pipSize)
                    .scaleEffect(imageScale)
                    .foregroundColor(ThemeColor.getSuitColor(for: card.suit))

                Text(card.cardFace.displayValue)
                    .font(.system(size: rankFontSize, weight: .black))
                    .foregroundColor(.white)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview {
    CardPipsView(card: .init(cardFace: .ten, suit: .diamonds))
        .frame(width: 60, height: 95)
}
