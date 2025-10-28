//
//  CreditsView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
        ZStack {
            ThemeColor.backgroundMenu
                .ignoresSafeArea(edges: .bottom)
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ThemeColor.accentSecondary, ThemeColor.accentPrimary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("About")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(ThemeColor.textPrimary)
                        
                        Text("Sequence Card Game")
                            .font(.subheadline)
                            .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
                    }
                    .padding(.top, 20)
                    
                    // App Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "App Information")
                        
                        CreditsInfoCard(
                            icon: "app.badge",
                            title: "Version",
                            value: "1.0",
                            subtitle: "Initial Release"
                        )
                        
                        CreditsInfoCard(
                            icon: "person.fill",
                            title: "Developer",
                            value: "Prajakta Kulkarni",
                            subtitle: "iOS Developer"
                        )
                        
                        CreditsInfoCard(
                            icon: "gamecontroller.fill",
                            title: "Game Type",
                            value: "Strategy Card Game",
                            subtitle: "Board Game Adaptation"
                        )
                    }
                    
                    // Game Description Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "About the Game")
                        
                        VStack(alignment: .leading, spacing: 12) {
                            InfoParagraph(
                                title: "What is Sequence?",
                                content: "Sequence is a strategy board game for two or more players. " +
                                "Players compete to form rows of five chips on the board using their cards."
                            )
                            
                            InfoParagraph(
                                title: "How to Play",
                                content: "1. Each player gets 7 cards\n" +
                                "2. Players take turns placing chips\n" +
                                "3. Use Jacks as wild cards\n" +
                                "4. Form two sequences to win"
                            )
                        }
                    }
                    
                    // Links Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Resources")
                        
                        VStack(spacing: 12) {
                            NavigationLink(destination: AttributionsView()) {
                                CreditsLinkRow(
                                    icon: "doc.text.fill",
                                    title: "Attributions & Licenses",
                                    subtitle: "View open source credits",
                                    iconColor: ThemeColor.accentPrimary
                                )
                            }
                            
                            NavigationLink(destination: HelpView()) {
                                CreditsLinkRow(
                                    icon: "questionmark.circle.fill",
                                    title: "How to Play",
                                    subtitle: "View detailed game rules",
                                    iconColor: ThemeColor.accentSecondary
                                )
                            }
                            
                            CreditsLinkRow(
                                icon: "safari.fill",
                                title: "Official Rules",
                                subtitle: "Visit JAX Games website",
                                iconColor: ThemeColor.accentSecondary,
                                action: {
                                    if let url = URL(string: "https://www.jaxgames.com/") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            )
                        }
                    }
                    
                    // Technical Info Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Technical Details")
                        
                        VStack(spacing: 8) {
                            TechInfoRow(label: "Platform", value: "iOS")
                            TechInfoRow(label: "Framework", value: "SwiftUI")
                            TechInfoRow(label: "Language", value: "Swift")
                            TechInfoRow(label: "Minimum iOS", value: "18.0")
                        }
                    }
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("© 2025 Prajakta Kulkarni")
                            .font(.caption)
                            .foregroundStyle(ThemeColor.textPrimary.opacity(0.5))
                        Text("Built with ❤️ in Netherlands")
                            .font(.caption2)
                            .foregroundStyle(ThemeColor.textPrimary.opacity(0.4))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Credits")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
    }
}

// MARK: - Credits Info Card
struct CreditsInfoCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    
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
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(ThemeColor.accentPrimary.opacity(0.1))
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
                Text(value)
                    .font(.headline)
                    .foregroundStyle(ThemeColor.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(ThemeColor.textPrimary.opacity(0.6))
            }
            
            Spacer()
        }
        .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
        .padding(.vertical, 14)
        .background(ThemeColor.backgroundMenu)
        .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius)
                .stroke(ThemeColor.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Info Paragraph
struct InfoParagraph: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(ThemeColor.textPrimary)
            
            Text(content)
                .font(.subheadline)
                .foregroundStyle(ThemeColor.textPrimary.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ThemeColor.backgroundMenu)
        .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius)
                .stroke(ThemeColor.border, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Credits Link Row
struct CreditsLinkRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    var action: (() -> Void)?
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: GameConstants.UISizing.iconSizeLarge))
                    .foregroundStyle(iconColor)
                    .frame(width: 50, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(iconColor.opacity(0.1))
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
            .padding(.vertical, 14)
            .background(ThemeColor.backgroundMenu)
            .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GameConstants.UISizing.mediumCornerRadius)
                    .stroke(ThemeColor.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Tech Info Row
struct TechInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(ThemeColor.textPrimary)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, GameConstants.UISizing.horizontalPadding)
        .padding(.vertical, 10)
        .background(ThemeColor.backgroundMenu)
        .clipShape(RoundedRectangle(cornerRadius: GameConstants.UISizing.smallCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GameConstants.UISizing.smallCornerRadius)
                .stroke(ThemeColor.border, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationView {
        CreditsView()
    }
}
