//
//  MainMenu.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct MainMenu: View {
    @State private var scatterItems: [ScatterItem] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [ThemeColor.backgroundMenu, ThemeColor.backgroundMenu.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                    .ignoresSafeArea()
                
                VStack(spacing: GameConstants.UISizing.largeSpacing) {
                    // Logo/Title Section
                    VStack(spacing: 16) {
                        ZStack {
                            ForEach(scatterItems) { item in
                                switch item.kind {
                                case .chip(let color, let size):
                                    Circle()
                                        .fill(color)
                                        .frame(width: size, height: size)
                                        .shadow(
                                            color: .black.opacity(item.shadowOpacity),
                                            radius: 4,
                                            x: 2,
                                            y: 2
                                        )
                                        .offset(item.offset)
                                        .rotationEffect(item.rotation)
                                case .card(let borderColor, let suitSymbol, let size):
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.white)
                                        .frame(width: size * 0.75, height: size)
                                        .overlay(
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(borderColor, lineWidth: 2)
                                                Image(systemName: suitSymbol)
                                                    .font(.system(size: size * 0.4))
                                                    .foregroundStyle(borderColor)
                                            }
                                        )
                                        .shadow(
                                            color: .black.opacity(item.shadowOpacity * 0.8),
                                            radius: 6,
                                            x: 1,
                                            y: 3
                                        )
                                        .offset(item.offset)
                                        .rotationEffect(item.rotation)
                                }
                            }
                        }
                        .frame(height: 90)
                        .onAppear {
                            guard scatterItems.isEmpty else { return }
                            // Use theme tertiary accent color from assets
                            let chipColors: [Color] = [ThemeColor.teamBlue, ThemeColor.teamGreen, ThemeColor.accentSecondary, ThemeColor.accentTertiary]
                            // Generate 5 chips
                            var generated: [ScatterItem] = (0..<5).map { _ in
                                let color = chipColors.randomElement() ?? ThemeColor.teamBlue
                                let size = CGFloat(Int.random(in: 26...38))
                                let offsetX = CGFloat(Int.random(in: -70...70))
                                let offsetY = CGFloat(Int.random(in: -18...30))
                                let rotationDegrees = Double(Int.random(in: -40...40))
                                return ScatterItem(
                                    kind: .chip(color, size),
                                    offset: CGSize(width: offsetX, height: offsetY),
                                    rotation: .degrees(rotationDegrees),
                                    shadowOpacity: 0.28
                                )
                            }
                            // Add two tilted cards with suits resembling Jacks context
                            let card1 = ScatterItem(
                                kind: .card(ThemeColor.accentPrimary, "spade.fill", 62),
                                offset: CGSize(width: -28, height: 8),
                                rotation: .degrees(38),
                                shadowOpacity: 0.22
                            )
                            let card2 = ScatterItem(
                                kind: .card(ThemeColor.accentSecondary, "diamond.fill", 56),
                                offset: CGSize(width: 42, height: 18),
                                rotation: .degrees(-22),
                                shadowOpacity: 0.22
                            )
                            generated.append(contentsOf: [card1, card2])
                            scatterItems = generated
                        }
                        
                        Text("Sequence")
                            .font(.system(size: 58, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ThemeColor.accentPrimary, ThemeColor.accentSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("Classic Board Game")
                            .font(.title3.weight(.heavy))
                            .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Menu Buttons
                    VStack(spacing: GameConstants.UISizing.verticalSpacing) {
                        // New Game Button
                        NavigationLink(destination: GameSettingsView()) {
                            HStack(spacing: 16) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: GameConstants.UISizing.iconSizeLarge))
                                    .foregroundStyle(ThemeColor.textOnAccent)
                                VStack(alignment: .leading, spacing: 4) {
                                Text("New Game")
                                        .font(.system(.headline, design: .rounded).weight(.heavy))
                                    Text("Start a fresh game")
                                        .font(.system(.subheadline, design: .rounded))
                                        .opacity(0.9)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .opacity(0.7)
                            }
                            .foregroundStyle(ThemeColor.textOnAccent)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, minHeight: GameConstants.UISizing.secondaryButtonHeight)
                            .background(
                                LinearGradient(
                                    colors: [ThemeColor.accentPrimary, ThemeColor.accentSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.largeCornerRadius, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: GameConstants.UISizing.largeCornerRadius)
                                    .stroke(ThemeColor.border, lineWidth: 1.5)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: GameConstants.UISizing.largeCornerRadius)
                                    .stroke(ThemeColor.accentSecondary.opacity(0.35), lineWidth: 1)
                                    .padding(1)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        
                        // Resume Game Button
                        NavigationLink(destination: SequenceGameView()) {
                            HStack(spacing: 16) {
                                Image(systemName: "arrow.uturn.forward.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(ThemeColor.textOnAccent)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Resume Game")
                                        .font(.system(.headline, design: .rounded).weight(.heavy))
                                    Text("Continue where you left off")
                                        .font(.system(.subheadline, design: .rounded))
                                        .opacity(0.9)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .opacity(0.7)
                            }
                            .foregroundStyle(ThemeColor.textOnAccent)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, minHeight: GameConstants.UISizing.secondaryButtonHeight)
                            .background(
                                LinearGradient(
                                    colors: [ThemeColor.accentPrimary, ThemeColor.accentTertiary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.largeCornerRadius, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: GameConstants.UISizing.largeCornerRadius)
                                    .stroke(ThemeColor.border, lineWidth: 1.5)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: GameConstants.UISizing.largeCornerRadius)
                                    .stroke(ThemeColor.accentTertiary.opacity(0.35), lineWidth: 1)
                                    .padding(1)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        
                        // Help Button
                        NavigationLink(destination: HelpView()) {
                            HStack(spacing: 16) {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(ThemeColor.textOnAccent)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("How to Play")
                                        .font(.system(.headline, design: .rounded).weight(.heavy))
                                    Text("Game rules and tips")
                                        .font(.system(.subheadline, design: .rounded))
                                        .opacity(0.9)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .opacity(0.7)
                            }
                            .foregroundStyle(ThemeColor.textOnAccent)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, minHeight: GameConstants.UISizing.secondaryButtonHeight)
                            .background(
                                LinearGradient(
                                    colors: [ThemeColor.accentPrimary, ThemeColor.accentSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.largeCornerRadius, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: GameConstants.UISizing.largeCornerRadius)
                                    .stroke(ThemeColor.border, lineWidth: 1.5)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: GameConstants.UISizing.largeCornerRadius)
                                    .stroke(ThemeColor.accentSecondary.opacity(0.35), lineWidth: 1)
                                    .padding(1)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        
                        // Settings Button
                        NavigationLink(destination: SettingsView()) {
                            HStack(spacing: 16) {
                                Image(systemName: "gearshape.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(ThemeColor.textOnAccent)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Settings")
                                        .font(.system(.headline, design: .rounded).weight(.heavy))
                                    Text("Preferences and options")
                                        .font(.system(.subheadline, design: .rounded))
                                        .opacity(0.9)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .opacity(0.7)
                            }
                            .foregroundStyle(ThemeColor.textOnAccent)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, minHeight: GameConstants.UISizing.secondaryButtonHeight)
                            .background(
                                LinearGradient(
                                    colors: [ThemeColor.accentPrimary, ThemeColor.accentTertiary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.largeCornerRadius, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: GameConstants.UISizing.largeCornerRadius)
                                    .stroke(ThemeColor.border, lineWidth: 1.5)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: GameConstants.UISizing.largeCornerRadius)
                                    .stroke(ThemeColor.accentTertiary.opacity(0.35), lineWidth: 1)
                                    .padding(1)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                        
                        // About Button
                        NavigationLink(destination: CreditsView()) {
                            HStack(spacing: 16) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(ThemeColor.textOnAccent)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("About & Credits")
                                        .font(.system(.headline, design: .rounded).weight(.heavy))
                                    Text("App info and attributions")
                                        .font(.system(.subheadline, design: .rounded))
                                        .opacity(0.9)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .opacity(0.7)
                            }
                            .foregroundStyle(ThemeColor.textOnAccent)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, minHeight: GameConstants.UISizing.secondaryButtonHeight)
                            .background(
                                LinearGradient(
                                    colors: [ThemeColor.accentPrimary, ThemeColor.accentSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.largeCornerRadius, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: GameConstants.UISizing.largeCornerRadius)
                                    .stroke(ThemeColor.border, lineWidth: 1.5)
                            )
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
                    
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
