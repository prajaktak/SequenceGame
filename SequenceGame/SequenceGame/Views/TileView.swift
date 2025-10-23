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
    var body: some View {
        if isCard {
            CardFaceView(card: card ?? Card(cardFace: .queen, suit: .clubs))
                .frame(width: 28, height: 45)
        } else {
            ZStack {
                Image(systemName: "circle" )
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 23, height: 41)
                    .padding(2)
            }
            .background(.white)
            .frame(width: 25, height: 41)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 3)
        }
    }
}

#Preview {
    TileView(card: Card(cardFace: .ten, suit: .clubs))
}

#Preview {
    TileView(isCard: false, card: nil)
}
