//
//  MultiplayerSession.swift
//  SequenceGame
//

import Foundation

/// Tracks the mapping between connected peer IDs and their assigned player IDs.
///
/// Maintained by the host (`MultiplayerCoordinator`) to know which device
/// controls which player slot. Used to validate that only the correct peer
/// can send actions on a given turn.
struct MultiplayerSession: Equatable {
    /// Maps a MultipeerConnectivity peer ID string to the assigned `Player.id`.
    private(set) var peerToPlayer: [String: UUID] = [:]

    /// Assigns a peer to a player slot. Replaces any existing assignment for that peer.
    mutating func assign(peerId: String, to playerId: UUID) {
        peerToPlayer[peerId] = playerId
    }

    /// Removes all assignments for a disconnected peer.
    mutating func removePeer(_ peerId: String) {
        peerToPlayer.removeValue(forKey: peerId)
    }

    /// Returns the player ID assigned to the given peer, if any.
    func playerId(for peerId: String) -> UUID? {
        peerToPlayer[peerId]
    }

    /// Returns the peer ID for a given player ID, if assigned.
    func peerId(for playerId: UUID) -> String? {
        peerToPlayer.first(where: { $0.value == playerId })?.key
    }

    /// Returns true if the peer is currently assigned to any player slot.
    func isAssigned(_ peerId: String) -> Bool {
        peerToPlayer[peerId] != nil
    }
}
