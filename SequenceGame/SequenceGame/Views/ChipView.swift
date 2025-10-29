//
//  ChipView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 27/10/2025.
//

import SwiftUI

struct ChipView: View {
    let color: Color
    var body: some View {
        if color == .secondary {
            Image(systemName: "largecircle.fill.circle")
                .resizable()
                .frame(width: 23, height: 23)
                .padding(2)
                .foregroundStyle(color)
        } else {
            Image(systemName: "circle.fill")
                .resizable()
                .frame(width: 23, height: 23)
                .padding(2)
                .foregroundStyle(color)
        }
       
    }
}

#Preview {
    ChipView(color: .secondary)
}
