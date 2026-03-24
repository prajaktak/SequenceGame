//
//  PlayerInfo.swift
//  SequenceGame
//

import Foundation

/// Safe, privacy-respecting snapshot of a player broadcast to all devices.
///
/// Contains only what all players are allowed to see:
/// name, team, and card count. Card faces are never included.
struct PlayerInfo: Codable, Equatable, Identifiable {
    /// Stable identifier matching `Player.id` on the host.
    let id: UUID

    /// Display name of the player.
    let name: String

    /// Team color of the player.
    let teamColor: TeamColor

    /// Number of cards in the player's hand (faces are private).
    let cardCount: Int

    /// Peer ID string of the device controlling this player. `nil` for host-only slots.
    let peerId: String?
}
