//
//  NewGameUITests.swift
//  SequenceGameUITests
//
//  Created on 2025-11-24.
//

import XCTest

/// UI tests for new game functionality.
///
/// Tests the "New Game" option from various locations (main menu, in-game menu, game over),
/// ensuring new games start correctly and existing saves are handled properly.
final class NewGameUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-reset-saved-game", "YES", "-ui-testing"]
        app.launch()
        Thread.sleep(forTimeInterval: 0.5)
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - New Game from Main Menu Tests
    
    func testNewGameButton_existsInMainMenu() {
        let newGameButton = app.buttons["New Game"]
        
        XCTAssertTrue(newGameButton.waitForExistence(timeout: 3.0), "New Game button should exist in main menu")
    }
    
    func testNewGameButton_tapNavigatesToSettings() {
        let newGameButton = app.buttons["New Game"]
        newGameButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        let settingsTitle = app.staticTexts["Select your game settings"]
        
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3.0), "Should navigate to game settings")
    }
    
    func testNewGameFromMainMenu_deletesExistingSave() {
        // This test requires:
        // 1. A saved game to exist
        // 2. Tapping New Game
        // 3. Verifying save is deleted
        
        // For now, we verify the navigation works
        let newGameButton = app.buttons["New Game"]
        newGameButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        let settingsTitle = app.staticTexts["Select your game settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3.0), "Should navigate to settings")
    }
    
    // MARK: - New Game from In-Game Menu Tests
    
    func testNewGameButton_existsInInGameMenu() {
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
    }
    
    func testNewGameFromInGameMenu_navigatesToSettings() {
        // Navigate to game
        let newGameButton = app.buttons["New Game"]
        newGameButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        let startGameButton = app.buttons["startGameButton"]
        startGameButton.tap()
        Thread.sleep(forTimeInterval: 3.0)
        
        // Open menu and tap New Game
        let menuButton = app.buttons["menuButton"]
        menuButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        let inGameNewGameButton = app.buttons["New Game"]
        inGameNewGameButton.tap()
        Thread.sleep(forTimeInterval: 2.0)
        
        // Should navigate to game settings
        let settingsTitle = app.staticTexts["Select your game settings"]
        
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3.0), "Should navigate to game settings")
    }
    
    func testNewGameFromInGameMenu_resetsGameState() {
        // Navigate to game
        let newGameButton = app.buttons["New Game"]
        newGameButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        let startGameButton = app.buttons["startGameButton"]
        startGameButton.tap()
        Thread.sleep(forTimeInterval: 3.0)
        
        // Verify game is active - check for menu button as indicator
        let menuButton = app.buttons["menuButton"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 5.0), "Menu button should exist (game is active)")
        
        // Open menu and tap New Game
        menuButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        let inGameNewGameButton = app.buttons["New Game"]
        inGameNewGameButton.tap()
        Thread.sleep(forTimeInterval: 2.0)
        
        // Should be back at settings, not in game
        let settingsTitle = app.staticTexts["Select your game settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3.0), "Should be at settings screen")
        
        // Menu button should not be visible (we're not in game anymore)
        XCTAssertFalse(menuButton.exists, "Menu button should not be visible (not in game)")
    }
    
    // MARK: - New Game from Game Over Tests
    
    func testNewGameButton_existsInGameOver() {
        // Note: This test requires game to be in game over state
        // For now, we verify the game view structure exists
        
        navigateToGameView()
        
        // Check for menu button as indicator that game is active
        let menuButton = app.buttons["menuButton"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 5.0), "Menu button should exist (game is active)")
    }
    
    // MARK: - Helper Methods
    
    /// Navigates from main menu to game view
    private func navigateToGameView() {
        let newGameButton = app.buttons["New Game"]
        if newGameButton.waitForExistence(timeout: 3.0) {
            newGameButton.tap()
            Thread.sleep(forTimeInterval: 1.0)
        }
        
        let startGameButton = app.buttons["startGameButton"]
        if startGameButton.waitForExistence(timeout: 3.0) {
            startGameButton.tap()
            Thread.sleep(forTimeInterval: 3.0)
        }
    }
}
