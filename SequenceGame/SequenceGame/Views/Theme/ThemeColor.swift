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
    static let accentTertiary = Color("AccentTertiary")
}

#Preview {
    VStack(spacing: 20) {
        Text("Theme Colors")
            .font(.headline)
        
        // Primary colors
        HStack(spacing: 15) {
            VStack {
                Circle().fill(ThemeColor.accentPrimary).frame(width: 50)
                Text("Accent")
            }
            VStack {
                Circle().fill(ThemeColor.accentSecondary).frame(width: 50)
                Text("Secondary")
            }
            VStack {
                Circle().fill(ThemeColor.accentTertiary).frame(width: 50)
                Text("Tertiary")
            }
            VStack {
                Circle().fill(ThemeColor.accentGolden).frame(width: 50)
                Text("Golden")
            }
            VStack {
                Circle().fill(ThemeColor.accentYellowGolden).frame(width: 50)
                Text("Yellow")
            }
        }
        
        // Backgrounds
        HStack(spacing: 15) {
            VStack {
                RoundedRectangle(cornerRadius: 8).fill(ThemeColor.backgroundGame).frame(width: 50, height: 50)
                Text("Game BG")
            }
            VStack {
                RoundedRectangle(cornerRadius: 8).fill(ThemeColor.backgroundMenu).frame(width: 50, height: 50)
                Text("Menu BG")
            }
            VStack {
                RoundedRectangle(cornerRadius: 8).fill(ThemeColor.boardFelt).frame(width: 50, height: 50)
                Text("Felt")
            }
        }
        
        // Text colors
        HStack(spacing: 15) {
            VStack {
                Circle().fill(ThemeColor.textPrimary).frame(width: 50)
                Text("Primary")
            }
            VStack {
                Circle().fill(ThemeColor.textOnAccent).frame(width: 50)
                Text("On Accent")
            }
            VStack {
                Circle().fill(ThemeColor.border).frame(width: 50)
                Text("Border")
            }
        }
        
        // Team colors
        HStack(spacing: 15) {
            VStack {
                Circle().fill(ThemeColor.teamBlue).frame(width: 50)
                Text("Blue")
            }
            VStack {
                Circle().fill(ThemeColor.teamGreen).frame(width: 50)
                Text("Green")
            }
        }
    }
    .padding()
}
