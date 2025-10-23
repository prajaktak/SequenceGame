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
        HStack(spacing: 0) {
            ForEach(pipRows(card.cardFace), id: \.self) { pipRow in
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    ForEach(0..<pipRow, id: \.self) { _ in
                        pipView
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    func pipRows(_ face: CardFace) -> [Int] {
        switch face {
        case .ace:
            return [1]
        case .two:
            return [2]
        case .three:
            return [3]
        case .four:
            return [2, 2]
        case .five:
            return [2, 1, 2]
        case .six:
            return [3, 3]
        case .seven:
            return [3, 1, 3]
        case .eight:
            return [3, 2, 3]
        case .nine:
            return [3, 3, 3]
        case .ten:
            return [3, 4, 3]
        default:
            return [1]
        }
    }
    var pipView: some View {
        Image(systemName: card.suit.systemImageName)
            .resizable()
            .scaledToFit()
            .frame(minWidth: 0, maxWidth: 10, minHeight: 0, maxHeight: 10)
            .foregroundColor(card.suit.color)
            .aspectRatio(1, contentMode: .fit)
            .padding(2)
    }
}

#Preview {
    CardPipsView(card: .init(cardFace: .ten, suit: .diamonds))
        .frame(width: 25, height: 45)
}
