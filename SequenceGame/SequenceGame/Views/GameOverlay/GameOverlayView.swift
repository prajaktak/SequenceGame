//
//  GameOverviewOverlay.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 25/10/2025.
//

import SwiftUI

struct GameOverlayView: View {
    @EnvironmentObject var gameState: GameState
    let playerName: String
    let teamColor: Color
    let borderColor: Color
    let backgroundColor: Color
    var onHelp: () -> Void = {}
    var onClose: () -> Void = {}
    var onRestart: (() -> Void)?
    var onNewGame: (() -> Void)?
    @State private var shimmerOffset: CGFloat = -60
    @State private var textWidth: CGFloat = 160
    let mode: GameOverlayMode
    
    var body: some View {
        switch mode {
        case .turnStart:
            VStack(spacing: GameConstants.UISizing.overlayContentSpacing) {
                HexagonOverlay(
                    borderColor: borderColor,
                    backgroundColor: backgroundColor
                ) {
                    // Content will go here in next step
                    VStack(spacing: GameConstants.UISizing.overlayContentSpacing) {
                        // Player name + "Your turn"
                        ShimmeringNameView(
                            name: playerName,
                            baseColor: ThemeColor.textOnAccent,
                            highlightColor: borderColor
                        )
                        // Instruction text
                        Text("Select card to place chip")
                            .font(.system(size: GameConstants.UISizing.overlayInstructionFontSize, weight: .semibold, design: .rounded))
                            .foregroundColor(ThemeColor.textOnAccent.opacity(0.7))
                        
                        // Help button (icon only)
                        Button(action: onHelp) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: GameConstants.UISizing.overlayHelpIconSize, weight: .bold))
                                .foregroundColor(borderColor)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        case .cardSelected:
            HexagonOverlay(
                borderColor: borderColor,
                backgroundColor: backgroundColor
            ) {
                VStack(spacing: GameConstants.UISizing.overlayContentSpacing) {
                    ShimmeringNameView(
                        name: playerName,
                        baseColor: ThemeColor.textOnAccent,
                        highlightColor: borderColor
                    )
                    CardSelectedOverlayContent(teamColor: borderColor)
                }
            }
            
        case .deadCard:
            HexagonOverlay(
                borderColor: borderColor,
                backgroundColor: backgroundColor
            ) {
                VStack(spacing: GameConstants.UISizing.overlayContentSpacing) {
                    ShimmeringNameView(
                        name: playerName,
                        baseColor: ThemeColor.textOnAccent,
                        highlightColor: borderColor
                    )
                    DeadCardOverlayContent(teamColor: borderColor)
                }
            }
        case .postPlacement:
            HexagonOverlay(
                borderColor: borderColor,
                backgroundColor: backgroundColor
            ) {
                VStack(spacing: GameConstants.UISizing.overlayContentSpacing) {
                    ShimmeringNameView(
                        name: playerName,
                        baseColor: ThemeColor.textOnAccent,
                        highlightColor: borderColor
                    )
                    PostPlacementOverlayContent(teamColor: borderColor)
                }
            }
        case .jackPlaceAnywhere:
            HexagonOverlay(
                borderColor: borderColor,
                backgroundColor: backgroundColor
            ) {
                VStack(spacing: GameConstants.UISizing.overlayContentSpacing) {
                    ShimmeringNameView(
                        name: playerName,
                        baseColor: ThemeColor.textOnAccent,
                        highlightColor: borderColor
                    )
                    TwoEyedJackOverlayContent(teamColor: borderColor)
                }
            }
        case .jackRemoveChip:
            HexagonOverlay(
                borderColor: borderColor,
                backgroundColor: backgroundColor
            ) {
                VStack(spacing: GameConstants.UISizing.overlayContentSpacing) {
                    ShimmeringNameView(
                        name: playerName,
                        baseColor: ThemeColor.textOnAccent,
                        highlightColor: borderColor
                    )
                    OneEyedJackOverlayContent(teamColor: borderColor)
                }
            }
        case .paused:
            HexagonOverlay(
                borderColor: borderColor,
                backgroundColor: backgroundColor
            ) {
                VStack(spacing: GameConstants.UISizing.overlayContentSpacing) {
                    ShimmeringNameView(
                        name: playerName,
                        baseColor: ThemeColor.textOnAccent,
                        highlightColor: borderColor
                    )
                    PausedOverlayContent(teamColor: borderColor)
                }
            }
        case .gameOver:
            HexagonOverlay(
                borderColor: borderColor,
                backgroundColor: backgroundColor,
                allowsHitTesting: true,
                content: {
                    VStack(spacing: GameConstants.UISizing.overlayGameOverSpacing) {
                        // Title
                        Text("Game Over!")
                            .font(.system(size: GameConstants.UISizing.overlayGameOverTitleSize, weight: .bold, design: .rounded))
                            .foregroundColor(ThemeColor.textOnAccent)
                        
                        // Winner announcement
                        if let winningTeam = gameState.winningTeam {
                            Text("\(teamName(for: winningTeam)) Wins!")
                                .font(.system(size: GameConstants.UISizing.overlayGameOverSubtitleSize, weight: .semibold, design: .rounded))
                                .foregroundColor(ThemeColor.textOnAccent)
                        }
                        
                        // Buttons - wrapped in container that consumes taps
                        HStack(spacing: GameConstants.UISizing.handSpacing) {
                            // Play Again Button
                            Button(action: {
                                // Use callback if provided, otherwise handle directly
                                if let onRestart = onRestart {
                                    onRestart()
                                } else {
                                    // Fallback: Close overlay and restart
                                    onClose()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        do {
                                            try gameState.restartGame()
                                        } catch {
                                            // Silently fail
                                        }
                                    }
                                }
                            },
                                   label: {
                                HStack(spacing: GameConstants.UISizing.iconSizeSmall / 4) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: GameConstants.UISizing.iconSizeSmall))
                                    Text("Play Again")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, GameConstants.UISizing.handVerticalInsets)
                                .padding(.horizontal, GameConstants.UISizing.handSpacing)
                                .background(Color.white.opacity(0.25))
                                .foregroundColor(.white)
                                .cornerRadius(GameConstants.UISizing.cardCornerRadius)
                            })
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                            
                            // New Game Button
                            Button(action: {
                                // Use callback if provided, otherwise just close overlay
                                if let onNewGame = onNewGame {
                                    onNewGame()
                                } else {
                                    onClose()
                                }
                            },
                                   label: {
                                HStack(spacing: GameConstants.UISizing.iconSizeSmall / 4) {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: GameConstants.UISizing.iconSizeSmall))
                                    Text("New Game")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, GameConstants.UISizing.handVerticalInsets)
                                .padding(.horizontal, GameConstants.UISizing.handSpacing)
                                .background(Color.white.opacity(0.25))
                                .foregroundColor(ThemeColor.textOnAccent)
                                .cornerRadius(GameConstants.UISizing.cardCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: GameConstants.UISizing.cardCornerRadius)
                                        .stroke(ThemeColor.textOnAccent.opacity(0.4), lineWidth: GameConstants.UISizing.standardBorderWidth)
                                )
                            })
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, GameConstants.UISizing.boardPadding)
                        .padding(.top, GameConstants.UISizing.iconSizeSmall / 4)
                        .contentShape(Rectangle())
                        .onTapGesture { } // Consume taps on button area to prevent propagation
                    }
                }
            )
        case .aITurnInProgress:
            HexagonOverlay(
                borderColor: borderColor, backgroundColor: backgroundColor) {
                    VStack(spacing: GameConstants.UISizing.overlayContentSpacing) {
                        AITurnInProgressOverlay(teamColor: borderColor, text: "\(playerName) is thinking...")
                    }
                }
            
        }
    }
    private func teamName(for color: TeamColor) -> String {
        if color == TeamColor.blue { return "Blue Team" }
        if color == TeamColor.green { return "Green Team" }
        if color == TeamColor.red { return "Red Team" }
        return "Team"
    }
}

#Preview("GameOverlayView – Turn Start") {
    GameOverlayView(
        playerName: "Prajakta",
        teamColor: ThemeColor.teamGreen,
        borderColor: ThemeColor.overlayTeamGreen,
        backgroundColor: ThemeColor.accentPrimary,
        onHelp: {},
        onClose: {},
        mode: .turnStart
    )
    .padding(20)
    .background(ThemeColor.backgroundGame)
}
#Preview("GameOverlayView – Card Selected") {
    GameOverlayView(
        playerName: "Prajakta",
        teamColor: ThemeColor.teamRed,
        borderColor: ThemeColor.overlayTeamRed,
        backgroundColor: ThemeColor.accentTertiary,
        onHelp: {},
        mode: .cardSelected
    )
    .padding(20)
    .background(ThemeColor.backgroundGame)
}
#Preview("GameOverlayView – Dead Card") {
    GameOverlayView(
        playerName: "Prajakta",
        teamColor: ThemeColor.teamBlue,
        borderColor: ThemeColor.overlayTeamBlue,
        backgroundColor: ThemeColor.accentSecondary,
        onHelp: {},
        mode: .deadCard
    )
    .padding(20)
    .background(ThemeColor.backgroundGame)
}
