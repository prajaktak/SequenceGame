//
//  OnboardingView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 26/11/2025.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("isOnboardingCompleted") var isOnboardingCompleted = false
    
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    
    @State private var pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "gamecontroller.fill",
            title: "Welcome to Sequence!",
            description: "A strategic board game where you form sequences of five chips to win."
        ),
        OnboardingPage(
            icon: "trophy.fill",
            title: "Your Objective",
            description: "Be the first team to complete TWO sequences of five chips. Sequences can be horizontal, vertical, or diagonal."
        ),
        OnboardingPage(
            icon: "hand.tap.fill",
            title: "How to Play",
            description: "1. Select a card from your hand\n2. Place your chip on the matching card on the board\n3. Draw a new card"
        ),
        OnboardingPage(
            icon: "jacks.head.fill",
            title: "Special Cards",
            description: "Two-Eyed Jack: Place chip anywhere\nOne-Eyed Jack: Remove opponent's chip"
        ),
        OnboardingPage(
            icon: "square.fill",
            title: "Corner Tiles",
            description: "The four corner spaces are wild! They can be used by anyone and count toward any sequence."
        ),
        OnboardingPage(
            icon: "play.circle.fill",
            title: "Ready to Play!",
            description: "Start your first game and have fun!"
        )]
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                OnboardingPageView(page: page)
                    .tag(index)
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page)
        .background(
            LinearGradient(
                colors: [ThemeColor.backgroundMenu, ThemeColor.backgroundMenu.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .overlay(
            VStack {
                // Skip button at top-right
                HStack {
                    Spacer()
                    Button(action: {
                        isOnboardingCompleted = true
                        dismiss()
                    }, label: {
                        Text("Skip")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(ThemeColor.textPrimary.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    })
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                }
                
                Spacer()
                
                // Bottom button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        // Not last page - go to next page
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        // Last page - complete onboarding
                        isOnboardingCompleted = true
                        dismiss()
                    }
                }, label: {
                    HStack {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(ThemeColor.textOnAccent)
                        
                        if currentPage < pages.count - 1 {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(ThemeColor.textOnAccent)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [ThemeColor.accentPrimary, ThemeColor.accentSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: GameConstants.buttonCornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: GameConstants.buttonCornerRadius)
                            .stroke(ThemeColor.border, lineWidth: GameConstants.universalBorderWidth)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                })
                .padding(.horizontal, GameConstants.horizontalPadding)
                .padding(.bottom, 40)
            }
        )
    }
}

#Preview {
    OnboardingView()
}
