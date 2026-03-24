//
//  MultiplayerRole.swift
//  SequenceGame
//

import Foundation

/// Identifies the role of this device in a multiplayer session.
///
/// - host: iPad — runs GameState, displays the board, advertises the session.
/// - player: iPhone — displays one player's hand, sends actions to host.
enum MultiplayerRole: Codable, Equatable {
    case host
    case player(peerId: String, playerId: UUID)
}
