//
//  CardFaceView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//

import SwiftUI
import UIKit

struct CardFaceView: View {
    @State var pipViewMaxWidth: CGFloat = 10
    @State var pipViewMaxHeight: CGFloat = 7
    let card: Card
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let fontSize = width * 0.18  // Slightly smaller for better fit
            let cornerPadding = fontSize * 0.4  // Padding for corner numbers
            let assetName = availableCenterAssetName(for: card)
            
            ZStack {
                if let assetName = assetName {
                    // Use pre-rendered card center artwork with numbers already baked in
                    Image(assetName)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, width * 0.02)
                        .padding(.vertical, height * 0.02)
                } else {
                    // Generated layout: draw corner numbers and center pips
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
                    
                    CardPipsView(pipViewMaxWidth: pipViewMaxWidth, card: card)
                        .padding(.horizontal, fontSize * 0.3)
                        .padding(.vertical, fontSize * 0.2)
                }
            }
            .background(.white)
            .foregroundColor(card.suit.color)
            .frame(width: width, height: height)
            .border(Color.gray, width: 1)
        }
    }
}

// MARK: - Asset name resolution
private func availableCenterAssetName(for card: Card) -> String? {
    let suit = suitName(card.suit)
    let rank = rankName(card.cardFace)
    let name = "card_center_\(rank)_\(suit)"
    return UIImage(named: name) != nil ? name : nil
}

private func suitName(_ suit: Suit) -> String {
    switch suit {
    case .hearts: return "heart"
    case .spades: return "spade"
    case .diamonds: return "diamond"
    case .clubs: return "club"
    }
}

private func rankName(_ face: CardFace) -> String {
    switch face {
    case .ace: return "ace"
    case .jack: return "jack"
    case .queen: return "queen"
    case .king: return "king"
    case .two: return "2"
    case .three: return "3"
    case .four: return "4"
    case .five: return "5"
    case .six: return "6"
    case .seven: return "7"
    case .eight: return "8"
    case .nine: return "9"
    case .ten: return "10"
    }
}

#Preview {
    CardFaceView(card: .init(cardFace: .ten, suit: .diamonds))
        .frame(width: 28, height: 40)
}
