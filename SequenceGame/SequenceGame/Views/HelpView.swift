//
//  HelpView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 28/10/2025.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        ZStack {
            ThemeColor.backgroundMenu
                .ignoresSafeArea(edges: .bottom)
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ThemeColor.accentSecondary, ThemeColor.accentPrimary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("How to Play")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(ThemeColor.textPrimary)
                        
                        Text("Learn the game rules")
                            .font(.subheadline)
                            .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
                    }
                    .padding(.top, 20)
                    
                    // Quick Start Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Quick Start")
                        
                        InfoParagraph(
                            title: "Setup",
                            content: "Each player receives 7 cards. The board is laid out with playing cards. " +
                            "Players take turns placing chips on the board matching their cards."
                        )
                        
                        InfoParagraph(
                            title: "Objective",
                            content: "Be the first player (or team) to form TWO sequences of five chips. " +
                            "A sequence can be horizontal, vertical, or diagonal."
                        )
                    }
                    
                    // Detailed Rules Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Detailed Rules")
                        
                        InfoParagraph(
                            title: "Placing Chips",
                            content: "1. Select a card from your hand\n" +
                            "2. Look for that card on the game board\n" +
                            "3. Place your chip on the matching card on the board\n" +
                            "4. Discard the card you used"
                        )
                        
                        InfoParagraph(
                            title: "Special Cards (Jacks)",
                            content: "• Two-Eyed Jack: Place your chip on any open space on the board\n" +
                            "• One-Eyed Jack: Remove any opponent's chip from the board\n" +
                            "• You must still discard the jack after using it"
                        )
                        
                        InfoParagraph(
                            title: "Winning the Game",
                            content: "Complete TWO sequences of five chips to win. Sequences can be horizontal, " +
                            "vertical, or diagonal. Corner spaces count for both sequences if applicable."
                        )
                    }
                    
                    // Strategy Tips Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Strategy Tips")
                        
                        VStack(alignment: .leading, spacing: 12) {
                            TipCard(
                                icon: "hand.thumbsup.fill",
                                title: "Block Opponents",
                                content: "Watch for opponent sequences and block them strategically."
                            )
                            
                            TipCard(
                                icon: "eyes.fill",
                                title: "Multiple Options",
                                content: "Cards appear twice on the board - use this to your advantage."
                            )
                            
                            TipCard(
                                icon: "star.fill",
                                title: "Corner Spaces",
                                content: "Corner chips are wild and can be used by anyone."
                            )
                            
                            TipCard(
                                icon: "jacks.head.fill",
                                title: "Save Jacks",
                                content: "Use jacks wisely - they're powerful but limited!"
                            )
                        }
                    }
                    
                    // Links Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "More Information")
                        
                        CreditsLinkRow(
                            icon: "safari.fill",
                            title: "Official Game Rules",
                            subtitle: "Visit JAX Games official website",
                            iconColor: ThemeColor.accentPrimary,
                            action: {
                                if let url = URL(string: "https://www.jaxgames.com/") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                    }
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("Need more help?")
                            .font(.caption)
                            .foregroundStyle(ThemeColor.textPrimary.opacity(0.5))
                        Text("Visit the official website for complete rules")
                            .font(.caption2)
                            .foregroundStyle(ThemeColor.textPrimary.opacity(0.4))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        HelpView()
    }
}
