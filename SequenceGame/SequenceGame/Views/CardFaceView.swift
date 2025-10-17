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
        ZStack {
            VStack {
                HStack {
                    Text(card.cardFace.displayValue)
                        .font(.system(size: 5))
                        .fontWeight(.bold)
                    Spacer()
                    Text(card.cardFace.displayValue)
                        .font(.system(size: 5))
                        .fontWeight(.bold)
                }
                .padding(.vertical, 2)
                Spacer()
                HStack {
                    Text(card.cardFace.displayValue)
                        .font(.system(size: 5))
                        .fontWeight(.bold)
                    Spacer()
                    Text(card.cardFace.displayValue)
                        .font(.system(size: 5))
                        .fontWeight(.bold)
                }
                .padding(.vertical, 2)
            }
            CardPipsView(card: card)
        }
        .frame(width: 25, height: 45)
        .foregroundColor(card.suit.color)
        .padding(.horizontal, 2)
        .border(Color.black)
    }
}

#Preview {
    CardFaceView(card: .init(cardFace: .ten, suit: .diamonds))
}
