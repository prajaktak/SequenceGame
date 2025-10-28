//
//  ThemeColor.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

enum ThemeColor {
    static let backgroundGame = Color("BackgroundGame")
    static let backgroundMenu = Color("BackgroundMenu")
    static let boardFelt = Color("BoardFelt")
    static let accentPrimary = Color("AccentPrimary")
    static let accentSecondary = Color("AccentSecondary")
    static let textPrimary = Color("TextPrimary")
    static let textOnAccent = Color("TextOnAccent")
    static let border = Color("Border")
    static let teamBlue = Color("TeamBlue")
    static let teamGreen = Color("TeamGreen")
    static let accentGolden = Color("AccentGolden")
    static let accentYellowGolden = Color("AccentYellowGolden")
}
#Preview {
    HStack(spacing: 20) {
        Circle().fill(ThemeColor.accentPrimary).frame(width: 40)
        Circle().fill(ThemeColor.boardFelt).frame(width: 40)
        Circle().fill(ThemeColor.teamBlue).frame(width: 40)
    }
    .padding()
}
