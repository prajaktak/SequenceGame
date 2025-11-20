# Architecture Documentation

**Project:** Sequence Game  
**Platform:** iOS (SwiftUI)  
**Language:** Swift  
**Architecture Pattern:** MVVM (Model-View-ViewModel) with Observable State  
**Last Updated:** 2025-11-20

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture Layers](#architecture-layers)
3. [Data Flow](#data-flow)
4. [Module Responsibilities](#module-responsibilities)
5. [Key Design Decisions](#key-design-decisions)
6. [State Management](#state-management)
7. [Platform Separation](#platform-separation)
8. [Testing Strategy](#testing-strategy)

---

## Overview

The Sequence Game is built using **SwiftUI** with a **single source of truth** pattern. The architecture follows Apple's modern SwiftUI best practices, emphasizing:

- **Unidirectional data flow**
- **Platform-agnostic models**
- **Observable state management**
- **Separation of concerns**
- **Testable business logic**

### High-Level Architecture

```
┌─────────────────────────────────────────────────────┐
│                    SwiftUI Views                     │
│  (GameView, BoardView, HandView, Overlays, etc.)   │
└────────────────┬────────────────────────────────────┘
                 │ @EnvironmentObject
                 │ (Observe)
                 ▼
┌─────────────────────────────────────────────────────┐
│              GameState (Observable)                  │
│         Single Source of Truth (@Published)         │
└────────────────┬────────────────────────────────────┘
                 │ Uses
                 ▼
┌─────────────────────────────────────────────────────┐
│           Business Logic (Platform-Agnostic)        │
│  BoardManager, SequenceDetector, CardPlayValidator │
└────────────────┬────────────────────────────────────┘
                 │ Operates on
                 ▼
┌─────────────────────────────────────────────────────┐
│              Models (Value Types)                    │
│  Card, Player, Team, BoardTile, Position, etc.     │
└─────────────────────────────────────────────────────┘
```

---

## Architecture Layers

### 1. **Model Layer** (Platform-Agnostic)

**Location:** `SequenceGame/Models/`

**Purpose:** Define pure data structures with no UI dependencies.

**Key Types:**
- `Card` - Represents a playing card (rank + suit)
- `Player` - Player information and hand
- `Team` - Team configuration
- `BoardTile` - Single tile on game board
- `Board` - Game board structure (10×10 grid)
- `Position` - Board coordinate with validation
- `TeamColor` - Platform-agnostic team color enum
- `Chip` - Chip placement data

**Characteristics:**
- ✅ Value types (`struct`, `enum`)
- ✅ No `import SwiftUI`
- ✅ Platform-agnostic (could run on macOS, server, etc.)
- ✅ Conform to `Codable`, `Equatable`, `Identifiable` where appropriate
- ✅ Testable without UI framework

**Example:**
```swift
struct Card: Identifiable, Equatable {
    let id = UUID()
    let cardFace: CardFace
    let suit: Suit
}

enum TeamColor: Codable, CaseIterable {
    case blue, green, red, noTeam
}
```

---

### 2. **Business Logic Layer** (Platform-Agnostic)

**Location:** `SequenceGame/Managers/`, `SequenceGame/Validators/`, `SequenceGame/Detectors/`

**Purpose:** Implement game rules and logic without UI concerns.

**Key Components:**

#### **BoardManager**
- Initializes game board
- Handles chip placement and removal
- Manages board state mutations

#### **SequenceDetector**
- Detects 5-in-a-row sequences
- Handles horizontal, vertical, diagonal detection
- Considers corner tiles and chip ownership

#### **CardPlayValidator**
- Validates card placement rules
- Handles Jack card special rules:
  - Two-eyed Jacks (clubs/diamonds): Wild cards
  - One-eyed Jacks (hearts/spades): Remove opponent chips
- Checks position validity and occupation status

**Characteristics:**
- ✅ Pure Swift logic
- ✅ No UI dependencies
- ✅ Fully unit-testable
- ✅ Deterministic behavior
- ✅ Single Responsibility Principle

---

### 3. **State Management Layer**

**Location:** `SequenceGame/GameState.swift`

**Purpose:** Single source of truth for all game state.

**GameState** is an `ObservableObject` that:
- Manages all game state (`@Published` properties)
- Orchestrates business logic components
- Provides computed properties for derived state
- Handles user actions (card selection, chip placement)
- Enforces turn progression
- Evaluates win conditions

**Published State:**
```swift
@Published var players: [Player]
@Published var currentPlayerIndex: Int
@Published var boardTiles: [[BoardTile]]
@Published var selectedCardId: UUID?
@Published var detectedSequence: [Sequence]
@Published var winningTeam: TeamColor?
@Published var overlayMode: GameOverlayMode
```

**Key Methods:**
- `startGame(with:)` - Initialize new game
- `selectCard(_:)` - Handle card selection
- `performPlay(atPos:using:)` - Execute card play
- `advanceTurn()` - Move to next player
- `evaluateGameState()` - Check win conditions

**Characteristics:**
- ✅ Reference type (`class`)
- ✅ Observable by SwiftUI views
- ✅ Single instance shared via `@EnvironmentObject`
- ✅ Coordinates between business logic and UI

---

### 4. **View Layer** (SwiftUI)

**Location:** `SequenceGame/Views/`

**Purpose:** Present UI and handle user interactions.

**View Hierarchy:**

```
SequenceGameApp (App Entry Point)
└── MainMenuView
    ├── GameSettingsView
    └── GameView ← Main game screen
        ├── GameOverlayView (Turn info, instructions)
        ├── BoardView (10×10 game board)
        │   └── TileView (Individual tiles)
        │       └── CardFaceView, ChipView
        ├── HandView (Player's hand)
        └── SeatingRingOverlay (Player seating)
```

**View Principles:**
- ✅ Read state from `@EnvironmentObject var gameState: GameState`
- ✅ Call GameState methods for actions
- ✅ No business logic in views
- ✅ Stateless where possible (derive from GameState)
- ✅ Each view has `#Preview` for development

**Example:**
```swift
struct BoardView: View {
    @EnvironmentObject var gameState: GameState
    
    var body: some View {
        // Renders gameState.boardTiles
        // Calls gameState.performPlay() on tap
    }
}
```

---

### 5. **Theme Layer**

**Location:** `SequenceGame/Views/Theme/`

**Purpose:** Centralized styling and theming.

**Components:**
- `ThemeColor` - Color palette with semantic names
- `GameConstants.UISizing` - Layout constants
- `GameConstants.Animation` - Animation timing
- Button styles (`PrimaryButtonStyle`, `SecondaryButtonStyle`)

**Mapping Functions:**
- `ThemeColor.getTeamColor(for:)` - Maps `TeamColor` → `SwiftUI.Color`

**Benefits:**
- ✅ Consistent visual design
- ✅ Easy theme changes
- ✅ Semantic naming (not just hex codes)
- ✅ Centralized constants

---

## Data Flow

### Unidirectional Data Flow

```
User Action (Tap, Swipe)
        ↓
   SwiftUI View
        ↓
   Calls GameState Method
        ↓
   GameState Updates (@Published)
        ↓
   Business Logic Executes
        ↓
   State Changes Propagate
        ↓
   SwiftUI Re-renders
```

### Example: Playing a Card

1. **User taps tile** in `BoardView`
2. **View calls** `gameState.performPlay(atPos:using:)`
3. **GameState:**
   - Removes card from hand
   - Validates placement (`CardPlayValidator`)
   - Places chip (`BoardManager`)
   - Detects sequences (`SequenceDetector`)
   - Checks win condition
   - Draws replacement card
   - Advances turn
4. **State changes** trigger view updates automatically
5. **UI re-renders** with new state

---

## Module Responsibilities

### Models (Data)
- ✅ Define data structures
- ✅ Value semantics
- ✅ No business logic
- ❌ No UI code
- ❌ No dependencies on other layers

### Business Logic (Rules)
- ✅ Implement game rules
- ✅ Validate actions
- ✅ Detect game conditions
- ❌ No UI code
- ❌ No direct state mutation (returns results)

### GameState (Orchestration)
- ✅ Manage game state
- ✅ Coordinate business logic
- ✅ Handle user actions
- ✅ Publish state changes
- ❌ No UI code (no SwiftUI imports)

### Views (Presentation)
- ✅ Render UI
- ✅ Handle user input
- ✅ Observe GameState
- ❌ No business logic
- ❌ No direct model mutation

---

## Key Design Decisions

### 1. **Platform-Agnostic Models**

**Decision:** Keep models free of UI dependencies.

**Why:**
- Models can be tested without UI framework
- Could port to macOS, server, or other platforms
- Clearer separation of concerns
- Easier to reason about data structures

**Implementation:**
- No `import SwiftUI` in model files
- Use `TeamColor` enum instead of `SwiftUI.Color`
- Map to UI colors in theme layer

---

### 2. **Single Source of Truth (GameState)**

**Decision:** All game state lives in one `GameState` instance.

**Why:**
- No state synchronization bugs
- Clear data ownership
- Predictable state changes
- Easy to debug (one place to inspect)

**Implementation:**
- `GameState` as `@EnvironmentObject`
- All views read from same instance
- No local state duplication

---

### 3. **Observable Object Pattern**

**Decision:** Use `@Published` properties with `ObservableObject`.

**Why:**
- Native SwiftUI pattern
- Automatic view updates
- Compile-time safety
- No manual notification code

**Trade-offs:**
- Reference type (not value type)
- Main thread updates required
- Fine-grained updates challenging

---

### 4. **Value Types for Models**

**Decision:** Use `struct` and `enum` for models, not `class`.

**Why:**
- Value semantics prevent unintended sharing
- Easier to reason about changes
- Thread-safe by default
- Better performance in many cases

**Example:**
```swift
struct Card: Identifiable, Equatable {
    // Copied when passed, not shared
}
```

---

### 5. **Computed Properties over Stored State**

**Decision:** Derive state from published properties when possible.

**Why:**
- Reduces state duplication
- Automatic consistency
- Fewer bugs from stale data

**Example:**
```swift
var currentPlayer: Player? {
    guard players.indices.contains(currentPlayerIndex) else { return nil }
    return players[currentPlayerIndex]
}
```

---

### 6. **Separation of Validation and Execution**

**Decision:** Validators check rules, managers execute changes.

**Why:**
- Clear responsibility separation
- Testable validation logic
- Reusable validators
- Predictable side effects

**Example:**
```swift
// Validate
let validator = CardPlayValidator(boardTiles: tiles, detectedSequences: sequences)
guard validator.canPlace(at: pos, for: card) else { return }

// Execute
boardManager.placeChip(at: pos, teamColor: teamColor, tiles: &boardTiles)
```

---

## State Management

### Published Properties

**GameState publishes:**
- `players` - Player roster
- `currentPlayerIndex` - Active player
- `boardTiles` - Board state
- `selectedCardId` - UI selection state
- `detectedSequence` - Found sequences
- `winningTeam` - Victory state
- `overlayMode` - UI mode

### Computed Properties

**Derived state (not stored):**
- `currentPlayer` - From `currentPlayerIndex`
- `requiredSequencesToWin` - Based on player count
- `validPositionsForSelectedCard` - Computed on demand
- `hasSelection` - From `selectedCardId`

### State Transitions

**Turn Flow:**
```
.turnStart → User selects card → .cardSelected
           → User plays card → Chip placed → Sequences detected
           → Win checked → Turn advanced → .turnStart
```

**Overlay Modes:**
- `.turnStart` - Player's turn begins
- `.cardSelected` - Card selected, showing valid moves
- `.deadCard` - Card has no valid moves
- `.postPlacement` - After successful play
- `.gameOver` - Game completed

---

## Platform Separation

### Why Separate Platform Code?

**Models are platform-agnostic** to enable:
- Unit testing without UI framework
- Potential cross-platform reuse
- Clear architectural boundaries
- Independent evolution of UI and logic

### TeamColor vs ThemeColor

**TeamColor (Model):**
```swift
// In Models/ (platform-agnostic)
enum TeamColor: Codable {
    case blue, green, red, noTeam
}
```

**ThemeColor (UI):**
```swift
// In Views/Theme/ (SwiftUI-specific)
enum ThemeColor {
    static func getTeamColor(for teamColor: TeamColor) -> Color {
        switch teamColor {
        case .blue: return Color("teamBlue")
        case .green: return Color("teamGreen")
        case .red: return Color("teamRed")
        case .noTeam: return Color.gray
        }
    }
}
```

**Mapping happens in view layer**, keeping models clean.

---

## Testing Strategy

### Unit Tests

**What we test:**
- Model logic (Card, Player, Team)
- Business logic (validators, detectors, managers)
- GameState methods
- Computed properties
- Edge cases and boundary conditions

**Example:**
```swift
@Test("advanceTurn wraps around to first player")
func testAdvanceTurnWrapsAround() {
    let state = createTestGameState()
    state.advanceTurn()
    state.advanceTurn()
    #expect(state.currentPlayerIndex == 0)
}
```

### Test Files

- `GameStateTests.swift` - GameState functionality (53 tests)
- `SequenceDetectorTests.swift` - Sequence detection logic
- `SequenceGameTests.swift` - General game logic
- `DeckTests.swift` - Deck operations

### Testing Principles

- ✅ **One behavior per test** (CODING_CONVENTIONS.md)
- ✅ **Descriptive test names**
- ✅ **No UI testing** (focus on logic)
- ✅ **Swift Testing framework** (`@Test`, `#expect`)
- ✅ **Helper functions** to reduce duplication

---

## Project Structure

```
SequenceGame/
├── SequenceGameApp.swift          # App entry point
├── Models/                         # Platform-agnostic data
│   ├── Card.swift
│   ├── Player.swift
│   ├── Team.swift
│   ├── TeamColor.swift            # Model enum
│   ├── BoardTile.swift
│   ├── Board.swift
│   ├── Position.swift
│   ├── Chip.swift
│   └── ...
├── Views/                          # SwiftUI views
│   ├── GameView.swift             # Main game screen
│   ├── BoardView.swift            # Game board
│   ├── HandView.swift             # Player hand
│   ├── TileView.swift             # Board tile
│   ├── GameOverlay/
│   │   └── GameOverlayView.swift
│   ├── Theme/
│   │   ├── ThemeColor.swift       # UI color mapping
│   │   ├── PrimaryButtonStyle.swift
│   │   └── SecondaryButtonStyle.swift
│   └── ...
├── Managers/                       # Business logic
│   ├── BoardManager.swift
│   └── ...
├── Validators/
│   └── CardPlayValidator.swift
├── Detectors/
│   └── SequenceDetector.swift
├── GameState.swift                 # State management
├── GameConstants.swift             # Constants
└── ...

SequenceGameTests/
├── GameStateTests.swift
├── SequenceDetectorTests.swift
├── SequenceGameTests.swift
└── DeckTests.swift
```

---

## Best Practices

### Do's ✅

- ✅ Keep models platform-agnostic (no SwiftUI imports)
- ✅ Use single source of truth (GameState)
- ✅ Prefer value types (struct, enum)
- ✅ Compute derived state instead of storing
- ✅ Test business logic thoroughly
- ✅ Use semantic naming for constants
- ✅ Follow Single Responsibility Principle
- ✅ Keep views stateless where possible

### Don'ts ❌

- ❌ Import SwiftUI in model files
- ❌ Duplicate state between views and GameState
- ❌ Put business logic in views
- ❌ Use force unwrapping without guards
- ❌ Mix UI and business logic
- ❌ Store computed values as state
- ❌ Create deep class hierarchies
- ❌ Test UI directly (test logic instead)

---

## Future Considerations

### Potential Enhancements

1. **Networking Layer**
   - Multiplayer support
   - Platform-agnostic models ready for serialization

2. **Persistence Layer**
   - Save/load game state
   - Models already `Codable`

3. **Analytics/Logging**
   - Track game events
   - Clear state transitions to instrument

4. **AI Opponents**
   - Evaluate positions
   - Platform-agnostic validators make this easier

5. **Accessibility**
   - Already started with VoiceOver labels
   - Expand to other accessibility features

---

## References

### Apple Documentation

- [SwiftUI Architecture](https://developer.apple.com/documentation/swiftui)
- [State and Data Flow](https://developer.apple.com/documentation/swiftui/state-and-data-flow)
- [Model Data](https://developer.apple.com/documentation/swiftui/model-data)
- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)

### Project Documentation

- `CODING_CONVENTIONS.md` - Coding standards
- `COMMUNICATION_RULES.md` - Development workflow
- `TODO_FROM_CODE_REVIEWS_2025-11-20.md` - Current tasks

---

## Glossary

**Terms used in this architecture:**

- **Platform-Agnostic** - Code that doesn't depend on UI framework (SwiftUI)
- **Single Source of Truth** - One authoritative location for each piece of state
- **Observable Object** - Swift/SwiftUI pattern for publishing state changes
- **Value Type** - `struct` or `enum` with copy semantics (not reference)
- **Reference Type** - `class` with shared reference semantics
- **Unidirectional Data Flow** - Data flows one direction: action → state → view
- **Computed Property** - Property calculated from other state, not stored
- **Business Logic** - Game rules and logic, independent of UI

---

**Document Version:** 1.0  
**Last Updated:** 2025-11-20  
**Maintainer:** Sequence Game Team

---

*For questions or clarifications about this architecture, refer to the code review reports or documentation in the project root.*
