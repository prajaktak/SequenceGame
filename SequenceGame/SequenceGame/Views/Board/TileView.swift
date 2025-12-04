//
//  TileView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//

import SwiftUI

struct TileView: View {
    var isCard: Bool = true
    var card: Card?
    var color: Color
    var isChipVisible: Bool
    
    var body: some View {
        if isCard {
            ZStack {
                CardFaceView(card: card ?? Card(cardFace: .queen, suit: .clubs))
                ChipView(color: color)
                    .opacity(isChipVisible ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .border(.black, width: 0.25)
            
        } else {
            ZStack {
                CardFaceView(card: Card(cardFace: .empty, suit: .empty))
                ChipView(color: .secondary)
            }
            .background(.white)
            .border(.black, width: 0.25)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    TileView(card: Card(cardFace: .ten, suit: .clubs), color: .blue, isChipVisible: true)
        .frame(width: 32, height: 50)

}

#Preview {
    TileView(isCard: false, card: nil, color: .blue, isChipVisible: false)
        .frame(width: 32, height: 50)

}
