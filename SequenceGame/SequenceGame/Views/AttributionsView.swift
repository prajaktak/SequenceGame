//
//  AttributionsView.swift
//  SequenceGame
//
//  Created by Assistant on 28/10/2025.
//

import SwiftUI

struct AttributionsView: View {
    private let attributionTitle = "Open Source Attributions"
    
    private let attributionBody = """
Vectorized Playing Cards 3.2
https://totalnonsense.com/open-source-vector-playing-cards/
Copyright 2011,2024 – Chris Aguilar – conjurenation@gmail.com
Licensed under: LGPL 3.0 - https://www.gnu.org/licenses/lgpl-3.0.html
"""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(attributionTitle)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
                
                GroupBox(label: Text("Vectorized Playing Cards")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(attributionBody)
                            .font(.caption)
                            .textSelection(.enabled)
                            .foregroundColor(.primary)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Link("Project Homepage", destination: URL(string: "https://totalnonsense.com/open-source-vector-playing-cards/")!)
                            Link("LGPL 3.0 License", destination: URL(string: "https://www.gnu.org/licenses/lgpl-3.0.html")!)
                        }
                        .font(.footnote)
                    }
                    .padding(.vertical, 4)
                }
                
                Text("Notes")
                    .font(.headline)
                Text("These assets are provided under the LGPL 3.0. Attribution is required and NFTs/derivative NFT sales are not permitted.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle("Attributions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        AttributionsView()
    }
}
