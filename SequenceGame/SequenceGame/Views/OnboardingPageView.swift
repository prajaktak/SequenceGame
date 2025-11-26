//
//  OnboardingPageView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 26/11/2025.
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 24) {
            // Large icon
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ThemeColor.accentSecondary, ThemeColor.accentPrimary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.top, 60)
            
            // Title
            Text(page.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(ThemeColor.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Description
            Text(page.description)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(ThemeColor.textPrimary.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OnboardingPageView(page: OnboardingPage(icon: "gamecontroller.fill", title: "Welcome to Sequence!", description: "A strategic board game where you form sequences of five chips to win."))
        .background(
            LinearGradient(
                colors: [ThemeColor.backgroundMenu, ThemeColor.backgroundMenu.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
}
