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
                    ZStack {
                        // Corner numbers layer
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
                        
                        // Center pips layer - use padding to create safe area, GeometryReader will see reduced size
                        let horizontalPadding = fontSize * 0.3
                        let verticalPadding = fontSize * 0.2
                        
                        CardPipsView(pipViewMaxWidth: pipViewMaxWidth, card: card)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.vertical, verticalPadding)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .frame(width: width, height: height)
            .background(.white)
            .foregroundColor(ThemeColor.getSuitColor(for: card.suit) )
            .border(Color.gray, width: 1)
        }
    }
}

// MARK: - Asset name resolution
private func availableCenterAssetName(for card: Card) -> String? {
    let suit = card.suit.rawValue
    let rank = card.cardFace.rawValue
    let name = "card_center_\(rank)_\(suit)"
    return UIImage(named: name) != nil ? name : nil
}

#Preview {
    CardFaceView(card: .init(cardFace: .jack, suit: .diamonds))
        .frame(width: 28, height: 40)
}
