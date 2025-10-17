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
        } else {
            ZStack {
                Image(systemName: "circle" )
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(width: 25, height: 45)
            .foregroundColor(Color.black)
            .padding(.horizontal, 3)
            .border(Color.black)
        }
    }
}

#Preview {
    TileView(card: Card(cardFace: .ten, suit: .clubs))
}

#Preview {
    TileView(isCard: false, card: nil)
}
