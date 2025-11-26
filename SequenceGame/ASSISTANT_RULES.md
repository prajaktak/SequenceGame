# Assistant Rules - SequenceGame

## Code Style
- Swift Testing ONLY: `@Test`, `@Suite`, `#expect()`, `Issue.record()` (NO XCTest in unit tests)
- One type per file, descriptive file names
- Test names: `testFunction_condition_expectedResult` with underscores
- One behavior per test, no guards in tests, hardcode test data
- No abbreviations: `rowIndex` not `i`, descriptive names always
- Single Responsibility: each function/class does ONE thing
- Error handling: `do-catch` with `Issue.record()` on unexpected errors
- Value types (`struct`) for models, `ObservableObject` for state

## Project Structure
- **GameState**: Observable, main game manager (players, board, deck, turns)
- **Board**: 10x10 grid, corners are wild
- **Teams**: Blue/Green/Red via TeamColor enum
- **Players**: Array in turn order, hold cards
- **GameConstants**: Static config (board size, cards per player)
- **Tests**: Use helpers like `createTestGameState()`, `createFourPlayerGameState()`

## Communication
- Concise, code-first, practical solutions only
- Provide documentation links for all suggestions/claims
- **DO NOT modify code** unless user says: "do changes in code"
- "How to" questions = explain + example code, DON'T create files (ask first)
- When user asks "let's fix together" = guide only, no direct edits
- Error reports: analyze → explain → suggest → ask permission to fix

## Common Patterns
- Properties: `@Published` in GameState (ObservableObject)
- Card dealing: Via `deck.drawCards()`
- Game flow: startGame() → turns → detectSequence() → checkWin()
- Reset: `resetGame()` clears all, `restartGame()` keeps players

## Project Type
- macOS/iOS board game (Sequence)
- SwiftUI views + observable state
- Turn-based multiplayer
