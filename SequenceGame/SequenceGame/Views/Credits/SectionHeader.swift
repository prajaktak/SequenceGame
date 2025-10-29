//
//  SectionHeader.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
    }
}

#Preview {
    SectionHeader(title: "App Information")
        .padding()
}
