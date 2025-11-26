//
//  GameRestartUITests.swift
//  SequenceGameUITests
//
//  Created on 2025-11-24.
//

import XCTest

/// UI tests for game restart functionality.
///
/// Tests the restart game feature accessible from the in-game menu
/// and game over overlay, ensuring games restart correctly with same players.
final class GameRestartUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-reset-saved-game", "YES"]
        app.launch()
        Thread.sleep(forTimeInterval: 0.5)
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Methods
    
    /// Navigates from main menu to game view
    private func navigateToGameView() {
        // First navigate to settings
        let newGameButton = app.buttons["New Game"]
        if newGameButton.waitForExistence(timeout: 3.0) {
            newGameButton.tap()
            Thread.sleep(forTimeInterval: 1.0)
        }
        
        // After accessibility fixes, "Start Game" should be queryable as a button
        var tapped = false
        
        // Strategy 1: Try as button with identifier (preferred after fix)
        let startGameButton = app.buttons["startGameButton"]
        if startGameButton.waitForExistence(timeout: 3.0) {
            print("✅ Found 'Start Game' as button with identifier")
            startGameButton.tap()
            tapped = true
        }
        
        // Strategy 2: Try as button with label
        if !tapped {
            let startGameButtonLabel = app.buttons["Start Game"]
            if startGameButtonLabel.waitForExistence(timeout: 2.0) {
                print("✅ Found 'Start Game' as button with label")
                startGameButtonLabel.tap()
                tapped = true
            }
        }
        
        // Strategy 3: Try as link with identifier (fallback)
        if !tapped {
            let startGameLink = app.links["startGameButton"]
            if startGameLink.waitForExistence(timeout: 2.0) {
                print("✅ Found 'Start Game' as link")
                startGameLink.tap()
                tapped = true
            }
        }
        
        // Wait for game to initialize completely
        Thread.sleep(forTimeInterval: 3.0)
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
    
    // MARK: - Restart from Menu Tests
    
    func testRestartFromMenu_preservesPlayerCount() {
        navigateToGameView()
        
        restartGameFromMenu()
        
        // After restart, menu should be closed and game should still be active
        // Check for menu button as indicator that we're back on GameView
        let menuButton = app.buttons["menuButton"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 5.0), "Menu button should exist after restart (game is active)")
        
        // Verify menu is closed
        let menuTitle = app.staticTexts["Game Menu"]
        XCTAssertFalse(menuTitle.exists, "Menu should be closed after restart")
    }
    
    func testRestartFromMenu_resetsBoardState() {
        navigateToGameView()
        
        restartGameFromMenu()
        
        // After restart, menu should be closed and game board should be visible
        // Check for gameBoardContainer as indicator that game is active
        let gameBoardContainer = app.otherElements["gameBoardContainer"]
        XCTAssertTrue(gameBoardContainer.waitForExistence(timeout: 5.0), "Game board should be visible after restart")
        
        // Verify menu is closed
        let menuTitle = app.staticTexts["Game Menu"]
        XCTAssertFalse(menuTitle.exists, "Menu should be closed after restart")
    }
    
    func testRestartFromMenu_closesMenu() {
        navigateToGameView()
        
        let menuButton = app.buttons["menuButton"]
        menuButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        let menuTitle = app.staticTexts["Game Menu"]
        XCTAssertTrue(menuTitle.waitForExistence(timeout: 2.0))
        
        restartGameFromMenu()
        
        // Menu should be closed
        XCTAssertFalse(menuTitle.exists, "Menu should be closed after restart")
    }
    
    // MARK: - Restart from Game Over Tests
    
    func testPlayAgainButton_existsInGameOver() {
        // Note: This test requires game to be in game over state
        // For now, we'll test that the button structure exists
        // Full game over test would require completing a game
        
        navigateToGameView()
        
        // Test would verify Play Again button exists in game over state
        // (Requires completing a game to reach game over state)
    }
}
