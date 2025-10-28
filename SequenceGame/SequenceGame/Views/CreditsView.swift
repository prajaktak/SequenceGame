//
//  CreditsView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
        NavigationLink(destination: AttributionsView()) {
            Text("Game assets")
        }
    }
}

#Preview {
    CreditsView()
}
