//
//  SequenceGameApp.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 17/10/2025.
//

import SwiftUI

@main
struct SequenceGameApp: App {
    @StateObject var gameState = GameState()
    var body: some Scene {
        WindowGroup {
            MainMenu()
                .environmentObject(gameState)
                .preferredColorScheme(.light) // Force light mode always
        }
    }
}
