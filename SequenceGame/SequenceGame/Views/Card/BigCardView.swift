//
//  BigCardView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 27/10/2025.
//

import SwiftUI

struct BigCardView: View {
    @Environment(\.dismiss) private var dismiss
    @State var tappedCard: Card
    var body: some View {
        NavigationStack {
            CardFaceView(pipViewMaxWidth: 100, pipViewMaxHeight: 100, card: tappedCard)
                .frame(width: 200, height: 300)
            Button("Close me") {
                dismiss()
            }
        }
        
    }
}

#Preview {
    BigCardView(tappedCard: Card(cardFace: .ace, suit: .hearts))
}
