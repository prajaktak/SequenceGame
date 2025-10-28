//
//  SettingsView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var soundEffectsEnabled = true
    @State private var hapticFeedbackEnabled = true
    @State private var selectedTheme: ThemeOption = .auto
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var showAttributions = false
    
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
            ThemeColor.backgroundMenu
                .ignoresSafeArea(edges: .bottom)
            
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
                            isOn: $soundEffectsEnabled
                        )
                        
                        // Haptic Feedback Toggle
                        SettingsToggleRow(
                            icon: "iphone.radiowaves.left.and.right",
                            title: "Haptic Feedback",
                            subtitle: "Tactile responses",
                            isOn: $hapticFeedbackEnabled
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

// MARK: - Settings Toggle Row
struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: GameConstants.UISizing.iconSizeLarge))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ThemeColor.accentPrimary, ThemeColor.accentSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ThemeColor.accentPrimary.opacity(0.1))
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(ThemeColor.textPrimary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(ThemeColor.accentPrimary)
        }
        .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
        .padding(.vertical, 12)
        .background(ThemeColor.backgroundMenu)
        .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius)
                .stroke(ThemeColor.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Settings Option Button
struct SettingsOptionButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: GameConstants.UISizing.iconSizeLarge))
                    .foregroundStyle(
                        isSelected ? ThemeColor.accentPrimary : ThemeColor.textPrimary.opacity(0.5)
                    )
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                isSelected ?
                                ThemeColor.accentPrimary.opacity(0.15) :
                                ThemeColor.accentPrimary.opacity(0.05)
                            )
                    )
                
                Text(title)
                    .font(.headline)
                    .foregroundStyle(ThemeColor.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(ThemeColor.accentPrimary)
                }
            }
            .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
            .padding(.vertical, 12)
            .background(ThemeColor.backgroundMenu)
            .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius)
                    .stroke(
                        isSelected ? ThemeColor.accentPrimary : ThemeColor.border,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? ThemeColor.accentPrimary.opacity(0.2) : .black.opacity(0.03),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: 2
            )
        }
    }
}

// MARK: - Settings Difficulty Button
struct SettingsDifficultyButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: GameConstants.UISizing.iconSizeLarge))
                    .foregroundStyle(
                        isSelected ? ThemeColor.accentPrimary : ThemeColor.textPrimary.opacity(0.5)
                    )
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                isSelected ?
                                ThemeColor.accentPrimary.opacity(0.15) :
                                ThemeColor.accentPrimary.opacity(0.05)
                            )
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(ThemeColor.textPrimary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(ThemeColor.accentPrimary)
                }
            }
            .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
            .padding(.vertical, 12)
            .background(ThemeColor.backgroundMenu)
            .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius)
                    .stroke(
                        isSelected ? ThemeColor.accentPrimary : ThemeColor.border,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? ThemeColor.accentPrimary.opacity(0.2) : .black.opacity(0.03),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: 2
            )
        }
    }
}

// MARK: - Settings Row Button (for Navigation Links)
struct SettingsRowButton: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: GameConstants.UISizing.iconSizeLarge))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ThemeColor.accentPrimary, ThemeColor.accentSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ThemeColor.accentPrimary.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(ThemeColor.textPrimary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(ThemeColor.textPrimary.opacity(0.3))
        }
        .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
        .padding(.vertical, 12)
        .background(ThemeColor.backgroundMenu)
        .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius)
                .stroke(ThemeColor.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
