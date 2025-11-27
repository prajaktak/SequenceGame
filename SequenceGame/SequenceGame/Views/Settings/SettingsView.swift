//
//  SettingsView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("showTurnOverlays") private var showTurnOverlays = true
    @State private var selectedTheme: ThemeOption = .auto
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var showAttributions = false

    private let audioManager = AudioManager.shared

    private var soundEffectsBinding: Binding<Bool> {
        Binding(
            get: { audioManager.soundEffectsEnabled },
            set: { audioManager.soundEffectsEnabled = $0 }
        )
    }

    private var hapticsBinding: Binding<Bool> {
        Binding(
            get: { audioManager.hapticsEnabled },
            set: { audioManager.hapticsEnabled = $0 }
        )
    }
    
    enum ThemeOption: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case auto = "Auto"
        
        var systemName: String {
            switch self {
            case .light: return "sun.max.fill"
            case .dark: return "moon.fill"
            case .auto: return "circle.lefthalf.filled"
            }
        }
    }
    
    enum Difficulty: String, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        
        var description: String {
            switch self {
            case .easy: return "More time, fewer errors"
            case .medium: return "Balanced gameplay"
            case .hard: return "Fast-paced challenge"
            }
        }
        
        var icon: String {
            switch self {
            case .easy: return "1.circle.fill"
            case .medium: return "2.circle.fill"
            case .hard: return "3.circle.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [ThemeColor.backgroundMenu, ThemeColor.backgroundMenu.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ThemeColor.accentPrimary, ThemeColor.accentSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Settings")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(ThemeColor.textPrimary)
                            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                    }
                    .padding(.top, 20)
                    
                    // Audio & Haptics Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Audio & Feedback")
                            .font(.headline)
                            .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
                            .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
                        
                        // Sound Effects Toggle
                        SettingsToggleRow(
                            icon: "speaker.wave.2.fill",
                            title: "Sound Effects",
                            subtitle: "Game sounds and notifications",
                            isOn: soundEffectsBinding
                        )
                        
                        // Haptic Feedback Toggle
                        SettingsToggleRow(
                            icon: "iphone.radiowaves.left.and.right",
                            title: "Haptic Feedback",
                            subtitle: "Tactile responses",
                            isOn: hapticsBinding
                        )
                        // Show Turn Overlays Toggle
                        SettingsToggleRow(
                            icon: "eye.fill",
                            title: "Show Turn Overlays",
                            subtitle: "Display turn start and card hints",
                            isOn: $showTurnOverlays
                        )
                    }
                    
                    // Appearance Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Appearance")
                            .font(.headline)
                            .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
                            .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
                        
                        // Theme Selection
                        VStack(spacing: 12) {
                            ForEach(ThemeOption.allCases, id: \.self) { theme in
                                SettingsOptionButton(
                                    icon: theme.systemName,
                                    title: theme.rawValue,
                                    isSelected: selectedTheme == theme
                                ) {
                                    selectedTheme = theme
                                }
                            }
                        }
                    }
                    
                    // Gameplay Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Gameplay")
                            .font(.headline)
                            .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
                            .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
                        
                        VStack(spacing: 12) {
                            ForEach(Difficulty.allCases, id: \.self) { difficulty in
                                SettingsDifficultyButton(
                                    icon: difficulty.icon,
                                    title: difficulty.rawValue,
                                    subtitle: difficulty.description,
                                    isSelected: selectedDifficulty == difficulty
                                ) {
                                    selectedDifficulty = difficulty
                                }
                            }
                        }
                    }
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("Sequence v1.0")
                            .font(.caption)
                            .foregroundStyle(ThemeColor.textPrimary.opacity(0.5))
                        Text("Classic card game")
                            .font(.caption2)
                            .foregroundStyle(ThemeColor.textPrimary.opacity(0.4))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
