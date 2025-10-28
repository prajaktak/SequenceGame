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
    @State var color: Color
    @State var isChipVisible: Bool
    
    var body: some View {
        if isCard {
            ZStack {
                CardFaceView(card: card ?? Card(cardFace: .queen, suit: .clubs))
                    .frame(width: GameConstants.UISizing.tileWidth, height: GameConstants.UISizing.tileHeight)
                ChipView(color: color)
                    .opacity(isChipVisible ? 1 : 0)
            }
            
        } else {
            ZStack {
                Image(systemName: "circle" )
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 23, height: 38)
                    .padding(2)
            }
            .background(.white)
            .frame(width: 23, height: 38)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 3)
        }
    }
}

#Preview {
    TileView(card: Card(cardFace: .ten, suit: .clubs), color: .blue, isChipVisible: true)
}

#Preview {
    TileView(isCard: false, card: nil, color: .blue, isChipVisible: false)
}
