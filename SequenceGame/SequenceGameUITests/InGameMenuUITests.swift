//
//  InGameMenuUITests.swift
//  SequenceGameUITests
//
//  Created on 2025-11-24.
//

import XCTest

/// UI tests for in-game menu functionality.
///
/// Tests the in-game menu that appears when the menu button is tapped during gameplay.
/// Verifies Resume, Restart, New Game, and navigation options work correctly.
final class InGameMenuUITests: XCTestCase {
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
    
    /// Opens the in-game menu
    private func openInGameMenu() {
        let menuButton = app.buttons["menuButton"]
        if menuButton.waitForExistence(timeout: 5.0) {
            menuButton.tap()
            Thread.sleep(forTimeInterval: 1.0)
        }
    }
    
    // MARK: - Menu Button Tests
    
    func testMenuButton_existsInGameView() {
        navigateToGameView()
        
        let menuButton = app.buttons["menuButton"]
        
        XCTAssertTrue(menuButton.waitForExistence(timeout: 5.0), "Menu button should exist in game view")
    }
    
    func testMenuButton_isTappable() {
        navigateToGameView()
        
        let menuButton = app.buttons["menuButton"]
        
        XCTAssertTrue(menuButton.waitForExistence(timeout: 5.0), "Menu button should exist")
        XCTAssertTrue(menuButton.isHittable, "Menu button should be tappable")
    }
    
    func testMenuButton_tapOpensMenu() {
        navigateToGameView()
        openInGameMenu()
        
        // Check for menu title
        let menuTitle = app.staticTexts["Game Menu"]
        
        XCTAssertTrue(menuTitle.waitForExistence(timeout: 3.0), "In-game menu should appear")
    }
    
    // MARK: - Resume Button Tests
    
    func testResumeButton_existsInMenu() {
        navigateToGameView()
        openInGameMenu()
        
        let resumeButton = app.buttons["Resume"]
        
        XCTAssertTrue(resumeButton.waitForExistence(timeout: 3.0), "Resume button should exist")
    }
    
    func testResumeButton_tapClosesMenu() {
        navigateToGameView()
        openInGameMenu()
        
        let resumeButton = app.buttons["Resume"]
        resumeButton.tap()
        Thread.sleep(forTimeInterval: 1.5)
        
        // Menu should be closed, game view should be visible
        // Check for menu button as indicator that we're back on GameView
        let menuButton = app.buttons["menuButton"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 3.0), "Menu button should exist after resume (game view is visible)")
        
        // Verify menu is closed
        let menuTitle = app.staticTexts["Game Menu"]
        XCTAssertFalse(menuTitle.exists, "Menu should be closed after resume")
    }
    
    func testResumeButton_doesNotChangeGameState() {
        navigateToGameView()
        
        openInGameMenu()
        let resumeButton = app.buttons["Resume"]
        resumeButton.tap()
        Thread.sleep(forTimeInterval: 1.5)
        
        // Game should still be in same state after resume
        // Check for gameView as indicator that game is still active
        let gameView = app.otherElements["gameView"]
        XCTAssertTrue(gameView.waitForExistence(timeout: 3.0), "Game view should still be visible after resume")
        
        // Verify menu is closed
        let menuTitle = app.staticTexts["Game Menu"]
        XCTAssertFalse(menuTitle.exists, "Menu should be closed after resume")
    }
    
    // MARK: - Restart Button Tests
    
    func testRestartButton_existsInMenu() {
        navigateToGameView()
        openInGameMenu()
        
        let restartButton = app.buttons["Restart"]
        
        XCTAssertTrue(restartButton.waitForExistence(timeout: 3.0), "Restart button should exist")
    }
    
    func testRestartButton_tapShowsConfirmation() {
        navigateToGameView()
        openInGameMenu()
        
        let restartButton = app.buttons["Restart"]
        restartButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        // Check for confirmation alert
        let alert = app.alerts["Restart Game?"]
        
        XCTAssertTrue(alert.waitForExistence(timeout: 2.0), "Confirmation alert should appear")
    }
    
    func testRestartConfirmation_hasCancelButton() {
        navigateToGameView()
        openInGameMenu()
        
        let restartButton = app.buttons["Restart"]
        restartButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        let alert = app.alerts["Restart Game?"]
        let cancelButton = alert.buttons["Cancel"]
        
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 2.0), "Cancel button should exist")
    }
    
    func testRestartConfirmation_hasRestartButton() {
        navigateToGameView()
        openInGameMenu()
        
        let restartButton = app.buttons["Restart"]
        restartButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        let alert = app.alerts["Restart Game?"]
        let confirmRestartButton = alert.buttons["Restart"]
        
        XCTAssertTrue(confirmRestartButton.waitForExistence(timeout: 2.0), "Restart button should exist")
    }
    
    func testRestartConfirmation_cancelClosesAlert() {
        navigateToGameView()
        openInGameMenu()
        
        let restartButton = app.buttons["Restart"]
        restartButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        let alert = app.alerts["Restart Game?"]
        let cancelButton = alert.buttons["Cancel"]
        cancelButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        // Alert should be gone, menu should still be visible
        XCTAssertFalse(alert.exists, "Alert should be dismissed")
    }
    
    func testRestartConfirmation_confirmRestartsGame() {
        navigateToGameView()
        openInGameMenu()
        
        let restartButton = app.buttons["Restart"]
        restartButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        let alert = app.alerts["Restart Game?"]
        let confirmRestartButton = alert.buttons["Restart"]
        confirmRestartButton.tap()
        // Wait for menu to dismiss and game to restart
        Thread.sleep(forTimeInterval: 3.0)
        
        // Menu should be closed, game should be restarted
        // Check for menu button as indicator that we're back on GameView
        let menuButton = app.buttons["menuButton"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 5.0), "Menu button should exist after restart (game is active)")
        
        // Verify menu is closed
        let menuTitle = app.staticTexts["Game Menu"]
        XCTAssertFalse(menuTitle.exists, "Menu should be closed after restart")
    }
    
    // MARK: - New Game Button Tests
    
    func testNewGameButton_existsInMenu() {
        navigateToGameView()
        openInGameMenu()
        
        let newGameButton = app.buttons["New Game"]
        
        XCTAssertTrue(newGameButton.waitForExistence(timeout: 3.0), "New Game button should exist")
    }
    
    func testNewGameButton_tapNavigatesToSettings() {
        navigateToGameView()
        openInGameMenu()
        
        let newGameButton = app.buttons["New Game"]
        newGameButton.tap()
        Thread.sleep(forTimeInterval: 2.0)
        
        // Should navigate back to game settings
        let settingsTitle = app.staticTexts["Select your game settings"]
        
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3.0), "Should navigate to game settings")
    }
    
    // MARK: - Navigation Options Tests
    
    func testHowToPlayButton_existsInMenu() {
        navigateToGameView()
        openInGameMenu()
        
        let howToPlayButton = app.buttons["How to Play"]
        
        XCTAssertTrue(howToPlayButton.waitForExistence(timeout: 3.0), "How to Play button should exist")
    }
    
    func testSettingsButton_existsInMenu() {
        navigateToGameView()
        openInGameMenu()
        
        let settingsButton = app.buttons["Settings"]
        
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 3.0), "Settings button should exist")
    }
}
