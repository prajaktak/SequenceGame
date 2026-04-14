//
//  CardFaceView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//

import SwiftUI

struct CardFaceView: View {
    let card: Card

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let fontSize = width * 0.18
            let cornerPadding = fontSize * 0.4

            ZStack {
                // Corner rank labels
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text(card.cardFace.displayValue)
                            .font(.system(size: fontSize, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, cornerPadding)
                            .padding(.top, cornerPadding * 0.5)
                        Spacer()
                        Text(card.cardFace.displayValue)
                            .font(.system(size: fontSize, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, cornerPadding)
                            .padding(.top, cornerPadding * 0.5)
                    }
                    Spacer()
                    HStack(spacing: 0) {
                        Text(card.cardFace.displayValue)
                            .font(.system(size: fontSize, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, cornerPadding)
                            .padding(.bottom, cornerPadding * 0.5)
                        Spacer()
                        Text(card.cardFace.displayValue)
                            .font(.system(size: fontSize, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, cornerPadding)
                            .padding(.bottom, cornerPadding * 0.5)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Center pips
                CardPipsView(card: card)
                    .padding(.horizontal, fontSize * 0.3)
                    .padding(.vertical, fontSize * 0.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: width, height: height)
            .background(.white)
            .foregroundColor(ThemeColor.getSuitColor(for: card.suit))
            .border(Color.gray, width: 1)
        }
    }
}

#Preview {
    CardFaceView(card: .init(cardFace: .jack, suit: .diamonds))
        .frame(width: 28, height: 40)
}
