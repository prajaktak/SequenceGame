//
//  CardPipView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//

import SwiftUI

struct CardPipsView: View {
    var pipViewMaxWidth: CGFloat = 10
    var pipviewMaxHeight: CGFloat = 7
    let card: Card
    
    enum LayoutAxis { case rows, columns }
    
    var body: some View {
        GeometryReader { geometry in
            let layout = pipLayout(card.cardFace)
            let counts = layout.counts
            let rowCount = counts.count
            let maxPipsPerLine = counts.max() ?? 1
            
            // Compute a responsive pip size based on available space and layout density
            let pipSize = calculatePipSize(
                availableWidth: geometry.size.width,
                availableHeight: geometry.size.height,
                maxPipsPerLine: maxPipsPerLine,
                lineCount: rowCount,
                axis: layout.axis
            )
            
            Group {
                if layout.axis == .rows {
                    VStack(spacing: max(1, pipSize * 0.2)) {
                        ForEach(Array(counts.enumerated()), id: \.offset) { _, pipsInRow in
                            HStack(spacing: max(1, pipSize * 0.2)) {
                                Spacer(minLength: 0)
                                ForEach(0..<pipsInRow, id: \.self) { _ in
                                    Image(systemName: card.suit.systemImageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: pipSize, height: pipSize)
                                        .foregroundColor(card.suit.color)
                                }
                                Spacer(minLength: 0)
                            }
                        }
                    }
                } else { // columns
                    HStack(spacing: max(1, pipSize * 0.2)) {
                        ForEach(Array(counts.enumerated()), id: \.offset) { _, pipsInColumn in
                            VStack(spacing: max(1, pipSize * 0.2)) {
                                Spacer(minLength: 0)
                                ForEach(0..<pipsInColumn, id: \.self) { _ in
                                    Image(systemName: card.suit.systemImageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: pipSize, height: pipSize)
                                        .foregroundColor(card.suit.color)
                                }
                                Spacer(minLength: 0)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // Data-driven pip patterns (line counts) with axis selection
    func pipLayout(_ face: CardFace) -> (axis: LayoutAxis, counts: [Int]) {
        switch face {
        case .ace:
            return (.rows, [1])
        case .two:
            return (.rows, [1, 1])           // vertical stack
        case .three:
            return (.rows, [1, 1, 1])        // vertical stack
        case .four:
            return (.rows, [2, 2])           // corners per row
        case .five:
            return (.rows, [2, 1, 2])        // corners + center
        case .six:
            return (.columns, [3, 3])        // two columns of three
        case .seven:
            return (.columns, [3, 1, 3])     // 3-1-3 columns
        case .eight:
            return (.columns, [3, 2, 3])     // 3-2-3 columns
        case .nine:
            return (.rows, [3, 3, 3])        // 3x3 grid
        case .ten:
            return (.columns, [4, 2, 4])     // 4-2-4 columns (vertical 4s)
        default:
            return (.rows, [1])
        }
    }
    
    private func calculatePipSize(
        availableWidth: CGFloat,
        availableHeight: CGFloat,
        maxPipsPerLine: Int,
        lineCount: Int,
        axis: LayoutAxis
    ) -> CGFloat {
        // Reserve some breathing room so pips do not touch edges or corner numbers
        let horizontalPaddingFactor: CGFloat = 0.85
        let verticalPaddingFactor: CGFloat = 0.80
        
        // Determine limiting dimension based on axis
        let widthPerPip: CGFloat
        let heightPerPip: CGFloat
        if axis == .rows {
            widthPerPip = (availableWidth * horizontalPaddingFactor) / CGFloat(max(1, maxPipsPerLine))
            heightPerPip = (availableHeight * verticalPaddingFactor) / CGFloat(max(1, lineCount))
        } else { // columns
            // Swap logic because we are laying out columns of VStacks
            widthPerPip = (availableWidth * horizontalPaddingFactor) / CGFloat(max(1, lineCount))
            heightPerPip = (availableHeight * verticalPaddingFactor) / CGFloat(max(1, maxPipsPerLine))
        }
        
        var size = min(widthPerPip, heightPerPip) * 0.8
        size = min(max(size, 4), 12)
        return size
    }
}

#Preview {
    CardPipsView(card: .init(cardFace: .ten, suit: .diamonds))
        .frame(width: 25, height: 45)
}
