//
//  SequenceGameView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 22/10/2025.
//

import SwiftUI

struct SequenceGameView: View {
    var body: some View {
        NavigationView{
           VStack{
               HStack{
                   VStack {
                       Text("Team Blue")
                           .font(.title3)
                       Image(systemName: "circle.fill")
                           .font(.title)
                           .foregroundStyle(.blue)
                       Text("Score: 0")
                   }
                  Image(systemName: "inset.filled.rectangle.portrait")
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width: 70 , height: 70)
                   CardFaceView(card: Card(cardFace: .ace, suit: .hearts))
                       
                   VStack {
                       Text("Team Green")
                           .font(.title3)
                       Image(systemName: "circle.fill")
                           .font(.title)
                           .foregroundStyle(.green)
                       Text("Score: 0")
                   }
               }
               .padding(10)
               SequenceBoardView()
            }
           .navigationTitle("Sequence Game")
           .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SequenceGameView()
}
