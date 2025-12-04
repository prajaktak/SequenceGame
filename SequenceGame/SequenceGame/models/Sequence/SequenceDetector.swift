//
//  SequenceDetector.swift
//  SequenceGame
//
//  Created by Prajakta Kulkarni on 10/11/2025.
//

import Foundation

/// Detects 5-in-a-row sequences on the game board in all four directions.
///
/// The `SequenceDetector` is responsible for identifying completed sequences of five or more
/// chips of the same team color arranged consecutively in horizontal, vertical, diagonal, or
/// antidiagonal patterns. Corner tiles (which act as wild cards) count toward any team's sequence.
///
/// ## Detection Algorithm
///
/// For each chip placement, the detector:
/// 1. Scans in all four directions from the placed chip
/// 2. Counts consecutive chips of the same color (including corners as wildcards)
/// 3. Validates that at least 5 consecutive chips exist
/// 4. Creates a `Sequence` object if validation passes
/// 5. Adds the sequence to the game state's detected sequences
///
/// ## Corner Tile Behavior
///
/// Corner tiles at positions (0,0), (0,9), (9,0), and (9,9) act as **wild cards**:
/// - They count as any team's color during sequence detection
/// - They enable sequences that pass through corners
/// - They don't belong to any specific team (`.noTeam`)
///
/// ## Time Complexity
///
/// - **Per-direction scan:** O(n) where n is the board dimension (typically 10)
/// - **Total detection:** O(4n) = O(n) for all four directions
/// - Efficient for real-time gameplay without performance impact
///
/// ## Example Usage
///
/// ```swift
/// var detector = SequenceDetector(board: gameBoard)
/// let hasSequence = detector.detectSequence(
///     atPosition: (rowIndex: 5, colIndex: 5),
///     forPlayer: currentPlayer,
///     gameState: gameState
/// )
/// if hasSequence {
///     // Sequence was detected and added to gameState.detectedSequence
/// }
/// ```
struct SequenceDetector: Codable {
    /// The game board being analyzed for sequences
    var board: Board
    
    /// The current count of consecutive chips being evaluated (resets for each direction)
    var numberOfChipsInSequence: Int = 0
    
    /// The team color currently being checked for sequences
    var teamColor: TeamColor = .noTeam
    
    // MARK: - Chip Color Detection
    
    /// Retrieves the team color of a chip at the specified board position.
    ///
    /// This method handles three distinct cases:
    /// 1. **Corner tiles**: Return `.noTeam` (act as wild cards)
    /// 2. **Empty tiles**: Return `nil` (no chip present)
    /// 3. **Occupied tiles**: Return the chip's team color
    ///
    /// - Parameter atPosition: The board coordinates (row, column) to check
    /// - Returns: The `TeamColor` of the chip at the position, `.noTeam` for corners, or `nil` if empty
    ///
    /// ## Implementation Details
    ///
    /// Corner positions are checked first to ensure they're treated as wildcards.
    /// The double-check for corners is intentional to handle edge cases during board initialization.
    func getChipColor(atPosition: Position) -> TeamColor? {
        if GameConstants.cornerPositions.contains(where: { $0.row == atPosition.row && $0.col == atPosition.col }) {
            return .noTeam
        }
        
        let isCorner = GameConstants.cornerPositions.contains { $0.row == atPosition.row && $0.col == atPosition.col }
        if board.boardTiles[atPosition.row][atPosition.col].isEmpty && !isCorner {
            return nil
        }
        
        if board.boardTiles[atPosition.row][atPosition.col].isChipOn {
            return board.boardTiles[atPosition.row][atPosition.col].chip?.color
        }
        
        return nil
    }
    
    // MARK: - Main Detection Entry Point
    
    /// Detects sequences in all four directions from the specified chip placement.
    ///
    /// This is the main entry point for sequence detection. It checks all possible sequence
    /// directions (horizontal, vertical, diagonal, and antidiagonal) from the given position.
    ///
    /// - Parameters:
    ///   - atPosition: The board coordinates where a chip was just placed
    ///   - forPlayer: The player who placed the chip
    ///   - gameState: The current game state (receives detected sequences)
    /// - Returns: `true` if at least one sequence was detected in any direction, `false` otherwise
    ///
    /// ## Detection Process
    ///
    /// 1. Validates the position is not an empty non-corner tile
    /// 2. Sets the team color to match the player's team
    /// 3. Scans horizontally (left-right)
    /// 4. Scans vertically (up-down)
    /// 5. Scans diagonally (top-left to bottom-right)
    /// 6. Scans antidiagonally (top-right to bottom-left)
    /// 7. Returns `true` if **any** direction contains a valid sequence
    ///
    /// ## Performance
    ///
    /// - **Best case:** O(1) if position is invalid
    /// - **Average case:** O(4n) where n is board dimension (checks all 4 directions)
    /// - **Worst case:** O(4n) (always checks all directions)
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Player places chip at row 5, column 5
    /// let detected = detector.detectSequence(
    ///     atPosition: (rowIndex: 5, colIndex: 5),
    ///     forPlayer: currentPlayer,
    ///     gameState: gameState
    /// )
    /// // detected = true if any 5-in-a-row found
    /// ```
    mutating func detectSequence(atPosition: Position, forPlayer: Player, gameState: GameState) -> Bool {
        var isSequenceCompleteHorizontally: Bool = false
        var isSequenceCompleteVertically: Bool = false
        var isSequenceCompleteDiagonally: Bool = false
        var isSequenceCompleteAntidiagonally: Bool = false
        
        let isCorner = GameConstants.cornerPositions.contains { $0.row == atPosition.row && $0.col == atPosition.col }
        if board.boardTiles[atPosition.row][atPosition.col].isEmpty && !isCorner {
            return false
        }
        
        teamColor =  forPlayer.team.color 
        // detecting sequence in one row
        isSequenceCompleteHorizontally = detectSequenceHorizontally(atPosition: atPosition, forPlayer: forPlayer, gameState: gameState)
        
        // detecting sequence in one column
        isSequenceCompleteVertically = detectSequenceVertically(atPosition: atPosition, forPlayer: forPlayer, gameState: gameState)
        
        // detecting sequence diagonally
        isSequenceCompleteDiagonally = detectSequenceDiagonally(atPosition: atPosition, forPlayer: forPlayer, gameState: gameState)
        
        // detecting sequence antidiagonally
        isSequenceCompleteAntidiagonally = detectSequenceAntidiagonal(atPosition: atPosition, forPlayer: forPlayer, gameState: gameState)
        
        // true when any one sequence detected. false when no sequence detected.
        if isSequenceCompleteDiagonally || isSequenceCompleteHorizontally || isSequenceCompleteVertically || isSequenceCompleteAntidiagonally {
            print("Sequence completed team color: \(teamColor)")
        }
        return isSequenceCompleteDiagonally || isSequenceCompleteHorizontally || isSequenceCompleteVertically || isSequenceCompleteAntidiagonally
    }
    
    // MARK: - Horizontal Detection
    
    /// Detects horizontal sequences (left-right) from the specified position.
    ///
    /// Scans left and right from the placed chip, counting consecutive chips of the same
    /// team color (or corner wildcards) until reaching a different color or board edge.
    ///
    /// - Parameters:
    ///   - atPosition: The center position to scan from
    ///   - forPlayer: The player whose sequence we're detecting
    ///   - gameState: The game state to add detected sequences to
    /// - Returns: `true` if a valid 5+ chip sequence was found, `false` otherwise
    ///
    /// ## Algorithm
    ///
    /// 1. Start with the center chip (count = 1)
    /// 2. Scan **left** (decreasing column index) until:
    ///    - Reaching board edge (column 0)
    ///    - Finding a different team's chip
    /// 3. Scan **right** (increasing column index) until:
    ///    - Reaching board edge (column 9)
    ///    - Finding a different team's chip
    /// 4. Validate total count >= 5
    ///
    /// ## Example
    ///
    /// ```
    /// Board row 5: [ ][ ][B][B][X][B][ ][ ]
    ///                     ← scan → 
    /// Chip placed at column 4 (X)
    /// Left chips: 2 (columns 2,3)
    /// Center: 1 (column 4)
    /// Right chips: 1 (column 5)
    /// Total: 4 chips (not enough for sequence)
    /// ```
    ///
    /// - Complexity: O(n) where n is the number of columns (typically 10)
    mutating func detectSequenceHorizontally(atPosition: Position, forPlayer: Player, gameState: GameState) -> Bool {
        var sequenceHorizontalLeft: [BoardTile] = []
        var sequenceHorizontalRight: [BoardTile] = []
        let sequenceHorizontalCenter: BoardTile = board.boardTiles[atPosition.row][atPosition.col]
        var sequenceStartColumnIndex: Int = atPosition.col
        // Start counting with the center chip (position 1)
        numberOfChipsInSequence = 1
        
        // For horizontal detection, column index varies. Start checking left (previous column) first
        var aColumnIndex = atPosition.col - 1
    
        // Check chips to the left (previous columns) until reaching border or finding different color chip
        while aColumnIndex >= 0 && (forPlayer.team.color == getChipColor(atPosition: Position(row: atPosition.row, col: aColumnIndex)) || getChipColor(atPosition: Position(row: atPosition.row, col: aColumnIndex)) == .noTeam) {
            numberOfChipsInSequence += 1
            sequenceHorizontalLeft.append(board.boardTiles[atPosition.row][aColumnIndex])
            sequenceStartColumnIndex = aColumnIndex
            aColumnIndex -= 1
        }
        
        // Check chips to the right (next columns) until reaching border or finding different color chip
        aColumnIndex = atPosition.col + 1
        while aColumnIndex < board.col && (forPlayer.team.color == getChipColor(atPosition: Position(row: atPosition.row, col: aColumnIndex)) || getChipColor(atPosition: Position(row: atPosition.row, col: aColumnIndex)) == .noTeam) {
            numberOfChipsInSequence += 1
            sequenceHorizontalRight.append(board.boardTiles[atPosition.row][aColumnIndex])
            aColumnIndex += 1
        }

        // Verify sequence has at least 5 chips and matches the player's team color
        return validateAndCreateSequence(left: sequenceHorizontalLeft, center: sequenceHorizontalCenter, right: sequenceHorizontalRight, position: Position(row: atPosition.row, col: sequenceStartColumnIndex), sequenceType: .horizontal, gameState: gameState)
    }
    
    // MARK: - Vertical Detection
    
    /// Detects vertical sequences (up-down) from the specified position.
    ///
    /// Scans up and down from the placed chip, counting consecutive chips of the same
    /// team color (or corner wildcards) until reaching a different color or board edge.
    ///
    /// - Parameters:
    ///   - atPosition: The center position to scan from
    ///   - forPlayer: The player whose sequence we're detecting
    ///   - gameState: The game state to add detected sequences to
    /// - Returns: `true` if a valid 5+ chip sequence was found, `false` otherwise
    ///
    /// ## Algorithm
    ///
    /// 1. Start with the center chip (count = 1)
    /// 2. Scan **up** (decreasing row index) until:
    ///    - Reaching board edge (row 0)
    ///    - Finding a different team's chip
    /// 3. Scan **down** (increasing row index) until:
    ///    - Reaching board edge (row 9)
    ///    - Finding a different team's chip
    /// 4. Validate total count >= 5
    ///
    /// ## Example
    ///
    /// ```
    /// Column 5:
    ///   [ ]  row 0
    ///   [B]  row 1  ← scan up
    ///   [B]  row 2
    ///   [X]  row 3  ← chip placed here
    ///   [B]  row 4  ← scan down
    ///   [B]  row 5
    ///   [ ]  row 6
    ///
    /// Up chips: 2 (rows 1,2)
    /// Center: 1 (row 3)
    /// Down chips: 2 (rows 4,5)
    /// Total: 5 chips → SEQUENCE DETECTED
    /// ```
    ///
    /// - Complexity: O(n) where n is the number of rows (typically 10)
    mutating func detectSequenceVertically(atPosition: Position, forPlayer: Player, gameState: GameState) -> Bool {
        var sequenceVerticalUp: [BoardTile] = []
        var sequenceVerticalDown: [BoardTile] = []
        let sequenceVerticalCenter = board.boardTiles[atPosition.row][atPosition.col]
        var sequenceStartRowIndex: Int = atPosition.row

        // Start counting with the center chip (position 1)
        numberOfChipsInSequence = 1
        // For vertical detection, row index varies. Start checking up (previous row) first
        var aRowIndex = atPosition.row - 1
        
        // Check chips above (previous rows) until reaching border or finding different color chip
        while aRowIndex >= 0  && (forPlayer.team.color == getChipColor(atPosition: Position(row: aRowIndex, col: atPosition.col)) || getChipColor(atPosition: Position(row: aRowIndex, col: atPosition.col)) == .noTeam) {
            numberOfChipsInSequence += 1
            sequenceVerticalUp.append(board.boardTiles[aRowIndex][atPosition.col])
            sequenceStartRowIndex = aRowIndex
            aRowIndex -= 1
        }
        
        // Check chips below (next rows) until reaching border or finding different color chip
        aRowIndex = atPosition.row + 1
        while aRowIndex < board.row && (forPlayer.team.color == getChipColor(atPosition: Position(row: aRowIndex, col: atPosition.col)) || getChipColor(atPosition: Position(row: aRowIndex, col: atPosition.col)) == .noTeam) {
            numberOfChipsInSequence += 1
            sequenceVerticalDown.append(board.boardTiles[aRowIndex][atPosition.col])
            aRowIndex += 1
        }
        
        // Verify sequence has at least 5 chips and matches the player's team color
        return validateAndCreateSequence(left: sequenceVerticalUp, center: sequenceVerticalCenter, right: sequenceVerticalDown, position: Position(row: sequenceStartRowIndex, col: atPosition.col), sequenceType: .vertical, gameState: gameState)
    }
    
    // MARK: - Diagonal Detection
    
    /// Detects diagonal sequences (top-left to bottom-right) from the specified position.
    ///
    /// Scans diagonally in both directions from the placed chip, counting consecutive chips
    /// of the same team color (or corner wildcards).
    ///
    /// - Parameters:
    ///   - atPosition: The center position to scan from
    ///   - forPlayer: The player whose sequence we're detecting
    ///   - gameState: The game state to add detected sequences to
    /// - Returns: `true` if a valid 5+ chip sequence was found, `false` otherwise
    ///
    /// ## Algorithm
    ///
    /// 1. Start with the center chip (count = 1)
    /// 2. Scan **top-left** (decreasing row and column) until:
    ///    - Reaching board edge
    ///    - Finding a different team's chip
    /// 3. Scan **bottom-right** (increasing row and column) until:
    ///    - Reaching board edge
    ///    - Finding a different team's chip
    /// 4. Validate total count >= 5
    ///
    /// ## Example
    ///
    /// ```
    /// Board (diagonal from top-left to bottom-right):
    ///   [B][ ][ ][ ]  row 1
    ///   [ ][B][ ][ ]  row 2
    ///   [ ][ ][X][ ]  row 3  ← chip placed here
    ///   [ ][ ][ ][B]  row 4
    ///   [ ][ ][ ][ ]  row 5
    ///
    /// Top-left: 2 chips
    /// Center: 1 chip
    /// Bottom-right: 1 chip
    /// Total: 4 chips (not enough)
    /// ```
    ///
    /// - Complexity: O(n) where n is min(rows, columns) along the diagonal
    mutating func detectSequenceDiagonally(atPosition: Position, forPlayer: Player, gameState: GameState) -> Bool {
        var sequenceDiagonalLeftUp: [BoardTile] = []
        var sequenceDiagonalRightDown: [BoardTile] = []
        let sequenceDiagonalCenter = board.boardTiles[atPosition.row][atPosition.col]
        var sequenceStartRowIndex: Int = atPosition.row
        var sequenceStartColumnIndex: Int = atPosition.col

        // Start counting with the center chip (position 1)
        numberOfChipsInSequence = 1
        // For diagonal detection (top-left to bottom-right), both row and column indices vary
        // Start checking top-left (previous row and column) first
        var aRowIndex = atPosition.row - 1
        var aColumnIndex = atPosition.col - 1
        
        // Check chips in top-left direction until reaching border or finding different color chip
        while aRowIndex >= 0 && aColumnIndex >= 0 && (forPlayer.team.color == getChipColor(atPosition: Position(row: aRowIndex, col: aColumnIndex)) || getChipColor(atPosition: Position(row: aRowIndex, col: aColumnIndex)) == .noTeam) {
            numberOfChipsInSequence += 1
            sequenceDiagonalLeftUp.append(board.boardTiles[aRowIndex][aColumnIndex])
            sequenceStartRowIndex = aRowIndex
            sequenceStartColumnIndex = aColumnIndex
            aRowIndex -= 1
            aColumnIndex -= 1
        }
        
        // Check chips in bottom-right direction until reaching border or finding different color chip
        aRowIndex = atPosition.row + 1
        aColumnIndex = atPosition.col + 1
        while aRowIndex < board.row && aColumnIndex < board.col && (forPlayer.team.color == getChipColor(atPosition: Position(row: aRowIndex, col: aColumnIndex)) || getChipColor(atPosition: Position(row: aRowIndex, col: aColumnIndex)) == .noTeam) {
            numberOfChipsInSequence += 1
            sequenceDiagonalRightDown.append(board.boardTiles[aRowIndex][aColumnIndex])
            aRowIndex += 1
            aColumnIndex += 1
        }
        
        // Verify sequence has at least 5 chips and matches the player's team color
        return validateAndCreateSequence(left: sequenceDiagonalLeftUp, center: sequenceDiagonalCenter, right: sequenceDiagonalRightDown, position: Position(row: sequenceStartRowIndex, col: sequenceStartColumnIndex), sequenceType: .diagonal, gameState: gameState)
    }
    
    // MARK: - Antidiagonal Detection
    
    /// Detects antidiagonal sequences (top-right to bottom-left) from the specified position.
    ///
    /// Scans antidiagonally in both directions from the placed chip, counting consecutive chips
    /// of the same team color (or corner wildcards).
    ///
    /// - Parameters:
    ///   - atPosition: The center position to scan from
    ///   - forPlayer: The player whose sequence we're detecting
    ///   - gameState: The game state to add detected sequences to
    /// - Returns: `true` if a valid 5+ chip sequence was found, `false` otherwise
    ///
    /// ## Algorithm
    ///
    /// 1. Start with the center chip (count = 1)
    /// 2. Scan **top-right** (decreasing row, increasing column) until:
    ///    - Reaching board edge
    ///    - Finding a different team's chip
    /// 3. Scan **bottom-left** (increasing row, decreasing column) until:
    ///    - Reaching board edge
    ///    - Finding a different team's chip
    /// 4. Validate total count >= 5
    ///
    /// ## Example
    ///
    /// ```
    /// Board (antidiagonal from top-right to bottom-left):
    ///   [ ][ ][ ][B]  row 1
    ///   [ ][ ][B][ ]  row 2
    ///   [ ][X][ ][ ]  row 3  ← chip placed here
    ///   [B][ ][ ][ ]  row 4
    ///   [ ][ ][ ][ ]  row 5
    ///
    /// Top-right: 2 chips
    /// Center: 1 chip
    /// Bottom-left: 1 chip
    /// Total: 4 chips (not enough)
    /// ```
    ///
    /// ## Note
    ///
    /// Antidiagonal is also called "secondary diagonal" or "reverse diagonal"
    /// and runs perpendicular to the main diagonal.
    ///
    /// - Complexity: O(n) where n is min(rows, columns) along the antidiagonal
    mutating func detectSequenceAntidiagonal(atPosition: Position, forPlayer: Player, gameState: GameState) -> Bool {
        var sequenceAntiDiagonalLeftDown: [BoardTile] = []
        var sequenceAntiDiagonalRightUp: [BoardTile] = []
        let sequenceAntiDiagonalCenter = board.boardTiles[atPosition.row][atPosition.col]
        var sequenceStartRowIndex: Int = atPosition.row
        var sequenceStartColumnIndex: Int = atPosition.col
       
        // Start counting with the center chip (position 1)
        numberOfChipsInSequence = 1
        // For antidiagonal detection (top-right to bottom-left), both row and column indices vary
        // Start checking top-right (previous row, next column) first
        var aRowIndex = atPosition.row - 1
        var aColumnIndex = atPosition.col + 1
        
        // Check chips in top-right direction until reaching border or finding different color chip
        while aRowIndex >= 0 && aColumnIndex < board.col &&
                (forPlayer.team.color == getChipColor(atPosition: Position(row: aRowIndex, col: aColumnIndex)) || getChipColor(atPosition: Position(row: aRowIndex, col: aColumnIndex)) == .noTeam) {
            numberOfChipsInSequence += 1
            sequenceAntiDiagonalRightUp.append(board.boardTiles[aRowIndex][aColumnIndex])
            sequenceStartRowIndex = aRowIndex
            sequenceStartColumnIndex = aColumnIndex
            aRowIndex -= 1
            aColumnIndex += 1
        }
        
        // Check chips in bottom-left direction until reaching border or finding different color chip
        aRowIndex = atPosition.row + 1
        aColumnIndex = atPosition.col - 1
        while aRowIndex < board.row && aColumnIndex >= 0 &&
                (forPlayer.team.color == getChipColor(atPosition: Position(row: aRowIndex, col: aColumnIndex)) || getChipColor(atPosition: Position(row: aRowIndex, col: aColumnIndex)) == .noTeam) {
            numberOfChipsInSequence += 1
            sequenceAntiDiagonalLeftDown.append(board.boardTiles[aRowIndex][aColumnIndex])
            aRowIndex += 1
            aColumnIndex -= 1
        }
        
        // Verify sequence has at least 5 chips and matches the player's team color
        return validateAndCreateSequence(left: sequenceAntiDiagonalRightUp, center: sequenceAntiDiagonalCenter, right: sequenceAntiDiagonalLeftDown, position: Position(row: sequenceStartRowIndex, col: sequenceStartColumnIndex), sequenceType: .antiDiagonal, gameState: gameState)
    }
    
    // MARK: - Sequence Validation and Creation
    
    /// Validates that a potential sequence meets requirements and creates a Sequence object.
    ///
    /// This helper method performs final validation and constructs the `Sequence` object
    /// that will be added to the game state's detected sequences.
    ///
    /// - Parameters:
    ///   - left: Tiles found in the "backward" direction (left/up/top-left/top-right)
    ///   - center: The tile where the chip was just placed
    ///   - right: Tiles found in the "forward" direction (right/down/bottom-right/bottom-left)
    ///   - position: The starting position of the sequence (first tile in reading order)
    ///   - sequenceType: The direction type (horizontal, vertical, diagonal, or antidiagonal)
    ///   - gameState: The game state to add the sequence to
    /// - Returns: `true` if a valid sequence was created and added, `false` otherwise
    ///
    /// ## Validation Rules
    ///
    /// 1. **Minimum Length**: Must have at least 5 consecutive chips
    /// 2. **Non-Empty**: The tile array must not be empty after construction
    /// 3. **Team Color**: All chips must be same color (or corners as wildcards)
    ///
    /// ## Sequence Creation
    ///
    /// If validation passes:
    /// - Constructs ordered array of tiles (left → center → right)
    /// - Creates a `Sequence` object with metadata
    /// - Appends to `gameState.detectedSequence` for win condition checking
    /// - Protects chips in the sequence from removal by one-eyed Jacks
    ///
    /// - Complexity: O(k) where k is the number of tiles in the sequence (typically 5-10)
    mutating func validateAndCreateSequence(
        left: [BoardTile],
        center: BoardTile,
        right: [BoardTile],
        position: Position,
        sequenceType: SequenceType,
        gameState: GameState) -> Bool {
        guard numberOfChipsInSequence >= 5 else { return false }
        
        let sequenceTiles = createSequence(left: left, center: center, right: right)
        guard !sequenceTiles.isEmpty else { return false }
        
        let sequence = Sequence(
            tiles: sequenceTiles,
            position: Position(row: position.row, col: position.col),
            teamColor: teamColor,
            sequenceType: sequenceType
        )
        gameState.detectedSequence.append(sequence)
        return true
    }
    
    // MARK: - Sequence Array Construction
    
    /// Constructs an ordered array of tiles representing a complete sequence.
    ///
    /// This helper method combines tiles from both directions and the center tile into
    /// a single array in the correct order for the sequence type.
    ///
    /// - Parameters:
    ///   - left: Tiles in the "backward" direction (must be reversed for correct order)
    ///   - center: The center tile (where chip was placed)
    ///   - right: Tiles in the "forward" direction (already in correct order)
    /// - Returns: An ordered array of `BoardTile` objects representing the complete sequence
    ///
    /// ## Ordering Rules
    ///
    /// - **Left tiles**: Reversed before concatenation (they were collected backward)
    /// - **Center tile**: Always in the middle
    /// - **Right tiles**: Used as-is (already in correct order)
    ///
    /// ## Example Cases
    ///
    /// ```swift
    /// // Case 1: Only center (shouldn't happen if called correctly)
    /// left=[], center=[C], right=[] → [C]
    ///
    /// // Case 2: Center + right only
    /// left=[], center=[C], right=[R1,R2] → [C,R1,R2]
    ///
    /// // Case 3: Left + center only
    /// left=[L2,L1], center=[C], right=[] → [L1,L2,C]
    /// (Note: left is reversed)
    ///
    /// // Case 4: Full sequence
    /// left=[L2,L1], center=[C], right=[R1,R2] → [L1,L2,C,R1,R2]
    /// ```
    ///
    /// - Complexity: O(n) where n is the total number of tiles in the sequence
    func createSequence(left: [BoardTile], center: BoardTile, right: [BoardTile]) -> [BoardTile] {
        if left.isEmpty && right.isEmpty {
            return [center]
        } else if left.isEmpty {
            return  [center] + right
        } else if right.isEmpty {
            return left.reversed() + [center]
        } else {
            return left.reversed() + [center] + right
        }
    }
}
