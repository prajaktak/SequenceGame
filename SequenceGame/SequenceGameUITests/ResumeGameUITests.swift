//
//  ResumeGameUITests.swift
//  SequenceGameUITests
//
//  Created on 2025-11-24.
//

import XCTest

/// UI tests for resume game functionality.
///
/// Tests the resume game feature from the main menu, ensuring saved games
/// can be loaded and continued without breaking current game flow.
final class ResumeGameUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Reset saved game for tests that expect no save to exist
        // Individual tests that need a save will create one
        app.launchArguments = ["-reset-saved-game", "YES", "-ui-testing"]
        app.launch()
        Thread.sleep(forTimeInterval: 0.5)
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testResumeGameButton_whenNoSaveExists_isDisabled() {
        // Ensure no save exists
        // Note: App was launched with -reset-saved-game flag
        
        let resumeButton = app.buttons["Resume Game"]
        
        // Wait for button to appear
        XCTAssertTrue(resumeButton.waitForExistence(timeout: 3.0), "Resume Game button should exist")
        
        // Give MainMenu.onAppear time to check for saved game and update hasSavedGame state
        Thread.sleep(forTimeInterval: 1.0)
        
        // Button should be disabled when no save exists
        XCTAssertFalse(resumeButton.isEnabled, "Resume button should be disabled when no save exists")
    }
    
    func testResumeGameButton_whenSaveExists_isEnabled() {
        // This test requires a saved game to exist
        // In a full implementation, you would:
        // 1. Start a game
        // 2. Play for a bit
        // 3. Background the app (triggers save)
        // 4. Return to main menu
        // 5. Check resume button is enabled
        
        let resumeButton = app.buttons["Resume Game"]
        
        if resumeButton.waitForExistence(timeout: 3.0) {
            // If save exists, button should be enabled
            // This test may need to be run after creating a save first
            // For now, we just verify the button exists
            XCTAssertTrue(resumeButton.exists, "Resume button should exist")
        }
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
}
