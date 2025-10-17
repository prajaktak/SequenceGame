//
//  CardPipView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 21/10/2025.
//

import SwiftUI

struct CardPipsView: View {
    let card: Card
    let pipSize: CGFloat = 4
    
    var body: some View {
        ZStack {
            switch card.cardFace {
            case .ace:
                singleCenteredPip()
            case .two:
                twoPips()
            case .three:
                threePips()
            case .four:
                fourPips()
            case .five:
                fivePips()
            case .six:
                sixPips()
            case .seven:
                sevenPips()
            case .eight:
                eightPips()
            case .nine:
                ninePips()
            case .ten:
                tenPips()
            default:
                // Face cards: single big symbol or custom design
                singleCenteredPip()
            }
        }
        .frame(width: 25, height: 45)
    }
    
    // Example Pip Components
    func pip(padding: CGFloat = 0) -> some View {
        VStack {
            Image(systemName: card.suit.systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: pipSize, height: pipSize)
                .foregroundColor(card.suit.color)
                .padding(padding)
        }
    }
    
    func singleCenteredPip() -> some View {
        pip()
    }
    
    func twoPips() -> some View {
        VStack {
            pip()
            pip()
        }
    }
    
    func threePips() -> some View {
        VStack {
            pip()
            pip()
            pip()
        }
    }
    
    func fourPips() -> some View {
        VStack {
            HStack {
                pip()
                pip()
            }
            HStack {
                pip()
                pip()
            }
        }
    }
    
    func fivePips() -> some View {
        ZStack {
            fourPips()
            pip()
        }
    }
    func sixPips() -> some View {
        HStack {
            threePips()
            threePips()
        }
        
    }
    func sevenPips() -> some View {
        ZStack {
            sixPips()
            VStack {
                Spacer()
                pip()
                    .padding(.top, 1)
                Spacer()
                Spacer()
            }
        }
    }
    func eightPips() -> some View {
        ZStack {
            sixPips()
            VStack {
                Spacer()
                pip()
                pip()
                Spacer()
            }
        }
    }
    func ninePips() -> some View {
        ZStack {
            HStack {
                threePips()
                threePips()
            }
            VStack {
                Spacer()
                threePips()
                Spacer()
                Spacer()
            }
        }
    }
    func tenPips() -> some View {
        ZStack {
            HStack {
                threePips()
                threePips()
            }
            VStack {
                threePips()
                pip()
            }
            
        }
    }
    
}

#Preview {
    CardPipsView(card: .init(cardFace: .ten, suit: .diamonds))
}
