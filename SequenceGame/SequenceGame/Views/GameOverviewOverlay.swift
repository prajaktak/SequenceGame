//
//  GameOverviewOverlay.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 25/10/2025.
//

import SwiftUI

struct GameOverviewOverlay: View {
    @State  var team1CoinsPlaced: Int = 0
    @State  var team2CoinsPlaced: Int = 0
    @Binding  var isVisible: Bool
    @State var playerName: String = ""

    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("Team Blue")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Image(systemName: "circle.fill")
                        .font(.title)
                        .foregroundStyle(.blue)
                    Text("Coins Placed: \(team1CoinsPlaced)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                }
                Spacer()
                VStack {
                    Text("Card Deck")
                        .font(.footnote)
                    Image(systemName: "inset.filled.rectangle.portrait")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                }
                VStack {
                    Text("Draw Pile")
                        .font(.footnote)
                    CardFaceView(card: Card(cardFace: .ace, suit: .hearts))
                        .frame(width: 40, height: 60)
                        .border(Color.gray)
                }
                Spacer()
                VStack {
                    Text("Team Green")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Image(systemName: "circle.fill")
                        .font(.title)
                        .foregroundStyle(.green)
                    Text("Coins Placed: \(team2CoinsPlaced)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                }
            }
            .padding(10)
        }
        .background(.white)
        .border(.gray, width: 1)
        .opacity(isVisible ? 1 : 0)
    }
}

#Preview {
   // GameOverviewOverlay(isVisible: )
}
