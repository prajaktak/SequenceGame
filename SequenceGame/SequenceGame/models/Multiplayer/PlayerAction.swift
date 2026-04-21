//
//  PlayerAction.swift
//  SequenceGame
//

import Foundation

/// An action sent from an iPhone player to the iPad host.
///
/// Each case represents a distinct player interaction during their turn.
/// The host validates the action against the current `GameState` before applying it.
enum PlayerAction: Codable, Equatable {
    /// Player selects a card from their hand.
    case selectCard(cardId: UUID)

    /// Player deselects the currently selected card.
    case deselectCard

    /// Player taps a valid position — iPad highlights it pending confirmation.
    case selectPosition(position: Position)

    /// Player confirms placing a chip at the selected position.
    case confirmPlacement(position: Position, cardId: UUID)

    /// Player cancels the pending placement (dismisses confirm dialog).
    case cancelPlacement

    /// Player replaces a dead card (no valid positions exist for that card).
    case replaceDeadCard(cardId: UUID)

    /// Player voluntarily leaves the game mid-session.
    case leaveGame

    /// Player requests the host to restart the game with the same players.
    case requestRestart

    /// Player requests the host to end the game and send all devices to the main menu.
    ///
    /// Unlike `leaveGame`, this does not disconnect immediately — the iPhone stays
    /// connected so it can receive the host's `isGameEnded` broadcast and navigate
    /// in sync with all other players.
    case requestEndGame
}
