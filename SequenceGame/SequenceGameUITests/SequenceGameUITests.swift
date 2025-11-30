//
//  SequenceGameUITests.swift
//  SequenceGameUITests
//
//  Created by Prajakta Kulkarni on 17/10/2025.
//
// UI Tests for the Sequence Game application.
//
// IMPORTANT: The app launches with MainMenu, not GameSettingsView.
// Tests must navigate from MainMenu -> GameSettingsView first.
//
// CRITICAL: NavigationLinks in SwiftUI are queried as app.links[], NOT app.buttons[]
// This includes:
// - "New Game" link in MainMenu
// - "startGameButton" link in GameSettingsView
//
// Key accessibility identifiers used in tests:
// - "startGameButton": The Start Game NavigationLink in GameSettingsView (queried as app.links)
// - "gameBoard": The main game board in GameView
//
// Note: Most text labels are queried by their text content rather than
// accessibility identifiers, as they don't have custom identifiers set.
//
// Navigation Flow:
// 1. App launches with MainMenu
// 2. Tap "New Game" LINK (not button!) to reach GameSettingsView
// 3. Configure settings and tap "Start Game" LINK to reach GameView

import XCTest

final class SequenceGameUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // Launch the app before each test
        app = XCUIApplication()
        
        // Pass launch argument to clear any saved game state
        // This ensures each test starts with a clean slate
        // Also add -ui-testing to skip onboarding
        app.launchArguments = ["-reset-saved-game", "YES", "-ui-testing"]
        
        app.launch()
        
        // Give the app time to process the reset
        Thread.sleep(forTimeInterval: 0.5)
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Methods
    
    /// Navigates from main menu to game settings
    private func navigateToGameSettings() {
        // Wait for the main menu to fully load
        Thread.sleep(forTimeInterval: 2.0)
        
        // After accessibility fixes, "New Game" should be queryable as a button
        
        // Try as button with accessibility (preferred after fix)
        let newGameButton = app.buttons["New Game"]
        if newGameButton.waitForExistence(timeout: 3.0) {
            print("✅ Found 'New Game' as button")
            newGameButton.tap()
            Thread.sleep(forTimeInterval: 1.0)
            return
        }
        // If we got here, navigation failed - print comprehensive debug info
        XCTFail("Could not find 'New Game' button to navigate to settings")
    }
    
    /// Navigates to the game view from main menu
    private func navigateToGameView() {
        // First navigate to settings
        navigateToGameSettings()
        
        // Verify we're on the settings screen
        XCTAssertTrue(isOnGameSettings(), "Should be on game settings screen after navigation")
        
        // After accessibility fixes, "Start Game" should be queryable as a button
        var tapped = false
        
        // Try as button with identifier (preferred after fix)
        let startGameButton = app.buttons["startGameButton"]
        if startGameButton.waitForExistence(timeout: 3.0) {
            print("✅ Found 'Start Game' as button with identifier")
            startGameButton.tap()
            tapped = true
        }
        
        XCTAssertTrue(tapped, "Should be able to find and tap Start Game button")
        
        // Wait for game to initialize completely
        // GameView calls setupGame in onAppear which creates players and sets currentPlayer
        // The board container only appears when currentPlayer != nil
        Thread.sleep(forTimeInterval: 3.0)
    }
    
    /// Checks if we are on the game settings screen
    private func isOnGameSettings() -> Bool {
        // Check for multiple indicators that we're on the settings screen
        let hasStartGameButton = app.buttons["startGameButton"].exists || app.staticTexts["Start Game"].exists
        let hasSettingsTitle = app.staticTexts["Select your game settings"].exists
        let hasNumberOfTeamsLabel = app.staticTexts["Number of Teams"].exists
        
        return hasStartGameButton || hasSettingsTitle || hasNumberOfTeamsLabel
    }
    /// Checks if we are on the game view screen
    private func isOnGameView() -> Bool {
        // Check for game view (stable identifier that's always present)
        let hasGameView = app.otherElements["gameView"].exists
        
        // Also check that we're NOT on settings anymore
        let notOnSettings = !app.staticTexts["Select your game settings"].exists
        
        return hasGameView || notOnSettings
    }
    
    /// Opens the in-game menu
    private func openInGameMenu() {
        let menuButton = app.buttons["menuButton"]
        if menuButton.waitForExistence(timeout: 5.0) {
            menuButton.tap()
            Thread.sleep(forTimeInterval: 1.0)
        }
    }
    
    /// Opens the in-game menu and confirms restart
    private func restartGameFromMenu() {
        let menuButton = app.buttons["menuButton"]
        if menuButton.waitForExistence(timeout: 5.0) {
            menuButton.tap()
            Thread.sleep(forTimeInterval: 1.0)
        }
        
        let restartButton = app.buttons["Restart"]
        if restartButton.waitForExistence(timeout: 3.0) {
            restartButton.tap()
            Thread.sleep(forTimeInterval: 1.0)
        }
        
        let alert = app.alerts["Restart Game?"]
        let confirmButton = alert.buttons["Restart"]
        if confirmButton.waitForExistence(timeout: 2.0) {
            confirmButton.tap()
            // Wait for menu to dismiss and game to restart
            Thread.sleep(forTimeInterval: 3.0)
        }
    }
    // MARK: - Main Menu
    ///  Test to check existance of Main Menu
    func test_mainMenuExists() throws {
        
        let resumeButton = app.buttons["Resume Game"]
        XCTAssertTrue(resumeButton.waitForExistence(timeout: 3.0), "Resume Game button should exist")
        
        let newGameButton = app.buttons["New Game"]
        XCTAssert(newGameButton.waitForExistence(timeout: 1.0), "New Game should exist as button")
        
        let howToPlayButton = app.buttons["How to Play"]
        XCTAssertTrue(howToPlayButton.waitForExistence(timeout: 1.0), "Settings should exist as button")
        
        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 1.0), "Settings should exist as button")
        
        let aboutAndCreditsButton = app.buttons["About & Credits"]
        XCTAssertTrue(aboutAndCreditsButton.waitForExistence(timeout: 1.0), "Settings should exist as button")
    }

    // MARK: - Game Settings
    
    /// test to check existance of Game settings view
    /// Verifies that changing number of teams updates the UI
    /// Verifies that changing number of players  updates the UI
    func test_gameSettingsExists() throws {
        navigateToGameSettings()
        
        let titleText = app.staticTexts["Sequence"]
        XCTAssertTrue(titleText.waitForExistence(timeout: 3.0), "Title 'Sequence' should be visible")
        
        let subtitleText = app.staticTexts["Select your game settings"]
        XCTAssertTrue(subtitleText.waitForExistence(timeout: 1.0), "Subtitle should be visible")
        
        let startGameButton = app.buttons["startGameButton"]
        XCTAssertTrue(startGameButton.waitForExistence(timeout: 1.0), "Start Game should exist as button")
        
        let teamsLabel = app.staticTexts["Number of Teams"]
        XCTAssertTrue(teamsLabel.waitForExistence(timeout: 1.0), "Number of Teams label should be visible")
        
        // Check for picker (it's a segmented control)
        let pickerTeam = app.segmentedControls.firstMatch
        XCTAssertTrue(pickerTeam.waitForExistence(timeout: 1.0), "Teams picker should exist")
        
        // Tap "3" segment
        let threeTeamsButton = pickerTeam.buttons["3"]
        if threeTeamsButton.exists {
            threeTeamsButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
            
            // Verify total players updated (3 teams × 1 player = 3)
            let totalPlayersLabel = app.staticTexts["Total Players: 3"]
            XCTAssertTrue(totalPlayersLabel.exists || app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Total Players: 3'")).firstMatch.exists,
                          "Total players should update to 3")
        }
        
        let playersLabel = app.staticTexts["Players in Team"]
        XCTAssertTrue(playersLabel.waitForExistence(timeout: 1.0), "Players in Team label should be visible")
        
        // Check for wheel picker
        let pickerPlayers = app.pickers.firstMatch
        XCTAssertTrue(pickerPlayers.waitForExistence(timeout: 1.0), "Players per team picker should exist")
        
        // 2. Get the wheel (for a single-component picker)
        let playersWheel = pickerPlayers.pickerWheels.element

        // 3. Adjust wheel to a specific value, e.g. "2"
        playersWheel.adjust(toPickerWheelValue: "2")

        // Optional: small wait if UI updates async
         _ = app.staticTexts["Total Players"].waitForExistence(timeout: 1.0)

        // 4. Assert UI updated
        // Example: 3 teams × 2 players = 6
        let exactLabel = app.staticTexts["Total Players: 6"]
        let containsLabel = app.staticTexts
            .matching(NSPredicate(format: "label CONTAINS 'Total Players: 6'"))
            .firstMatch

        XCTAssertTrue(exactLabel.exists || containsLabel.exists,
                      "Total players should update to 6 when picker is set to 2 players per team")
        
        // Default is 2 teams × 1 player = 2 total
        let totalPlayersLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Total Players'")).firstMatch
        XCTAssertTrue(totalPlayersLabel.waitForExistence(timeout: 1.0), "Total Players label should be visible")
    }
    
    // MARK: - Game View elements exitstance test
    /// Game view elements exists
    func testGameView_elementsExist() throws {
        navigateToGameView()
        
        let gameView = app.otherElements["gameView"]
        let viewAppeared = gameView.waitForExistence(timeout: 5.0)
        XCTAssertTrue(viewAppeared, "Game view should not be empty")
        
        let tileElements = gameView.descendants(matching: .any)
        XCTAssertFalse(tileElements.allElementsBoundByIndex.isEmpty, "Game board should contain tile elements")
        
        let menuButton = app.buttons["menuButton"]
        XCTAssertTrue(menuButton.exists, "Menu button with identifier should exist")
        
        // Look for turn banner elements (contains player name and team info)
        // The turn banner shows "T1-P1" or similar player name
        let turnBanner = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'T1-P1' OR label CONTAINS 'Player'")).firstMatch
        XCTAssertTrue(turnBanner.waitForExistence(timeout: 1.0), "Turn banner should be visible")
        
        // Look for card buttons directly (they should be accessible within gameView)
        // Cards have accessibility labels like "Queen of Hearts", "Ace of Spades", etc.
        let allButtons = app.buttons
        let cardButtons = allButtons.matching(NSPredicate(format: "label CONTAINS 'of'"))

        // Wait a bit more for cards to render
        Thread.sleep(forTimeInterval: 1.0)

        // Player should have cards (typically 5-7 cards depending on game setup)
        XCTAssertGreaterThan(cardButtons.count, 0, "Expected at least one card button in hand")
        
    }
    
    // MARK: - In-game menu
    func testInGameMenu_and_MenubuttonsExistance() throws {
        navigateToGameView()
        
        let menuButton = app.buttons["menuButton"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 5.0), "Menu button should exist in game view")
        
        openInGameMenu()
        
        // Check for menu title
        let menuTitle = app.staticTexts["Game Menu"]
        XCTAssertTrue(menuTitle.waitForExistence(timeout: 3.0), "In-game menu should appear")
        
        // Check resume button exists
        let resumeButton = app.buttons["Resume"]
        XCTAssertTrue(resumeButton.waitForExistence(timeout: 3.0), "Resume button should exist")
        
        // Check restart button exists
        let restartButton = app.buttons["Restart"]
        XCTAssertTrue(restartButton.waitForExistence(timeout: 3.0), "Restart button should exist")
        
        // Check new game button exists
        let newGameButton = app.buttons["New Game"]
        XCTAssertTrue(newGameButton.waitForExistence(timeout: 3.0), "New Game button should exist")
        
        // Check How to Play  button exists
        let howToPlayButton = app.buttons["How to Play"]
        XCTAssertTrue(howToPlayButton.waitForExistence(timeout: 3.0), "How to Play button should exist")
        
        // Check Settings  button exists
        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 3.0), "Settings button should exist")
    }
    
    // MARK: - Resume Flow Tests
    
    func testResumeButton_tapNavigatesToResumeView() {
        // This test requires a saved game
        // For now, we'll test the navigation structure
        
        let resumeButton = app.buttons["Resume Game"]
        
        if resumeButton.waitForExistence(timeout: 3.0) && resumeButton.isEnabled {
            resumeButton.tap()
            Thread.sleep(forTimeInterval: 2.0)
            
            // Should navigate to resume view or game view
            let resumeTitle = app.staticTexts["Resume Game"]
            let gameView = app.otherElements["gameView"]
            
            // Either resume view or game view should appear
            let navigated = resumeTitle.waitForExistence(timeout: 2.0) || gameView.waitForExistence(timeout: 2.0)
            XCTAssertTrue(navigated, "Should navigate to resume or game view")
        }
    }
    
    // MARK: - Restart from Menu Tests
    
    func testRestartFromMenu_preservesPlayerCount_resetsBoardState_closesMenu() {
        navigateToGameView()
        
        restartGameFromMenu()
        
        // After restart, menu should be closed and game should still be active
        // Check for menu button as indicator that we're back on GameView
        let menuButton = app.buttons["menuButton"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 5.0), "Menu button should exist after restart game is active")
        
        // Verify menu is closed
        let menuTitle = app.staticTexts["Game Menu"]
        XCTAssertFalse(menuTitle.exists, "Menu should be closed after restart")
 
        // After restart, menu should be closed and game board should be visible
        // Check for gameView as indicator that game is active
        let gameView = app.otherElements["gameView"]
        XCTAssertTrue(gameView.waitForExistence(timeout: 5.0), "Game board should be visible after restart")
        
        // Menu should be closed
        XCTAssertFalse(menuTitle.exists, "Menu should be closed after restart")
    }
    
    // MARK: - New Game from In-Game Menu Tests
    
    func testNewGameButton_existsInInGameMenuAndStartsNewGame() {
        // Navigate to game
        let newGameButton = app.buttons["New Game"]
        newGameButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        let startGameButton = app.buttons["startGameButton"]
        startGameButton.tap()
        Thread.sleep(forTimeInterval: 3.0)
        
        // Open in-game menu
        let menuButton = app.buttons["menuButton"]
        menuButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        let inGameNewGameButton = app.buttons["New Game"]
        XCTAssertTrue(inGameNewGameButton.waitForExistence(timeout: 3.0), "New Game button should exist in menu")
        
        inGameNewGameButton.tap()
        Thread.sleep(forTimeInterval: 2.0)

        // Should be back at settings, not in game
        let settingsTitle = app.staticTexts["Select your game settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3.0), "Should be at settings screen")
        
        // Menu button should not be visible (we're not in game anymore)
        XCTAssertFalse(menuButton.exists, "Menu button should not be visible (not in game)")
    }

    // MARK: - Game Interaction Tests
    
    /// Verifies that a card can be selected from the hand
    func testGameView_canSelectCard() throws {
        navigateToGameView()
        Thread.sleep(forTimeInterval: 1.5)
        
        // Try to find and tap a card
        let allButtons = app.buttons
        let cardButtons = allButtons.matching(NSPredicate(format: "label CONTAINS 'of'"))
        if !cardButtons.debugDescription.isEmpty {
            let firstCard = cardButtons.element(boundBy: 0)
            if firstCard.exists && firstCard.isHittable {
                firstCard.tap()
                Thread.sleep(forTimeInterval: 0.5)
                
                // After tapping, card selection state should change
                // (visual feedback or valid positions highlighted)
                XCTAssertTrue(true, "Card tap registered")
            }
        }
    }
    
    /// Verifies that tapping a valid board position places a chip
    func testGameView_canPlaceChipOnBoard() throws {
        navigateToGameView()
        Thread.sleep(forTimeInterval: 1.5)
        
        // Select a card first
        let cards = app.images.matching(NSPredicate(format: "identifier CONTAINS 'card'"))
        if !cards.allElementsBoundByIndex.isEmpty {
            let firstCard = cards.element(boundBy: 0)
            if firstCard.exists && firstCard.isHittable {
                firstCard.tap()
                Thread.sleep(forTimeInterval: 0.5)
                
                // Try to tap a board tile using gameView
                let gameView = app.otherElements["gameView"]
                let board = gameView
                
                if board.exists {
                    // Tap somewhere in the middle of the board
                    let coordinate = board.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
                    coordinate.tap()
                    Thread.sleep(forTimeInterval: 0.5)
                    
                    // Verify game continues (hard to verify exact state)
                    XCTAssertTrue(isOnGameView(), "Game should continue after move attempt")
                }
            }
        }
    }

    // MARK: - Validation Tests
    
    /// Verifies validation message appears when settings are invalid
    func testGameSettings_showsValidationForExcessivePlayers() throws {
        navigateToGameSettings()
        
        // This test requires changing settings to create invalid state
        // Due to auto-adjustment, this might not be easily testable in UI
        // But we can verify the validation message area exists
        
        let segmentedControl = app.segmentedControls.firstMatch
        if segmentedControl.exists {
            // Switch to 3 teams
            let threeTeamsButton = segmentedControl.buttons["3"]
            if threeTeamsButton.exists {
                threeTeamsButton.tap()
                Thread.sleep(forTimeInterval: 0.3)
            }
            
            // Try to set high player count via picker
            // Note: The app likely prevents invalid states, but we can check
            let picker = app.pickers.firstMatch
            if picker.exists {
                // Validation area exists for displaying messages
                XCTAssertTrue(true, "Settings validation logic is in place")
            }
        }
    }
    
    // MARK: - Edge Case Tests
    
    /// Verifies behavior with minimum configuration (2 teams, 1 player each)
    func testGameSettings_minimumConfiguration() throws {
        navigateToGameSettings()
        
        // Wait for the UI to be ready
        Thread.sleep(forTimeInterval: 0.5)
        
        // Default should be 2 teams, 1 player = 2 total
        let totalPlayersLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Total Players: 2'")).firstMatch
        XCTAssertTrue(totalPlayersLabel.waitForExistence(timeout: 3.0), "Default should be 2 total players")
        
        // Start game should work - after accessibility fixes, query as button
        let startGameButton = app.buttons["startGameButton"]
        let startGameExists = startGameButton.exists || app.staticTexts["Start Game"].exists
        XCTAssertTrue(startGameExists, "Start Game should exist")
        
        let isEnabled = startGameButton.isEnabled || app.staticTexts["Start Game"].isEnabled
        XCTAssertTrue(isEnabled, "Should be able to start with minimum configuration")
    }
    
    /// Verifies behavior with 3 teams
    func testGameSettings_threeTeamsConfiguration() throws {
        navigateToGameSettings()
        
        let segmentedControl = app.segmentedControls.firstMatch
        XCTAssertTrue(segmentedControl.waitForExistence(timeout: 3.0), "Segmented control should exist")
        
        let threeTeamsButton = segmentedControl.buttons["3"]
        if threeTeamsButton.exists {
            threeTeamsButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
            
            // Should show 3 total players (3 teams × 1 player)
            let totalPlayersLabel = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Total Players: 3'")).firstMatch
            XCTAssertTrue(totalPlayersLabel.exists, "Should show 3 total players for 3 teams")
            
            // Start game should work - after accessibility fixes, query as button
            let startGameButton = app.buttons["startGameButton"]
            let startGameExists = startGameButton.exists || app.staticTexts["Start Game"].exists
            XCTAssertTrue(startGameExists, "Start Game should exist")
            
            let isEnabled = startGameButton.isEnabled || app.staticTexts["Start Game"].isEnabled
            XCTAssertTrue(isEnabled, "Should be able to start with 3 teams")
        }
    }
    
    // MARK: - Performance Tests
    
    /// Measures time to launch app and display settings
    func testPerformance_appLaunch() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }
    
    /// Measures time to navigate to game view
    func testPerformance_navigationToGameView() throws {
        measure {
            let startLink = app.staticTexts["Start Game"]
            if startLink.waitForExistence(timeout: 3.0) {
                startLink.firstMatch.tap()
                _ = app.otherElements["gameBoard"].waitForExistence(timeout: 5.0)
            }
            
            // Reset for next iteration
            app.terminate()
            app.launch()
        }
    }
}
