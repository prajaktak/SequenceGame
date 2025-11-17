//
//  SequenceDetectorTests.swift
//  SequenceGameTests
//
//  Created by Prajakta Kulkarni on 11/11/2025.
//
// swiftlint:disable type_body_length
import Testing
@testable import SequenceGame
import SwiftUICore

struct SequenceDetectorTests {

    // MARK: - Sequence detection
    @Test("detectSequence returns true for 5 matching chips in a row")
    func testDetectSequence_5MatchingChipsInARow_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[1][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][2] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][3] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][4] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][5] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (1, 5),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        // expectation
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
   
    }
    
    @Test("detectSequence returns true for 5 matching chips in a column")
    func testDetectSequence_5MatchingChipsInAColumn_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[1][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[2][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[3][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[5][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (5, 1),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        
        // expectation
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
   
    }
    
    @Test("detectSequence returns true for 5 matching chips digonally")
    func testDetectSequence_5MatchingChipsDigonally_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[1][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[2][2] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[3][3] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][4] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[5][5] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (5, 5),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        // expectation
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
    }
    
    @Test("detectSequence returns true for 5 matching chips Antidiagonally")
    func testDetectSequence_5MatchingChipsAntidiagonal_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[9][9] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[8][8] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[7][7] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[6][6] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[5][5] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][4] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (5, 5),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        
        // expectatiom
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
    }
    
    @Test("detectSequence returns false for less than 5 matching chips horizontally")
    func testDetectSequence_lessThan5MatchChipsHorizontally_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[1][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][2] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][3] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][4] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .green))
        board.boardTiles[1][5] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .green))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (1, 5),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        
        // expectation
        #expect(!isSequenceComplete && gameState.detectedSequence.isEmpty)
    }
    
    @Test("detectSequence returns false for less than 5 matching chips in a column")
    func testDetectSequence_lessThan5MatchChipsvertically_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[1][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[2][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[3][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .green))
        board.boardTiles[5][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .green))
        var sequenceDetector = SequenceDetector(board: board)
        
        // Function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (5, 1),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        
        // expectation
        #expect(!isSequenceComplete && gameState.detectedSequence.isEmpty)
   
    }
    
    @Test("detectSequence returns false for less than 5 matching chips digonally")
    func testDetectSequence_lessThan5gChipsDigonally_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[1][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[2][2] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[3][3] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][4] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .green))
        board.boardTiles[5][5] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .green))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (5, 5),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        
        // expectation
        #expect(!isSequenceComplete && gameState.detectedSequence.isEmpty)
    }
    
    @Test("detectSequence returns false for less than 5 matching chips Antidiagonally")
    func testDetectSequence_lessThan5MatchingChipsAntidiagonal_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[9][9] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[8][8] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .green))
        board.boardTiles[7][7] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .green))
        board.boardTiles[6][6] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[5][5] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][4] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (5, 5),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        
        // expectation
        #expect(!isSequenceComplete && gameState.detectedSequence.isEmpty)
    }
    
    @Test("detectSequence returns true for 5 matching chips in a column when 3 chips are same horizonatally")
    func testDetectSequence_5MatchingChipsInAColumn3MatchingHorizontally_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[1][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][2] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][3] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[2][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[3][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[5][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (5, 1),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        
        // expectation
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
    }
    
    @Test("detectSequence returns true for 5 matching chips digonally with three matching horizonatally and vertically")
    func testDetectSequence_5MatchingChipsDigonally3matchinghorizonatallyAndVertically_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[1][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][2] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][3] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[2][2] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[2][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[3][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[3][3] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][4] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[5][5] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (5, 5),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        // expectation
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
    }
    
    @Test("detectSequence returns true for 5 matching chips in a row, starting position is in-between")
    func testDetectSequence_5MatchingChipsInARowPositionIsInBetween_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[1][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][2] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][3] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][4] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][5] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (1, 2),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        // expectation
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
   
    }
    
    @Test("detectSequence returns true for 5 matching chips in a column, starting position is in-between")
    func testDetectSequence_5MatchingChipsInAColumnPositionIsInBetween_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[1][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[2][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[3][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[5][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (3, 1),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        
        // expectation
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
   
    }
    
    @Test("detectSequence returns true for 5 matching chips digonally, starting position is in-between")
    func testDetectSequence_5MatchingChipsDigonallyPositionInBetween_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[1][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[2][2] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[3][3] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][4] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[5][5] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (2, 2),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        // expectation
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
    }
    
    @Test("detectSequence returns true for 5 matching chips Antidiagonally, starting position is in-between")
    func testDetectSequence_5MatchingChipsAntidiagonalPositionInBetween_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[9][9] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[8][8] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[7][7] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[6][6] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[5][5] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][4] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (6, 6),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        
        // expectatiom
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
    }
    
    @Test("detectSequence returns true for 5 matching chips digonally when col decreases and row increases")
    func testDetectSequence_5MatchingChipsdigonallyColDecreasesRowIncreases_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[0][4] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][3] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[2][2] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[3][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][0] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (4, 0),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        
        // expectatiom
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
    }
    
    @Test("detectSequence returns true for 5 matching chips digonally when col decreases and row increases starting position in between")
    func testDetectSequence_5MatchingChipsdigonallyColDecreasesRowIncreasesPositionInBetween_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[0][4] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][3] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[2][2] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[3][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][0] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (2, 2),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        // expectatiom
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
    }
    
    @Test("detectSequence returns true for 5 matching chips in a row starting from corner position")
    func testDetectSequence_5MatchingChipsInARowStartInCorner_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[0][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[0][2] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[0][3] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[0][4] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (0, 0),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        // expectation
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
   
    }
    
    @Test("detectSequence returns true for 5 matching chips in a column, starting from corner position")
    func testDetectSequence_5MatchingChipsInAColumnStartInCorner_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[1][0] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[2][0] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[3][0] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][0] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (0, 0),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        
        // expectation
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
   
    }
    
    @Test("detectSequence returns true for 5 matching chips digonally, starting from corner position")
    func testDetectSequence_5MatchingChipsDigonallyStartingInCorner_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[1][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[2][2] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[3][3] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][4] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (0, 0),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        // expectation
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
    }
    
    @Test("detectSequence returns true for 5 matching chips Antidiagonally, starting From right bottom corner")
    func testDetectSequence_5MatchingChipsAntidiagonalStartinBottomRightCorner_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[9][9] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[8][8] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[7][7] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[6][6] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[5][5] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (9, 9),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        
        // expectatiom
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
    }
    
    @Test("detectSequence returns true for 5 matching chips digonally starting from right top corner")
    func testDetectSequence_5MatchingChipsdigonallyStartinRightTopCorner_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][9] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[1][8] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[2][7] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[3][6] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][5] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (0, 9),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        
        // expectatiom
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
    }
    
    @Test("detectSequence returns true for 5 matching chips digonally starting from bottom left corner")
    func testDetectSequence_5MatchingChipsdigonallyStartInBottomLeftCorner_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[9][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[8][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[7][2] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[6][3] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[5][4] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (9, 0),
                                                                  forPlayer: currentPlayer, gameState: gameState)
        // expectatiom
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
    }
    
    @Test("detectSequence returns true for 5 matching chips multiple times")
    func testDetectSequence_5MatchingChipsMultipleTimes_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[9][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[8][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[7][2] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[6][3] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[5][4] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][0] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[2][0] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[3][0] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][0] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[5][0] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (9, 0), forPlayer: currentPlayer, gameState: gameState)
        let isSequenceComplete2  = sequenceDetector.detectSequence(atPosition: (1, 0), forPlayer: currentPlayer, gameState: gameState)
        // expectatiom
        #expect(isSequenceComplete && isSequenceComplete2 && gameState.detectedSequence.count == 2)
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
        guard let secondSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(secondSequence.teamColor == .blue)
    }
    
    @Test("detectSequence returns true for 5 matching chips multiple times overlapping")
    func testDetectSequence_5MatchingChipsMultipleTimesOverlapping_returnsTrue() {
        // setup
        let gameState = GameState()
        var board = Board(row: 10, col: 10)
        let currentPlayer = Player(name: "Player 0", team: Team(color: .blue, numberOfPlayers: 2))
        board.boardTiles[0][0] = BoardTile(card: nil, isEmpty: true, isChipOn: false, chip: nil)
        board.boardTiles[0][1] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[0][2] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[0][3] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[0][4] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[1][0] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[2][0] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[3][0] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        board.boardTiles[4][0] = BoardTile(card: Card(cardFace: .ace, suit: .clubs), isEmpty: false, isChipOn: true, chip: Chip(color: .blue))
        var sequenceDetector = SequenceDetector(board: board)
        
        // function call
        let isSequenceComplete  = sequenceDetector.detectSequence(atPosition: (4, 0), forPlayer: currentPlayer, gameState: gameState)
        let isSequenceComplete2  = sequenceDetector.detectSequence(atPosition: (0, 4), forPlayer: currentPlayer, gameState: gameState)
        // expectatiom
        #expect(isSequenceComplete && isSequenceComplete2 && gameState.detectedSequence.count == 2)
        #expect(isSequenceComplete && gameState.detectedSequence.count == 1)
        guard let firstSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(firstSequence.teamColor == .blue)
        guard let secondSequence = gameState.detectedSequence.first else {
            #expect(Bool(false), "Expected detected sequence"); return
        }
        #expect(secondSequence.teamColor == .blue)
    }
}
// swiftlint:enable type_body_length
