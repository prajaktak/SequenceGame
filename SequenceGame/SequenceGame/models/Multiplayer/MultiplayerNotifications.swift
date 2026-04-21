//
//  MultiplayerNotifications.swift
//  SequenceGame
//
//  Shared notification names used to coordinate cross-view navigation
//  in the multiplayer flow without tight coupling between screens.
//

import Foundation

extension Notification.Name {
    /// Posted when the host ends a multiplayer session (game-over "New Game" or explicit end).
    ///
    /// Any view in the multiplayer navigation stack that observes this notification
    /// should dismiss itself so all devices return to the main menu together.
    static let multiplayerSessionEnded = Notification.Name("multiplayerSessionEnded")
}
