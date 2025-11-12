//
//  GameSettingsView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 23/10/2025.
//

import SwiftUI

struct GameSettingsView: View {
    @EnvironmentObject var gameState: GameState
    @State private var settings = GameSettings()
    
    var body: some View {
        ZStack {
            ThemeColor.backgroundMenu
                .ignoresSafeArea(edges: [.bottom])
            VStack(spacing: 30) {
                    // Title Section
                    VStack(spacing: 8) {
                        Text("Sequence")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(ThemeColor.textPrimary)
                        Text("Select your game settings")
                            .font(.subheadline)
                            .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
                    }
                    .padding(.top, 20)
                    
                    // Settings Section
                    VStack(spacing: 24) {
                        // Number of Teams
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "person.2.fill")
                                    .foregroundStyle(ThemeColor.accentPrimary)
                                    .font(.title3)
                                Text("Number of Teams")
                                    .font(.headline)
                                    .foregroundStyle(ThemeColor.textPrimary)
                                Spacer()
                            }
                            Picker("Number of teams", selection: $settings.numberOfTeams) {
                                ForEach(2...3, id: \.self) { number in
                                    Text("\(number)").tag(number)
                                }
                            }
                            .pickerStyle(.segmented)
                            .tint(ThemeColor.accentPrimary)
                            .onChange(of: settings.numberOfTeams) { _, _ in
                                settings.adjustPlayersPerTeamIfNeeded()
                            }
                        }
                        .padding()
                        .background(ThemeColor.accentPrimary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(ThemeColor.border, lineWidth: 1))
                        
                        // Players per team
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .foregroundStyle(ThemeColor.accentSecondary)
                                    .font(.title3)
                                Text("Players in Team")
                                    .font(.headline)
                                    .foregroundStyle(ThemeColor.textPrimary)
                                Spacer()
                            }
                            Picker("Number of Players", selection: $settings.playersPerTeam) {
                                ForEach(settings.validPlayersPerTeamRange, id: \.self) { number in
                                    Text("\(number)").tag(number)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 100)
                            
                            Text("Total Players: \(settings.totalPlayers)")
                                .font(.subheadline)
                                .foregroundStyle(settings.isValid ? ThemeColor.textPrimary : .red)
                                .padding(.top, 8)

                            if let message = settings.validationMessage {
                                Text(message)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .padding(.top, 4)
                            }
                        }
                        .padding()
                        .background(ThemeColor.accentSecondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(ThemeColor.border, lineWidth: 1))
                        
                    }
                    .padding(.horizontal, 20)
                    
                    // Start Game Button
                NavigationLink(destination: GameView(numberOfPlayers: settings.playersPerTeam, numberOfTeams: settings.numberOfTeams)) {
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                                .font(.title3)
                            Text("Start Game")
                                .font(.headline)
                        }
                        .foregroundStyle(ThemeColor.textOnAccent)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(
                            LinearGradient(
                                colors: [
                                    ThemeColor.accentPrimary.opacity(0.95),
                                    ThemeColor.accentPrimary
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(ThemeColor.border, lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                    }
                    .accessibilityIdentifier("startGameButton")
                    .padding(.horizontal, 20)
                    .disabled(!settings.isValid)
                    .opacity(settings.isValid ? 1.0 : 0.6)
                    
                    Spacer()
                }
            }
            .navigationTitle("Sequence Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColor.backgroundMenu, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    GameSettingsView()
        .environmentObject(GameState())
}
