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
            let fontSize = width * 0.22
            
            ZStack {
                // Four corner labels (top-left, top-right, bottom-left, bottom-right)
                VStack {
                    HStack {
                        Text(card.cardFace.displayValue)
                            .font(.system(size: fontSize, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, fontSize * 0.2)
                            .padding(.top, fontSize * 0.1)
                        Spacer()
                        Text(card.cardFace.displayValue)
                            .font(.system(size: fontSize, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, fontSize * 0.2)
                            .padding(.top, fontSize * 0.1)
                    }
                    Spacer()
                    HStack {
                        Text(card.cardFace.displayValue)
                            .font(.system(size: fontSize, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, fontSize * 0.2)
                            .padding(.bottom, fontSize * 0.1)
                        Spacer()
                        Text(card.cardFace.displayValue)
                            .font(.system(size: fontSize, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, fontSize * 0.2)
                            .padding(.bottom, fontSize * 0.1)
                    }
                }
                // Center pip arrangement
                CardPipsView(card: card)
                    .padding(fontSize * 0.1) // small padding if you want
            }
            .background(.white)
            .foregroundColor(card.suit.color)
            .frame(width: width, height: height)
            .border(Color.white, width: 1)
        }
    }
}

#Preview {
    CardFaceView(card: .init(cardFace: .ten, suit: .diamonds))
        .frame(width: 30, height: 50)
}
