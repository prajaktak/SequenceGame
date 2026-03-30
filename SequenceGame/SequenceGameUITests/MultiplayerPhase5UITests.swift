//
//  MultiplayerPhase5UITests.swift
//  SequenceGameUITests
//
//  UI tests for Phase 5 — Entry Point Integration.
//  All tests in this file are EXPECTED TO FAIL until Phase 5 is implemented:
//    - MultiplayerModeSelectionView is created
//    - MainMenu gains a "Multiplayer" MenuButtonView
//
//  Navigation flow under test:
//    MainMenu → "Multiplayer" → MultiplayerModeSelectionView
//      ├── "Host a Game"  → HostLobbyView   (navigationTitle "Host Lobby")
//      └── "Join a Game"  → PlayerLobbyView (navigationTitle "Join Game")
//

import XCTest

final class MultiplayerPhase5UITests: XCTestCase {

    var app: XCUIApplication!

    // MARK: - Setup / Teardown

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

    // MARK: - Main Menu

    func test_mainMenu_multiplayerButtonExists() {
        let multiplayerButton = app.buttons["Multiplayer"]
        XCTAssertTrue(
            multiplayerButton.waitForExistence(timeout: 3.0),
            "Multiplayer button should exist on the main menu"
        )
    }

    // MARK: - MultiplayerModeSelectionView

    func test_multiplayerButton_tap_navigatesToModeSelectionView() {
        navigateToModeSelection()

        let hostButton = app.buttons["Host a Game"]
        XCTAssertTrue(
            hostButton.waitForExistence(timeout: 3.0),
            "Tapping Multiplayer should navigate to MultiplayerModeSelectionView showing 'Host a Game'"
        )
    }

    func test_modeSelection_hostGameButtonExists() {
        navigateToModeSelection()

        let hostButton = app.buttons["Host a Game"]
        XCTAssertTrue(
            hostButton.waitForExistence(timeout: 3.0),
            "'Host a Game' button should exist in MultiplayerModeSelectionView"
        )
    }

    func test_modeSelection_joinGameButtonExists() {
        navigateToModeSelection()

        let joinButton = app.buttons["Join a Game"]
        XCTAssertTrue(
            joinButton.waitForExistence(timeout: 3.0),
            "'Join a Game' button should exist in MultiplayerModeSelectionView"
        )
    }

    // MARK: - HostLobbyView navigation

    func test_hostGameButton_tap_navigatesToHostLobby() {
        navigateToModeSelection()

        let hostButton = app.buttons["Host a Game"]
        XCTAssertTrue(hostButton.waitForExistence(timeout: 3.0))
        hostButton.tap()
        Thread.sleep(forTimeInterval: 1.0)

        let hostLobbyTitle = app.staticTexts["Host Lobby"]
        XCTAssertTrue(
            hostLobbyTitle.waitForExistence(timeout: 3.0),
            "Tapping 'Host a Game' should navigate to Host Lobby screen"
        )
    }

    // MARK: - PlayerLobbyView navigation

    func test_joinGameButton_tap_navigatesToPlayerLobby() {
        navigateToModeSelection()

        let joinButton = app.buttons["Join a Game"]
        XCTAssertTrue(joinButton.waitForExistence(timeout: 3.0))
        joinButton.tap()
        Thread.sleep(forTimeInterval: 1.0)

        let joinLobbyTitle = app.staticTexts["Join Game"]
        XCTAssertTrue(
            joinLobbyTitle.waitForExistence(timeout: 3.0),
            "Tapping 'Join a Game' should navigate to Join Game screen"
        )
    }

    // MARK: - Private helpers

    private func navigateToModeSelection() {
        let multiplayerButton = app.buttons["Multiplayer"]
        guard multiplayerButton.waitForExistence(timeout: 3.0) else {
            XCTFail("Cannot navigate to mode selection — 'Multiplayer' button not found on main menu")
            return
        }
        multiplayerButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
    }
}
