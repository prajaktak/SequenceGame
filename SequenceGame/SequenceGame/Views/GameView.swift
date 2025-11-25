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
    
    /// Flag to track if the view has finished initial setup
    /// Prevents onDisappear from triggering during initial setup
    @State private var hasFinishedSetup: Bool = false

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
    init(playersPerTeam: Int = 5, numberOfTeams: Int = 2, isResuming: Bool = false) {
        _playersPerTeam = State(initialValue: playersPerTeam)
        _numberOfTeams = State(initialValue: numberOfTeams)
        _isResuming = State(initialValue: isResuming)
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
                        .animation(.easeInOut(duration: GameConstants.Animation.cardSelectionDuration), value: gameState.hasSelection)
                    }
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
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .navigationTitle("Sequence Game")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
//            .onChange(of: gameState.boardTiles) { _, _ in
//                saveGame()
//            }
            .onChange(of: gameState.currentPlayerIndex) { _, _ in
                saveGame()
            }
            .onDisappear {
                print("🔴 GameView.onDisappear - hasFinishedSetup: \(hasFinishedSetup)")
                print("🔴 GameView.onDisappear - isResuming: \(isResuming)")
                print("🔴 GameView.onDisappear - currentPlayer: \(gameState.currentPlayer?.name ?? "nil")")
                print("🔴 GameView.onDisappear - overlayMode: \(gameState.overlayMode)")
                print("🔴 GameView.onDisappear - isOverlayPresent: \(isOverlayPresent)")
                
                // Only save if setup is complete (prevents saving during initial setup)
                if hasFinishedSetup {
                    print("🔴 GameView.onDisappear - Saving game")
                    saveGame()
                } else {
                    print("🔴 GameView.onDisappear - Skipping save (setup not complete)")
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background {
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
                    
                    // Dismiss GameView (back to GameSettingsView)
                    dismiss()
                })
                .environmentObject(gameState)
            }
            .onAppear {
                print("🔵 GameView.onAppear - isResuming: \(isResuming), hasFinishedSetup: \(hasFinishedSetup)")
                print("🔵 GameView.onAppear - currentPlayer: \(gameState.currentPlayer?.name ?? "nil")")
                print("🔵 GameView.onAppear - overlayMode: \(gameState.overlayMode)")
                print("🔵 GameView.onAppear - isOverlayPresent: \(isOverlayPresent)")
                
                if isResuming {
                    // Game is already loaded from ResumeGameView, do nothing
                    print("✅ Resuming saved game")
                    // Set overlay present if overlayMode is set (even if it doesn't change)
                    if gameState.overlayMode == .turnStart {
                        print("🔵 GameView.onAppear - Setting isOverlayPresent = true for resumed game (turnStart)")
                        isOverlayPresent = true
                    }
                    // Mark setup as complete immediately for resume
                    hasFinishedSetup = true
                } else {
                    // Starting a new game - delete any existing save and setup new game
                    print("✅ Setting new game")
                    GamePersistence.deleteSavedGame()
                    setupGame()
                    print("🔵 GameView.onAppear - After setupGame() - currentPlayer: \(gameState.currentPlayer?.name ?? "nil")")
                    print("🔵 GameView.onAppear - After setupGame() - overlayMode: \(gameState.overlayMode)")
                    // Set overlay present if overlayMode is .turnStart (even if it doesn't change)
                    if gameState.overlayMode == .turnStart {
                        print("🔵 GameView.onAppear - Setting isOverlayPresent = true for new game (turnStart)")
                        isOverlayPresent = true
                    }
                    // Mark setup as complete after a small delay to allow state updates to settle
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        print("🔵 GameView - Setting hasFinishedSetup = true")
                        hasFinishedSetup = true
                    }
                }
            }
            .onChange(of: gameState.overlayMode) { oldMode, newMode in
                print("🟡 GameView.onChange(overlayMode) - oldMode: \(oldMode), newMode: \(newMode)")
                print("🟡 GameView.onChange(overlayMode) - currentPlayer: \(gameState.currentPlayer?.name ?? "nil")")
                print("🟡 GameView.onChange(overlayMode) - isOverlayPresent before: \(isOverlayPresent)")
                
                if newMode == .gameOver {
                    isOverlayPresent = true
                    print("🟡 GameView.onChange(overlayMode) - Set isOverlayPresent = true (gameOver)")
                    saveGame()
                    // Don't auto-dismiss game over overlay
                    return
                }
                isOverlayPresent = true
                print("🟡 GameView.onChange(overlayMode) - Set isOverlayPresent = true")
                overlayDismissWork?.cancel()
                overlayDismissWork = nil
                if newMode != .deadCard {
                    let work = DispatchWorkItem { 
                        print("🟡 GameView - Auto-dismissing overlay")
                        isOverlayPresent = false 
                    }
                    overlayDismissWork = work
                    DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.Animation.overlayAutoDismissDelay, execute: work)
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
                        mode: gameState.overlayMode
                    )
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isOverlayPresent)
                    .transition(.scale.combined(with: .opacity))
                    .allowsHitTesting(gameState.overlayMode == .deadCard ||  gameState.overlayMode == .gameOver)
                    .overlay(content: {
                        if gameState.overlayMode == .deadCard {
                            Color.clear
                                .contentShape(Rectangle())
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .onTapGesture { gameState.replaceCurrentlySelectedDeadCard() }
                        } else if gameState.overlayMode == .gameOver {
                            // Add tap gesture to dismiss to main menu
                            Color.clear
                                .contentShape(Rectangle())
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .onTapGesture {
                                    // Pop to root (MainMenu) by dismissing twice
                                    // First dismiss GameView, then GameSettingsView
                                    dismiss()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.Animation.navigationDismissDelay) {
                                        dismiss()
                                    }
                                }
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
        print("🟢 GameView.setupGame() - Starting setup")
        print("🟢 GameView.setupGame() - Before startGame - overlayMode: \(gameState.overlayMode)")
        print("🟢 GameView.setupGame() - Before startGame - currentPlayer: \(gameState.currentPlayer?.name ?? "nil")")
        
        var localPlayers: [Player] = []
        var localTeams: [Team] = []
        
        let colorNames: [TeamColor] = GameConstants.teamColors
        
        // Build teams and players
        for teamIndex in 0..<numberOfTeams {
            localTeams.append(Team(color: colorNames[teamIndex], numberOfPlayers: playersPerTeam))
            for index in 0..<playersPerTeam {
                let displayIndex = index + 1
                let playerName = "T\(teamIndex + 1)-P\(displayIndex)"
                localPlayers.append(Player(name: playerName, team: localTeams[teamIndex], cards: []))
            }
        }
        
        // Interleave by team
        let teamOrder = localTeams.map { $0.id }
        localPlayers = SeatingRules.interleaveByTeams(localPlayers, teamOrder: teamOrder)
        
        print("🟢 GameView.setupGame() - About to call startGame with \(localPlayers.count) players")
        
        // Hand off to GameState (single source of truth)
        gameState.startGame(with: localPlayers)
        
        print("🟢 GameView.setupGame() - After startGame - overlayMode: \(gameState.overlayMode)")
        print("🟢 GameView.setupGame() - After startGame - currentPlayer: \(gameState.currentPlayer?.name ?? "nil")")
        print("🟢 GameView.setupGame() - After startGame - players.count: \(gameState.players.count)")
        
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
            // Log error but don't interrupt gameplay
            print("⚠️ Failed to save game: \(error.localizedDescription)")
        }
    }
}

#Preview {
    GameView()
        .environmentObject(GameState())
}
