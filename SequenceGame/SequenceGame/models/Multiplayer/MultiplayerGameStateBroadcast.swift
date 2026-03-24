//
//  MultiplayerGameStateBroadcast.swift
//  SequenceGame
//

import Foundation

/// A codable snapshot of game state broadcast from the iPad host to all iPhones.
///
/// Designed for privacy: `myCards` contains only the receiving player's hand.
/// All other players are represented as `PlayerInfo` (card count only, no faces).
///
/// The host sends a fresh broadcast after every state change. Each iPhone
/// filters using `receivingPlayerId` to know which data is theirs.
struct MultiplayerGameStateBroadcast: Codable, Equatable {

    // MARK: - Turn Info

    /// Index of the current player in the turn order.
    let currentPlayerIndex: Int

    /// The `Player.id` of the player whose turn it is.
    let currentPlayerId: UUID?

    /// Peer ID string of the device that should act this turn. `nil` if it's a host-managed slot.
    let currentPlayerPeerId: String?

    /// Current overlay mode determining what UI all devices should show.
    let overlayMode: GameOverlayMode

    // MARK: - Board State

    /// Full 10×10 board tile state (cards + chips).
    let boardTiles: [[BoardTile]]

    /// All completed sequences on the board.
    let detectedSequences: [Sequence]

    /// Number of completed sequences per team.
    let teamScores: [String: Int]

    // MARK: - Player Info (public — visible to all)

    /// Ordered list of all players with safe public info (no card faces).
    let playerInfoList: [PlayerInfo]

    // MARK: - Private Data (only relevant to the receiving player)

    /// The `Player.id` of the device this broadcast was personalised for.
    /// Each iPhone ignores `myCards` if this doesn't match their assigned player.
    let receivingPlayerId: UUID?

    /// The hand cards for the receiving player only.
    let myCards: [Card]

    /// Valid board positions for the currently selected card (empty if no card selected).
    let validPositions: [Position]

    /// The card ID currently selected by the active player.
    let selectedCardId: UUID?

    // MARK: - Confirmation Flow

    /// A position that has been tapped once and is pending confirmation on the iPhone.
    /// The iPad board highlights this tile visually.
    let pendingPosition: Position?

    // MARK: - Events

    /// Set when a player discards a dead card; all iPhones show a brief toast.
    let lastDiscardEvent: DiscardEvent?

    // MARK: - Win State

    /// The winning team's color, set when the game ends.
    let winningTeam: TeamColor?
}
