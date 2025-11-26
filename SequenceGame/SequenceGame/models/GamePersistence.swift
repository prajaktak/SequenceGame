//
//  GamePersistence.swift
//  SequenceGame
//
//  Created on [today's date]
//

import Foundation

/// Manages persistence of game state to disk using JSON encoding.
///
/// `GamePersistence` is responsible for:
/// - Saving game state to disk
/// - Loading saved game state
/// - Checking if a saved game exists
/// - Deleting saved games
///
/// All methods are static as there's no instance state needed.
final class GamePersistence {
    
    // MARK: - Properties
    
    /// The file name for the saved game JSON file
    private static let savedGameFileName = "savedGame.json"
    
    // MARK: - File URL
    
    /// Returns the file URL where the game save is stored.
    ///
    /// Uses the application's documents directory for persistence across app launches.
    ///
    /// - Returns: The URL for the saved game file
    private static func gameSaveURL() -> URL {
        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            fatalError("Unable to access documents directory. This should never happen on supported platforms.")
        }
        
        return documentsDirectory.appendingPathComponent(savedGameFileName)
    }
    
    // MARK: - Check for Save
    
    /// Checks if a saved game file exists on disk.
    ///
    /// - Returns: `true` if a saved game exists, `false` otherwise
    static func hasSavedGame() -> Bool {
        let url = gameSaveURL()
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    // MARK: - Save Game
    
    /// Saves the current game state to disk.
    ///
    /// Creates a snapshot of the GameState and encodes it as JSON to the documents directory.
    /// Any existing save file will be overwritten.
    ///
    /// - Parameter gameState: The current game state to save
    /// - Throws: An error if encoding or file writing fails
    static func saveGame(_ gameState: GameState) throws {
       // Create snapshot from current game state
        let snapshot = GameStateSnapshot(from: gameState)
        // Create JSONEncoder with .prettyPrinted formatting
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        // Encode snapshot
        let data = try encoder.encode(snapshot)
        // Get file URL
        let url = gameSaveURL()
        // Write data to file atomically
        try data.write(to: url, options: [.atomic])
    }
    
    // MARK: - Load Game
    
    /// Loads a saved game state from disk.
    ///
    /// Reads the saved JSON file, decodes it into a GameStateSnapshot, and returns it.
    ///
    /// - Returns: A Result containing either the loaded snapshot or an error
    static func loadGame() -> Result<GameStateSnapshot, Error> {
        let url = gameSaveURL()
    
        do {
            // Read data from file
            let data = try Data(contentsOf: url)
            
            // Create JSON decoder
            let decoder = JSONDecoder()
            
            // Decode JSON data to GameStateSnapshot
            let snapshot = try decoder.decode(GameStateSnapshot.self, from: data)
            
            return .success(snapshot)
            
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Delete Save
    
    /// Deletes the saved game file from disk.
    ///
    /// - Returns: `true` if the file was deleted successfully, `false` otherwise
    @discardableResult
    static func deleteSavedGame() -> Bool {
          let url = gameSaveURL()
    
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
}
