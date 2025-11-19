# SequenceGame Project Gist

**Project Name:** SequenceGame  
**Platform:** iOS  
**Framework:** SwiftUI  
**Language:** Swift  
**Last Updated:** November 19, 2025  
**Status:** Active Development - CI Tests Passing ✅

---

## 📋 Executive Summary

SequenceGame is an iOS implementation of the classic board game "Sequence" built using SwiftUI. The app features a strategic card-based board game where 2-12 players compete to form sequences of five chips in a row on a 10×10 game board. Players use playing cards to place chips on corresponding board positions, with special Jack cards providing strategic advantages.

---

## 🎯 Project Overview

### What is Sequence?
Sequence is a strategy board game where:
- Players place chips on a board using playing cards
- Goal: Form sequences of 5 chips in a row (horizontal, vertical, or diagonal)
- **Two-eyed Jacks** (♣️ ♦️): Wild cards - place chip anywhere
- **One-eyed Jacks** (♥️ ♠️): Remove opponent's chip (except from completed sequences)
- Corner spaces are wild - count as chips for all players

### Win Conditions
- **2 players:** Need 2 sequences to win
- **3+ players:** Need 1 sequence to win

---

## 🏗️ Architecture

### Design Pattern
- **SwiftUI + Observable Pattern**: Using `@Published` properties in `ObservableObject`
- **Single Source of Truth**: `GameState` class manages all game state
- **Value Types**: Extensive use of `struct` for models (Card, Player, BoardTile, etc.)
- **Protocol-Oriented**: Separation of concerns with focused responsibilities

### Core Principles (from CODING_CONVENTIONS.md)
1. **One Type Per File**: Each enum, struct, or class in its own file
2. **Test-Driven Development (TDD)**: One behavior per test
3. **Single Responsibility Principle**: Each function/class does ONE thing
4. **No Abbreviations**: Descriptive names (e.g., `rowIndex`, not `i`)
5. **Separation of Concerns**: Dedicated functions, no mixing responsibilities

---

## 📂 Project Structure

```
SequenceGame/
├── Models/
│   ├── Card.swift               # Card with face and suit
│   ├── CardFace.swift           # Enum: ace, two, ..., king
│   ├── Suit.swift               # Enum: hearts, spades, diamonds, clubs
│   ├── Player.swift             # Player with name, team, cards
│   ├── Team.swift               # Team with color and player count
│   ├── BoardTile.swift          # Board position with card and chip
│   ├── Chip.swift               # Chip placed on board
│   ├── Deck.swift               # Standard 52-card deck
│   ├── DoubleDeck.swift         # Two decks for gameplay
│   ├── Board.swift              # 10×10 game board
│   ├── GameState.swift          # Central game state manager
│   ├── SequenceDetector.swift   # Detects 5-in-a-row sequences
│   ├── CardPlayValidator.swift  # Validates card plays
│   └── GameResult.swift         # Win/ongoing game results
│
├── Views/
│   ├── MainMenu.swift           # Entry point menu
│   ├── GameSettingsView.swift  # Setup: players, teams
│   ├── GameView.swift           # Main game screen
│   ├── BoardView.swift          # 10×10 board display
│   ├── HandView.swift           # Player's card hand
│   ├── GameOverlayView.swift   # Turn/instruction overlays
│   └── [Other UI Components]
│
├── Utilities/
│   ├── GameConstants.swift      # Constants (sizing, colors, rules)
│   └── ThemeColor.swift         # App-wide color theme
│
└── Tests/
    ├── SequenceGameTests/       # Unit tests
    └── SequenceGameUITests/     # UI tests
```

---

## 🎮 Core Components

### 1. GameState (Heart of the App)
**File:** `GameState.swift`  
**Type:** `final class` conforming to `ObservableObject`

**Responsibilities:**
- Manages all game state (@Published properties)
- Orchestrates turns and gameplay flow
- Validates moves and detects sequences
- Determines win conditions

**Key Properties:**
```swift
@Published var players: [Player]
@Published var currentPlayerIndex: Int
@Published var boardTiles: [[BoardTile]]
@Published var selectedCardId: UUID?
@Published var overlayMode: GameOverlayMode
@Published var detectedSequence: [Sequence]
@Published var winningTeam: Color?
private(set) var deck: DoubleDeck
```

**Key Methods:**
- `startGame(with:)` - Initialize game with players
- `performPlay(atPos:using:)` - Main play orchestration
- `selectCard(_:)` - Handle card selection
- `advanceTurn()` - Move to next player
- `evaluateGameState()` - Check win conditions
- `computePlayableTiles(for:)` - Find valid positions

### 2. Card System

#### Card (`Card.swift`)
```swift
struct Card: Identifiable, Equatable {
    let id: UUID
    let cardFace: CardFace  // ace, two, ..., king
    let suit: Suit          // hearts, spades, diamonds, clubs
}
```

#### CardFace Enum
- Standard playing card faces: ace, two, three, ..., king
- Special: jack (strategic card)
- Empty (for corner tiles)

#### Suit Enum
- hearts, spades, diamonds, clubs (standard suits)
- empty (for corner tiles)
- Each suit has color and system image

#### Special Jack Rules
- **Two-Eyed Jacks** (♣️ Clubs, ♦️ Diamonds): Place chip anywhere
- **One-Eyed Jacks** (♥️ Hearts, ♠️ Spades): Remove opponent's chip
- Implemented in `CardPlayValidator`

### 3. Player & Team System

#### Player (`Player.swift`)
```swift
struct Player: Identifiable {
    let id: UUID
    var name: String
    let team: Team
    var isPlaying: Bool
    var cards: [Card]
}
```

#### Team (`Team.swift`)
```swift
struct Team: Identifiable {
    var id: UUID
    var color: Color        // Team chip color
    var numberOfPlayers: Int
}
```

**Team Colors:**
- Blue, Green, Red (from `ThemeColor`)
- Up to 3 teams per game

### 4. Board System

#### Board (`Board.swift`)
- 10×10 grid of tiles
- Corner positions are "wild spaces"
- Manages tile setup with double deck

#### BoardTile (`BoardTile.swift`)
```swift
struct BoardTile: Identifiable {
    let id: UUID
    var card: Card?        // Card image on tile
    var isEmpty: Bool      // Corner tile flag
    var isChipOn: Bool     // Has chip placed
    var chip: Chip?        // Actual chip
}
```

#### Chip (`Chip.swift`)
- Represents chip placed on board
- Has team color and position
- `isPlaced` flag for tracking

### 5. Deck System

#### Deck (`Deck.swift`)
- Standard 52-card deck
- Methods: `resetDeck()`, `shuffle()`, `drawCard()`
- Special: `drawCardExceptJacks()` for dead card replacement

#### DoubleDeck
- Two decks combined (104 cards total)
- Required for full gameplay
- Handles dealing to multiple players

### 6. Game Logic Validators

#### CardPlayValidator
**Responsibilities:**
- Validates if a card can be played at position
- Classifies Jack types (two-eyed vs one-eyed)
- Checks tile occupation and protection
- Computes all playable positions for a card

**Key Methods:**
```swift
func canPlace(at position: Position, for card: Card) -> Bool
func classifyJack(_ card: Card) -> JackRule?
func computePlayableTiles(for card: Card) -> [Position]
```

#### SequenceDetector
**Responsibilities:**
- Detects completed 5-in-a-row sequences
- Checks horizontal, vertical, diagonal patterns
- Validates sequence belongs to single team
- Prevents duplicate sequence detection

**Detection Logic:**
- Checks 8 directions from each placed chip
- Validates consecutive chips of same team
- Wild corners count for any team

### 7. Game Result System

#### GameResult Enum
```swift
enum GameResult {
    case win(team: Color)
    case ongoing
}
```

#### GameOverlayMode Enum
```swift
enum GameOverlayMode {
    case turnStart        // "Your turn" prompt
    case cardSelected     // Show valid positions
    case deadCard         // No valid moves
    case postPlacement    // After successful play
    case gameOver         // Game won
}
```

---

## 🎨 UI/UX Design

### Theme System (`ThemeColor.swift`)
Centralized color palette:
- **Background:** Menu, board, card backgrounds
- **Accent:** Primary, secondary, tertiary gradients
- **Team Colors:** Blue, green, red chips
- **Text:** Primary, secondary, on-accent
- **Card Elements:** Borders, shadows, highlights

### Key Views

#### MainMenu
- Navigation hub
- Options: New Game, Resume, How to Play, Settings, About
- Gradient background with menu buttons

#### GameSettingsView
- Player configuration (2-12 players)
- Team assignment
- Player names
- Validates and starts game

#### GameView
- Main game screen
- Contains: BoardView (top), HandView (bottom)
- Overlay system for instructions
- Win screen display

#### BoardView
- 10×10 grid of tiles
- Interactive tile tapping
- Visual indicators for valid positions
- Highlights completed sequences
- Animated chip placement

#### HandView
- Current player's cards
- Horizontal scroll view
- Card selection with visual feedback
- Selected card highlighted and scaled

#### GameOverlayView
- Adaptive overlay based on game state
- Turn instructions
- Valid position hints
- Dead card replacement
- Win celebration

---

## 🧪 Testing Strategy

### Testing Framework
- **Unit Tests:** Swift Testing Framework (`@Test` macro)
- **UI Tests:** XCTest (XCUITest)

### Testing Principles (from CODING_CONVENTIONS.md)
1. **One Behavior Per Test**: Each test validates ONE thing
2. **Descriptive Names**: `testFunction_condition_expectedResult`
3. **No Guards in Tests**: Hardcode test data
4. **TDD Workflow**: Write failing test → implement → refactor

### Test Examples
```swift
@Test("Jack classification: clubs → placeAnywhere")
func jackClassification_clubs_returnsPlaceAnywhere() {
    let gameState = GameState()
    let jackOfClubs = Card(cardFace: .jack, suit: .clubs)
    #expect(gameState.classifyJack(jackOfClubs) == .placeAnywhere)
}

@Test("placeChip sets chip at position")
func testPlaceChip_setsChip() {
    state.placeChip(at: (row: 3, col: 3), teamColor: .blue)
    let tile = state.boardTiles[3][3]
    #expect(tile.isChipOn == true)
}
```

### Current Test Status
- **UI Tests:** Passing ✅ (as of Nov 19, 2025)
- Previously failing due to Simulator installation issue
- Resolved with CI configuration fixes

---

## 🚀 CI/CD Configuration

### GitHub Actions Setup
**Runner:** `macos-15`  
**Xcode:** 16.1  
**Simulator:** iPhone 16, iOS 18.1

### CI Workflow Files
1. **`ci_claude.yml`** - Research-backed robust configuration
   - Dynamic simulator discovery
   - Comprehensive error handling
   - Multiple job options (dynamic + simple)
   - Pre-boot simulator step

2. **`ci_composer.yml`** - Streamlined simple configuration
   - Explicit simulator specification
   - `showdestinations` validation
   - Unique artifact naming
   - **Recommended for this project** ⭐

### CI Analysis (from CI_COMPARISON_ANALYSIS.md)
**Winner:** `ci_composer.yml` (92% score vs 78%)

**Why:**
- Simpler, faster execution
- Proactive environment validation
- Better artifact management
- Perfect for stable GitHub-hosted runners

### Key CI Features
- Automated testing on push/PR
- Code coverage enabled
- Test result artifacts
- Build validation
- No code signing (test-only builds)

---

## 📐 Game Constants

### Board
- **Dimensions:** 10×10 grid
- **Corner Positions:** (0,0), (0,9), (9,0), (9,9) - Wild spaces
- **Sequence Length:** 5 chips in a row

### Players
- **Min Players:** 2
- **Max Players:** 12
- **Max Teams:** 3

### Cards Per Player (from GameConstants)
| Player Count | Cards |
|--------------|-------|
| 2            | 7     |
| 3, 4         | 6     |
| 6            | 5     |
| 8, 9         | 4     |
| 10, 12       | 3     |

### Win Conditions
- **2 players:** 2 sequences required
- **3+ players:** 1 sequence required

---

## 🎯 Gameplay Flow

### 1. Game Setup
```
GameSettingsView → Configure players/teams → Start Game
↓
GameState.startGame(with:)
- Shuffle double deck
- Deal cards to players
- Setup 10×10 board
- Set first player
```

### 2. Turn Flow
```
Player's Turn (overlayMode: .turnStart)
↓
Player selects card (overlayMode: .cardSelected)
↓
Valid positions highlighted on board
↓
Player taps board position
↓
GameState.performPlay(atPos:using:)
  1. Remove card from hand
  2. Validate placement
  3. Place/remove chip (depending on jack type)
  4. Detect sequences
  5. Check win condition
  6. Draw replacement card
  7. Advance to next player
↓
Next Player's Turn OR Game Over
```

### 3. Card Play Logic
```
Regular Card:
  → Find matching tile(s) on board
  → Check tile not occupied
  → Check tile not in completed sequence
  → Place team chip

Two-Eyed Jack (♣️ ♦️):
  → Can place on ANY unoccupied tile
  → Cannot place on completed sequence tiles

One-Eyed Jack (♥️ ♠️):
  → Remove opponent's chip
  → Cannot remove from completed sequence
  → Cannot remove from corner tiles
```

### 4. Sequence Detection
```
After chip placement:
  SequenceDetector.detectSequence()
  → Check 8 directions (horizontal, vertical, 4 diagonals)
  → Validate 5 consecutive chips
  → All chips must be same team
  → Wild corners count for any team
  → Store detected sequence
  
GameState.evaluateGameState()
  → Count sequences per team
  → Check if team reached required sequences
  → Declare winner OR continue game
```

---

## 🔧 Technical Implementation Details

### State Management
**Pattern:** SwiftUI Observable Object Pattern

```swift
// Views observe GameState
@EnvironmentObject var gameState: GameState

// GameState publishes changes
@Published var boardTiles: [[BoardTile]]
@Published var currentPlayerIndex: Int
```

**Benefits:**
- Automatic UI updates on state change
- Single source of truth
- No view-local state duplication

### Separation of Concerns

#### GameState Orchestration
```swift
func performPlay(atPos position: (row: Int, col: Int), using cardId: UUID) {
    // Delegates to specialized functions:
    removeCardFromHand(cardId:)        // Hand management
    placeChip(at:teamColor:)           // Board management
    removeChip(at:)                    // Board management
    drawReplacementForHand()           // Deck management
    advanceTurn()                      // Turn management
    evaluateGameState()                // Win detection
}
```

#### Validation Layer
- **CardPlayValidator**: Validates all moves
- **SequenceDetector**: Detects winning patterns
- **BoardManager**: Manages board state

### Error Handling
- Optional returns for fallible operations
- Guard statements for early exit
- Validation before state mutation
- No force unwrapping

---

## 📝 Coding Standards (from CODING_CONVENTIONS.md)

### File Organization
✅ One type per file  
✅ Descriptive file names matching type names  
✅ Organized by functional area (Models, Views, Utilities)

### Naming Conventions
✅ Descriptive names (no single letters except constants)  
✅ No abbreviations shorter than 3 characters  
✅ Loop variables: `rowIndex`, `columnIndex`, `playerIndex`  
✅ Boolean properties: `isEmpty`, `hasSelection`, `isChipOn`

### Access Control
- Default to `private` or `fileprivate`
- Use `private(set)` for read-only public properties
- Expose only necessary APIs

### SwiftUI Requirements
✅ Every view has `#Preview`  
✅ Use `ThemeColor` for all colors  
✅ No hardcoded colors  
✅ Use environment objects for shared state

### SwiftLint Configuration
- **Line Length:** Warning at 150, error at 200
- **Function Body Length:** Warning at 300, error at 500
- **Cyclomatic Complexity:** Warning at 15, error at 25
- **Zero warnings/errors required**

---

## 🐛 Known Issues & Solutions

### Issue 1: Simulator Not Found (RESOLVED ✅)
**Problem:** CI failing with "Simulator device failed to install"

**Root Cause:** 
- Using `generic/platform=iOS Simulator` for tests
- Generic destinations can't boot for test execution

**Solution Applied:**
- Changed to explicit simulator: `platform=iOS Simulator,name=iPhone 16,OS=18.1`
- Added `showdestinations` validation step
- Updated CI configuration

**Status:** Tests now passing ✅

### Issue 2: Scheme Not Shared
**Problem:** CI can't find scheme

**Solution:**
- Share scheme in Xcode (Product → Scheme → Manage Schemes)
- Commit `.xcscheme` file to git
- Located in `xcshareddata/xcschemes/`

---

## 📚 Documentation Files

### 1. CODING_CONVENTIONS.md
**Purpose:** Coding standards and best practices

**Key Sections:**
- File organization rules
- Testing (TDD) guidelines
- Code style and naming
- Apple Swift API Design Guidelines
- OOP principles (SOLID)
- SwiftLint configuration
- SwiftUI patterns

### 2. GITHUB_ACTIONS_CI_RESEARCH.md
**Purpose:** CI troubleshooting and solutions

**Key Findings:**
- Analysis of "simulator not found" error
- Research from top Swift projects
- 4 solution options with evidence
- macOS 15 runner specifications
- Debugging steps and verification

### 3. XCODE_PROJECT_SETTINGS_FOR_CI.md
**Purpose:** Xcode configuration for CI compatibility

**Critical Settings:**
- Share the scheme (MOST IMPORTANT)
- Configure test action
- Code signing setup
- Deployment target
- Enable testability

### 4. CI_COMPARISON_ANALYSIS.md
**Purpose:** Detailed comparison of CI configurations

**Compares:**
- `ci_claude.yml` vs `ci_composer.yml`
- Scoring across 7 criteria
- Specific strengths and weaknesses
- Recommendations with evidence

**Verdict:** Use `ci_composer.yml` (92% score)

---

## 🔮 Future Enhancements

### Potential Features
1. **Game State Persistence**
   - Save/load game progress
   - Resume game functionality

2. **Multiplayer**
   - Pass-and-play optimization
   - Network multiplayer
   - Game Center integration

3. **AI Opponents**
   - Single-player mode
   - Difficulty levels

4. **Enhanced UI**
   - Animations for chip placement
   - Sound effects
   - Haptic feedback
   - Dark mode optimization

5. **Statistics**
   - Game history
   - Win/loss tracking
   - Player statistics

6. **Accessibility**
   - VoiceOver support
   - Dynamic Type
   - Color blind mode

---

## 🛠️ Development Setup

### Requirements
- **Xcode:** 16.1 or later
- **iOS Deployment Target:** 17.0+
- **macOS:** 15.0+ (for development)

### Getting Started
```bash
# Clone repository
git clone <repository-url>

# Open in Xcode
open SequenceGame/SequenceGame.xcodeproj

# Run on simulator
⌘R (iPhone 15 or later recommended)

# Run tests
⌘U
```

### Local Testing
```bash
# Build from command line
xcodebuild clean build \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Run tests from command line
xcodebuild test \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

---

## 📊 Project Statistics

### Code Organization
- **Models:** ~15 files (Card, Player, Board, GameState, etc.)
- **Views:** ~20 files (MainMenu, GameView, BoardView, etc.)
- **Tests:** Unit + UI tests
- **Documentation:** 4 comprehensive markdown files

### Lines of Code (Approximate)
- **GameState.swift:** 282 lines
- **GameConstants.swift:** 173 lines
- **BoardView.swift:** 237 lines
- **GameView.swift:** 184 lines
- **SettingsView.swift:** 167 lines

### Technology Stack
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Testing:** Swift Testing + XCTest
- **CI/CD:** GitHub Actions
- **Version Control:** Git

---

## 👥 Team & Roles

**Developer:** Prajakta Kulkarni  
**Project Type:** Personal/Learning Project  
**Development Started:** October 2025  
**Last Updated:** November 19, 2025

---

## 🎓 Learning Outcomes

### Technical Skills Demonstrated
1. **SwiftUI Mastery**
   - Complex state management
   - Custom views and layouts
   - Animation and interactions

2. **Software Architecture**
   - Clean separation of concerns
   - Protocol-oriented design
   - SOLID principles

3. **Testing**
   - TDD approach
   - Unit and UI testing
   - Test isolation and clarity

4. **CI/CD**
   - GitHub Actions configuration
   - Automated testing
   - Build validation

5. **Best Practices**
   - Code style consistency
   - Documentation
   - Version control

---

## 📖 Key Takeaways

### Design Decisions

#### Why SwiftUI Over UIKit?
- Modern declarative syntax
- Easier state management
- Less boilerplate code
- Better for rapid prototyping

#### Why Struct Over Class for Models?
- Value semantics (immutability by default)
- No reference counting overhead
- Safer for concurrent access
- SwiftUI optimized for value types

#### Why Single GameState Class?
- Single source of truth
- Simplified state management
- Easier to test and debug
- Clear ownership of game logic

#### Why Separation of Validators?
- Testability (can test validation independently)
- Maintainability (single responsibility)
- Reusability (validators can be used elsewhere)
- Clarity (clear boundaries of responsibility)

### Challenges & Solutions

#### Challenge 1: Complex Turn Flow
**Problem:** Managing card selection, placement, validation, sequence detection, and turn advancement

**Solution:** 
- `performPlay()` orchestration function
- Delegates to focused, single-responsibility functions
- Clear step-by-step flow

#### Challenge 2: Board State Management
**Problem:** Keeping board, chips, and sequences in sync

**Solution:**
- `didSet` observer on `boardTiles` to auto-sync
- Single source of truth in `GameState`
- Immutable board positions

#### Challenge 3: CI/CD Setup
**Problem:** Simulator not found in GitHub Actions

**Solution:**
- Researched Swift project CI patterns
- Explicit simulator specification
- Proactive environment validation
- Documented findings for future reference

---

## 🎯 Project Goals Achieved

✅ **Functional Game Implementation**
- Complete gameplay mechanics
- All special rules (Jacks, corners, sequences)
- Win detection

✅ **Clean Architecture**
- Separation of concerns
- Single responsibility
- Testable components

✅ **Professional Code Quality**
- Comprehensive coding conventions
- SwiftLint compliance
- Descriptive naming

✅ **Testing**
- Unit tests for game logic
- UI tests for user flows
- TDD approach

✅ **CI/CD**
- Automated testing pipeline
- Build validation
- Documented configuration

✅ **Documentation**
- Detailed coding standards
- CI troubleshooting guides
- Architecture documentation

---

## 🔗 Resources & References

### Apple Documentation
- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Xcode Build Settings](https://developer.apple.com/documentation/xcode/)

### CI/CD References (from research)
- Swift Package Manager CI (Apple official)
- Alamofire CI configuration
- Firebase iOS SDK CI patterns
- Vapor framework testing
- SwiftLint CI setup

### Testing Resources
- [Swift Testing Framework](https://developer.apple.com/documentation/testing)
- [XCTest Documentation](https://developer.apple.com/documentation/xctest)

---

## 📝 Version History

### v1.0 (Current)
- Initial release
- Core gameplay implemented
- UI complete
- Tests passing
- CI/CD configured

### Upcoming (Planned)
- Game state persistence
- Enhanced animations
- Sound effects
- Statistics tracking

---

## 🎮 How to Play (Quick Reference)

1. **Setup:** 2-12 players, divided into teams
2. **Each Turn:**
   - Select a card from your hand
   - Tap matching position on board (or use Jack strategically)
   - Chip is placed/removed
   - Draw replacement card
3. **Win:** Form required sequences (5 chips in a row)
   - 2 players: need 2 sequences
   - 3+ players: need 1 sequence
4. **Special Cards:**
   - **Two-Eyed Jacks (♣️ ♦️):** Place anywhere
   - **One-Eyed Jacks (♥️ ♠️):** Remove opponent's chip
   - **Corners:** Wild spaces for all players

---

## 🏁 Conclusion

SequenceGame is a well-architected SwiftUI application demonstrating professional iOS development practices. The project showcases clean code, comprehensive testing, robust CI/CD, and extensive documentation. It serves as both a functional game implementation and a reference for Swift/SwiftUI best practices.

**Status:** Active, functional, and well-tested ✅

---

**End of Project Gist**

*Generated on: November 19, 2025*  
*Total Documentation Pages: 5 (including this gist)*  
*Project Health: Excellent ✅*
