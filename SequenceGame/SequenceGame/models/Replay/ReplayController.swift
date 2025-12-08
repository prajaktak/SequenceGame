//
//  ReplayController.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 08/12/2025.
//

import Foundation

/// Controls replay playback of recorded game moves
final class ReplayController: ObservableObject {
    @Published var playbackState: ReplayPlaybackState
    @Published var currentMoveIndex: Int

    let recorder: ReplayRecorder
    private weak var gameState: GameState?
    private let replayDelay: TimeInterval = 1.0 // Fixed 1 second delay between moves

    init(recorder: ReplayRecorder, gameState: GameState? = nil) {
        self.recorder = recorder
        self.gameState = gameState
        self.playbackState = .stopped
        self.currentMoveIndex = 0
    }

    /// Starts replay from the beginning
    func startReplay() {
        guard !recorder.moves.isEmpty else { return }
        guard let gameState = gameState else { return }

        // Clear the board first
        gameState.clearBoardForReplay()

        currentMoveIndex = 0
        playbackState = .playing
        playNextMove()
    }

    /// Stops replay and resets to beginning
    func stopReplay() {
        playbackState = .stopped
        currentMoveIndex = 0
    }

    /// Plays the next move in sequence
    private func playNextMove() {
        guard playbackState == .playing else { return }
        guard currentMoveIndex < recorder.moves.count else {
            stopReplay()
            // Show replay finished overlay
            if let gameState = gameState {
                gameState.overlayMode = .replayFinished
            }
            return
        }

        let move = recorder.moves[currentMoveIndex]
        executeMove(move)

        currentMoveIndex += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + replayDelay) { [weak self] in
            self?.playNextMove()
        }
    }

    /// Executes a recorded move on the game state
    private func executeMove(_ move: GameMove) {
        guard let gameState = gameState else { return }

        switch move.moveType {
        case .placeChip:
            gameState.placeChip(at: move.position, teamColor: move.teamColor)
        case .removeChip:
            gameState.removeChip(at: move.position)
        case .deadCardReplace:
            break
        }
    }

    /// Progress of replay as percentage (0.0 to 1.0)
    var progress: Double {
        guard !recorder.moves.isEmpty else { return 0.0 }
        return Double(currentMoveIndex) / Double(recorder.moves.count)
    }
}
