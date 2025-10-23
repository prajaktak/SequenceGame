//
//  SequenceGameView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 22/10/2025.
//

import SwiftUI

struct SequenceGameView: View {
    var body: some View {
        NavigationView {
           VStack {
               HStack {
                   VStack {
                       Text("Team Blue")
                           .font(.title3)
                       Image(systemName: "circle.fill")
                           .font(.title)
                           .foregroundStyle(.blue)
                       Text("Score: 0")
                           .padding(.top, 10)
                   }
                   Spacer()
                   VStack {
                       Text("Card Deck")
                           .font(.footnote)
                       Image(systemName: "inset.filled.rectangle.portrait")
                           .resizable()
                           .aspectRatio(contentMode: .fit)
                           .frame(width: 70, height: 70)
                   }
                   VStack {
                       Text("Draw Pile")
                           .font(.footnote)
                       CardFaceView(card: Card(cardFace: .ace, suit: .hearts))
                           .frame(width: 45, height: 70)
                           .border(Color.gray)
                   }
                    Spacer()
                   VStack {
                       Text("Team Green")
                           .font(.title3)
                       Image(systemName: "circle.fill")
                           .font(.title)
                           .foregroundStyle(.green)
                       Text("Score: 0")
                           .padding(.top, 10)
                   }
               }
               .padding(10)
               SequenceBoardView()
                   .padding(.top, 10)
               HStack {
                   ForEach(0..<7) {_ in
                       CardFaceView(card: Card(cardFace: .ace, suit: .hearts))
                           .frame(width: 45, height: 70)
                           .border(Color.gray)
                   }
                   
               }
            }
           .navigationTitle("Sequence Game")
           .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SequenceGameView()
}
