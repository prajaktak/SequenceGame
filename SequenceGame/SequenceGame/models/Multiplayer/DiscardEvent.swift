//
//  DiscardEvent.swift
//  SequenceGame
//

import Foundation

/// Describes a dead-card discard event visible to all players.
///
/// Broadcast by the host when a player discards a dead card so all iPhones
/// can display a brief toast showing who discarded what.
struct DiscardEvent: Codable, Equatable {
    /// Display name of the player who discarded.
    let playerName: String

    /// Team color of the discarding player.
    let teamColor: TeamColor

    /// The card that was discarded.
    let card: Card
}
