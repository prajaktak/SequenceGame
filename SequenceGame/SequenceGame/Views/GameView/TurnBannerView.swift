//
//  TurnBannerView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 29/10/2025.
//

import SwiftUI

struct TurnBannerView: View {
    let playerName: String
        let teamColor: Color

        var body: some View {
            Text("\(playerName) • Your turn")
                .font(.headline)
                .foregroundColor(ThemeColor.textOnAccent)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(teamColor))
                .shadow(color: .black.opacity(0.25), radius: 5, y: 2)
                .accessibilityLabel("\(playerName), your turn")
        }
}

#Preview("TurnBanner – Team Green") {
    TurnBannerView(playerName: "Prajakta", teamColor: ThemeColor.teamGreen)
        .padding(12)
        .background(ThemeColor.backgroundGame)
}
#Preview("TurnBanner – Team blue") {
    TurnBannerView(playerName: "Prajakta", teamColor: ThemeColor.teamBlue)
        .padding(12)
        .background(ThemeColor.backgroundGame)
}
#Preview("TurnBanner – Team red") {
    TurnBannerView(playerName: "Prajakta", teamColor: ThemeColor.teamRed)
        .padding(12)
        .background(ThemeColor.backgroundGame)
}
