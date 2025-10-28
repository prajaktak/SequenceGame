//
//  MainMenu.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct MainMenu: View {
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColor.backgroundMenu
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // Logo/Title Section
                    VStack(spacing: 16) {
                        ZStack {
                            HStack(spacing: 10) {
                                ForEach(0..<5) { index in
                                    let size: CGFloat = {
                                        switch index {
                                        case 0: return 20
                                        case 1: return 30
                                        case 2: return 50  // peak
                                        case 3: return 30
                                        case 4: return 20
                                        default: return 40
                                        }
                                    }()
                                    let yOffset: CGFloat = {
                                        switch index {
                                        case 0: return 5
                                        case 1: return -5
                                        case 2: return -15 // center, no offset
                                        case 3: return -5
                                        case 4: return 5
                                        default: return 0
                                        }
                                    }()
                                    Image(systemName: "star.fill")
                                        .font(.system(size: size))
                                        .foregroundStyle(
                                            AngularGradient(colors: [ThemeColor.accentYellowGolden,
                                                ThemeColor.accentPrimary,
                                                ThemeColor.accentGolden], center: UnitPoint(x: 0.5, y: 0.5), angle: Angle(degrees: 90))
                                        )
                                        .shadow(color: ThemeColor.accentPrimary.opacity(0.3), radius: 12, x: 0, y: 4)
                                        .offset(y: yOffset)
                                }
                            }
                        }
                        .frame(height: 60)
                        
                        Text("Sequence")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(ThemeColor.textPrimary)
                        Text("Classic Card Game")
                            .font(.title3)
                            .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Menu Buttons
                    VStack(spacing: 16) {
                        // New Game Button
                        NavigationLink(destination: GameSettingsView()) {
                            HStack(spacing: 16) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 28))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("New Game")
                                        .font(.headline)
                                    Text("Start a fresh game")
                                        .font(.subheadline)
                                        .opacity(0.8)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .opacity(0.5)
                            }
                            .foregroundStyle(ThemeColor.textOnAccent)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, minHeight: 70)
                            .background(
                                LinearGradient(
                                    colors: [
                                        ThemeColor.accentPrimary.opacity(0.95),
                                        ThemeColor.accentPrimary
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(ThemeColor.border, lineWidth: 1.5)
                            )
                            .shadow(color: ThemeColor.accentPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                        
                        // Resume Game Button
                        NavigationLink(destination: SequenceGameView()) {
                            HStack(spacing: 16) {
                                Image(systemName: "arrow.uturn.forward.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(ThemeColor.accentSecondary)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Resume Game")
                                        .font(.headline)
                                    Text("Continue where you left off")
                                        .font(.subheadline)
                                        .opacity(0.8)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .opacity(0.5)
                            }
                            .foregroundStyle(ThemeColor.textPrimary)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, minHeight: 70)
                            .background(ThemeColor.backgroundMenu)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(ThemeColor.border, lineWidth: 1.5)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        
                        // Settings Button
                        NavigationLink(destination: SettingsView()) {
                            HStack(spacing: 16) {
                                Image(systemName: "gearshape.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(ThemeColor.accentPrimary)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Settings")
                                        .font(.headline)
                                    Text("Preferences and options")
                                        .font(.subheadline)
                                        .opacity(0.8)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .opacity(0.5)
                            }
                            .foregroundStyle(ThemeColor.textPrimary)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, minHeight: 70)
                            .background(ThemeColor.backgroundMenu)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(ThemeColor.border, lineWidth: 1.5)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        
                        // About Button
                        NavigationLink(destination: AttributionsView()) {
                            HStack(spacing: 16) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(ThemeColor.accentSecondary)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("About & Credits")
                                        .font(.headline)
                                    Text("App info and attributions")
                                        .font(.subheadline)
                                        .opacity(0.8)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .opacity(0.5)
                            }
                            .foregroundStyle(ThemeColor.textPrimary)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, minHeight: 70)
                            .background(ThemeColor.backgroundMenu)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(ThemeColor.border, lineWidth: 1.5)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Footer
                    Text("v1.0")
                        .font(.caption)
                        .foregroundStyle(ThemeColor.textPrimary.opacity(0.5))
                        .padding(.bottom, 20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColor.backgroundMenu, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    MainMenu()
}
