//
//  GameView.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 06/11/2025.
//

import SwiftUI

/// The main game screen that displays the board, player hands, turn information, and game overlays.
///
/// `GameView` coordinates all visual elements of an active game session:
/// - Turn banner showing current player and team
/// - 10x10 game board with chip placements
/// - Seating ring overlay showing player positions
/// - Player's hand of cards at the bottom
/// - Game event overlays (turn start, card selection, dead card, game over)
///
/// This view relies on `GameState` as the single source of truth and derives all display data
/// from it via computed properties to maintain consistency as the game progresses.
struct GameView: View {
    // MARK: - Environment & State
    
    /// The authoritative game state containing all players, board state, and game logic.
    @EnvironmentObject var gameState: GameState
    
    /// Modern SwiftUI dismiss action for navigation (replaces deprecated presentationMode).
    @Environment(\.dismiss) var dismiss
    
    /// Number of players per team, set at initialization from game settings.
    @State private var playersPerTeam: Int
    
    /// Number of teams in the game, set at initialization from game settings.
    @State private var numberOfTeams: Int
    
    /// Controls visibility of game event overlays (turn start, dead card, game over).
    @State private var isOverlayPresent: Bool = false
    
    /// Work item for auto-dismissing temporary overlays; can be cancelled if overlay mode changes.
    @State private var overlayDismissWork: DispatchWorkItem?
    
    /// Controls visibility of the in-game menu sheet.
    @State private var showGameMenu: Bool = false
    
    /// Flag to track if this is a resumed game (true) or new game (false)
    @State private var isResuming: Bool = false
    
    /// Player configurations passed from settings
    private let playerConfigs: [String: PlayerConfig]?
    
    /// Flag to track if the view has finished initial setup
    /// Prevents onDisappear from triggering during initial setup
    @State private var hasFinishedSetup: Bool = false
    
    /// Timestamp when setup was completed, to prevent immediate saves
    @State private var setupCompletedAt: Date?
    @State private var isRestartingGame = false
    @State private var isNavigatingAway = false

    @Environment(\.scenePhase) var scenePhase
    
    // MARK: - Computed Properties
    
    /// Unique teams extracted from the current players in gameState.
    ///
    /// Derives team list dynamically to maintain single source of truth.
    /// Used for computing seating order and maintaining team consistency.
    private var teams: [Team] {
        var uniqueTeams: [Team] = []
        for player in gameState.players where uniqueTeams.contains(where: { $0.id == player.team.id }) {
                uniqueTeams.append(player.team)
        }
        return uniqueTeams
    }

    /// Seat positions around the board based on current player count.
    ///
    /// Computed dynamically from gameState to reflect any changes in player configuration.
    private var seats: [Seat] {
        SeatingLayout.computeSeats(for: gameState.players.count)
    }
    
    // MARK: - Initialization
    
    /// Creates a new game view with the specified player and team configuration.
    ///
    /// - Parameters:
    ///   - playersPerTeam: Number of players on each team (default: 5)
    ///   - numberOfTeams: Number of teams in the game (default: 2)
    ///   - isResuming: Whether this is resuming a saved game (default: false)
    ///   - playerConfigs: Optional configuration for players (AI/Human)
    init(playersPerTeam: Int = 5, numberOfTeams: Int = 2, isResuming: Bool = false, playerConfigs: [String: PlayerConfig]? = nil) {
        _playersPerTeam = State(initialValue: playersPerTeam)
        _numberOfTeams = State(initialValue: numberOfTeams)
        _isResuming = State(initialValue: isResuming)
        self.playerConfigs = playerConfigs
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 3) {
                // Turn Banner
                if let currentPlayer = gameState.currentPlayer {
                    let teamColor = ThemeColor.getTeamColor(for: currentPlayer.team.color)
                    TurnBannerView(
                        playerName: currentPlayer.name,
                        teamColor: teamColor
                    )
                } else {
                    Text("Setting up game...")
                        .padding()
                }
                // Game Board (expands to fill available space)
                if gameState.currentPlayer != nil {
                    let teamOrder = teams.map { $0.id }
                    let ordered = SeatingRules.interleaveByTeams(gameState.players, teamOrder: teamOrder)
                    let currentPlayerIndex = gameState.currentPlayerIndex
                    let anchoredPlayers: [Player] = (!ordered.isEmpty && currentPlayerIndex < ordered.count)
                        ? (Array(ordered[currentPlayerIndex...]) + Array(ordered[..<currentPlayerIndex]))
                        : ordered
                    
                    ZStack {
                        BoardView(currentPlayer: .constant(gameState.currentPlayer))
                        
                        SeatingRingOverlay(
                            seats: seats,
                            players: anchoredPlayers,
                            currentPlayerIndex: 0
                        )
                        .allowsHitTesting(false)
                        .opacity(gameState.hasSelection ? 0 : 1)
                        .animation(.easeInOut(duration: GameConstants.cardSelectionDuration), value: gameState.hasSelection)
                    }
                    .disabled(gameState.isAITurnInProgress)
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("gameBoardContainer")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("Loading board...")
                        .foregroundColor(.secondary)
                }
                // Player Hand (separate view)
                HandView()
                    .frame(height: 100)
                    .environmentObject(gameState)
                    .disabled(gameState.isAITurnInProgress)
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .accessibilityIdentifier("gameView")
            .navigationTitle("Sequence Game")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
//            .onChange(of: gameState.boardTiles) { _, _ in
//                saveGame()
//            }
            .onChange(of: gameState.currentPlayerIndex) { _, _ in
                // Don't save if game is over
                if gameState.overlayMode != .gameOver {
                    saveGame()
                }
            }
            .onDisappear {
                // Only save if setup is complete and game is not over
                // Also prevent saving immediately after setup completes (within 0.5 seconds) to avoid view refresh issues
                let timeSinceSetup = setupCompletedAt.map { Date().timeIntervalSince($0) } ?? 999
                if hasFinishedSetup && gameState.overlayMode != .gameOver && timeSinceSetup > 0.5 {
                    saveGame()
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background && gameState.overlayMode != .gameOver {
                    saveGame()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showGameMenu = true
                    }, label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(ThemeColor.accentPrimary)
                    })
                    .accessibilityIdentifier("menuButton")
                    .accessibilityLabel("Menu")
                    .accessibilityHint("Open game menu")
                }
            }
            .sheet(isPresented: $showGameMenu) {
                InGameMenuView(onNewGame: {
                    // Close the menu sheet first
                    showGameMenu = false
                    
                    // Reset game state
                    gameState.resetGame()
                    
                    // Dismiss GameView (back to GameSettingsView or MainMenu)
                    dismiss()
                })
                .environmentObject(gameState)
            }
            .onAppear {
                // If game is already set up (players exist), just ensure overlay is shown if needed
                // This handles the case where the view is recreated but the game state persists
                if !gameState.players.isEmpty && hasFinishedSetup {
                    if !isOverlayPresent && gameState.overlayMode == .turnStart {
                        isOverlayPresent = true
                    }
                    return
                }
                
                // If game is already set up but hasFinishedSetup is false (view recreated), mark it as complete
                if !gameState.players.isEmpty && !hasFinishedSetup {
                    if !isOverlayPresent && gameState.overlayMode == .turnStart {
                        isOverlayPresent = true
                    }
                    hasFinishedSetup = true
                    setupCompletedAt = Date()
                    return
                }
                
                if isResuming {
                    // Game is already loaded from ResumeGameView, do nothing
                    // Set overlay present if overlayMode is set
                    if gameState.overlayMode == .turnStart {
                        isOverlayPresent = true
                    }
                    // Mark setup as complete immediately for resume
                    hasFinishedSetup = true
                    setupCompletedAt = Date()
                } else {
                    // Starting a new game - delete any existing save and setup new game
                    GamePersistence.deleteSavedGame()
                    setupGame()
                    // Always show overlay on initial game start
                    // Set it immediately to avoid view recreation issues
                    if gameState.overlayMode == .turnStart {
                        isOverlayPresent = true
                    }
                    // Mark setup as complete after a small delay to allow state updates to settle
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        hasFinishedSetup = true
                        setupCompletedAt = Date()
                    }
                }
            }
            .onChange(of: gameState.overlayMode) { _, newMode in
                // Skip if we're navigating away (prevents overlay from briefly reappearing)
                guard !isNavigatingAway else {
                    return
                }

                // During initial setup, let onAppear handle overlay visibility to avoid race conditions
                // Only process overlay changes after setup is complete
                guard hasFinishedSetup else {
                    return
                }

                // CRITICAL: Cancel any pending auto-dismiss timers first (before any early returns)
                overlayDismissWork?.cancel()
                overlayDismissWork = nil

                if newMode == .gameOver {
                    isOverlayPresent = true
                    // Delete saved game since the game is finished
                    GamePersistence.deleteSavedGame()
                    // Don't auto-dismiss game over overlay
                    return
                }

                if newMode == .replayFinished {
                    isOverlayPresent = true
                    // Don't auto-dismiss replay finished overlay
                    return
                }

                isOverlayPresent = true
                if newMode != .deadCard {
                    let work = DispatchWorkItem {
                        isOverlayPresent = false
                    }
                    overlayDismissWork = work
                    DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.overlayAutoDismissDelay, execute: work)
                }
            }
            .overlay(content: {
                // Centered overlay for game events
                if isOverlayPresent, let activePlayer = gameState.currentPlayer {
                    let teamColor = ThemeColor.getTeamColor(for: activePlayer.team.color)
                    let teamOverlayBorderColor = ThemeColor.getTeamOverlayColor(for: teamColor)
                    let overlayBackgroundColor = teamColor
                    GameOverlayView(
                        playerName: activePlayer.name,
                        teamColor: teamColor,
                        borderColor: teamOverlayBorderColor,
                        backgroundColor: overlayBackgroundColor,
                        onHelp: { /* present help */ },
                        onClose: { isOverlayPresent = false },
                        onRestart: {
                            // Set flag FIRST to prevent tap gesture from firing
                            isRestartingGame = true
                            // Close overlay
                            isOverlayPresent = false
                            // Restart game after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
                                do {
                                    try gameState.restartGame()
                                    // Reset flag after restart completes
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                        isRestartingGame = false
                                    })
                                } catch {
                                    isRestartingGame = false
                                }
                            })
                        },
                        onNewGame: {
                            // Handle new game: close overlay first, then reset game state and navigate back
                            // Set flag to prevent onChange handler from showing overlay
                            isNavigatingAway = true
                            // Close overlay first to prevent it from briefly reappearing
                            isOverlayPresent = false
                            // Small delay to let overlay close, then reset and navigate
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                // Reset game state
                                gameState.resetGame()
                                // Dismiss GameView (back to GameSettingsView or MainMenu)
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.navigationDismissDelay, execute: {
                                    dismiss()
                                })
                            })
                        },
                        mode: gameState.overlayMode
                    )
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isOverlayPresent)
                    .transition(.scale.combined(with: .opacity))
                    .allowsHitTesting(gameState.overlayMode == .deadCard ||  gameState.overlayMode == .gameOver || gameState.overlayMode == .replayFinished)
                    .overlay(content: {
                        if gameState.overlayMode == .deadCard {
                            Color.clear
                                .contentShape(Rectangle())
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .onTapGesture { gameState.replaceCurrentlySelectedDeadCard() }
                        } else if gameState.overlayMode == .gameOver {
                            // Note: Game over overlay no longer has tap-to-dismiss
                            // Users must use the explicit "New Game" button to navigate away
                            // This prevents accidental dismissal when tapping "Play Again"
                            // The tap gesture is completely disabled for game over mode
                            Color.clear
                                .contentShape(Rectangle())
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .allowsHitTesting(false) // Completely disable tap gesture
                        }
                    })
                }
            })
        }
    }
    
    // MARK: - Setup
    
    /// Initializes a new game session with the configured teams and players.
    ///
    /// Creates teams and players based on `numberOfTeams` and `playersPerTeam`, assigns team colors
    /// from `GameConstants.teamColors`, interleaves players by team for fair turn order, and hands
    /// off the configured player list to `GameState` to start the game.
    ///
    /// - Note: After setup, all game data lives in `gameState`. This view derives `teams` and `seats`
    ///   dynamically via computed properties to maintain single source of truth.
    private func setupGame() {
        var localPlayers: [Player] = []
        var localTeams: [Team] = []
        
        let colorNames: [TeamColor] = GameConstants.teamColors
        
        // Build teams and players
        for teamIndex in 0..<numberOfTeams {
            localTeams.append(Team(color: colorNames[teamIndex], numberOfPlayers: playersPerTeam))
            for index in 0..<playersPerTeam {
                let displayIndex = index + 1
                let configKey = "T\(teamIndex + 1)-P\(displayIndex)"
                let config = playerConfigs?[configKey]
                
                let isAI = config?.isAI ?? false
                let difficulty = config?.difficulty
                
                let baseName = "T\(teamIndex + 1)-P\(displayIndex)"
                var player = Player(name: baseName, team: localTeams[teamIndex], cards: [])
                
                if isAI {
                    player.isAI = true
                    player.aiDifficulty = difficulty
                    player.name = "\(baseName) (AI)"
                }
                
                localPlayers.append(player)
            }
        }
        
        // Interleave by team
        let teamOrder = localTeams.map { $0.id }
        localPlayers = SeatingRules.interleaveByTeams(localPlayers, teamOrder: teamOrder)
        
        // Hand off to GameState (single source of truth)
        gameState.startGame(with: localPlayers)
        
        // Note: seats and teams are now computed properties derived from gameState
    }
    
    // MARK: - Persistence
    
    /// Saves the current game state to disk.
    ///
    /// Errors are logged but not shown to the user to avoid interrupting gameplay.
    private func saveGame() {
        do {
            try GamePersistence.saveGame(gameState)
        } catch {
            // Silently fail - don't interrupt gameplay
        }
    }
}

#Preview {
    GameView()
        .environmentObject(GameState())
}
