# Bug Fix: AI Players Not Preserved on "Play Again"

## 🐛 Issue Description

**Problem**: After completing a game, clicking "Play Again" would reset all AI players back to human players, losing their AI status and difficulty settings.

**Root Cause**: The `restartGame()` method in `GameState.swift` was not preserving the `isAI` and `aiDifficulty` properties when recreating players.

---

## 🔍 Investigation

### Location of Bug
**File**: `GameState.swift`  
**Method**: `restartGame()`  
**Lines**: 186-192 (before fix)

### What Was Happening

```swift
// BEFORE (BUGGY CODE):
let savedPlayers = players.map { player in
    Player(
        name: player.name,        // ✅ Preserved
        team: player.team,        // ✅ Preserved
        isPlaying: false,
        cards: []
        // ❌ isAI not preserved - defaults to false
        // ❌ aiDifficulty not preserved - defaults to nil
    )
}
```

This meant:
1. All AI players became human players after restart
2. AI difficulty settings were lost
3. Game configuration was not properly preserved

---

## ✅ Solution

### The Fix

```swift
// AFTER (FIXED CODE):
let savedPlayers = players.map { player in
    Player(
        name: player.name,              // ✅ Preserved
        team: player.team,              // ✅ Preserved
        isPlaying: false,
        cards: [],
        isAI: player.isAI,              // ✅ NOW PRESERVED
        aiDifficulty: player.aiDifficulty  // ✅ NOW PRESERVED
    )
}
```

### Changes Made

**File**: `GameState.swift`

1. **Added `isAI` preservation** - Line 191
2. **Added `aiDifficulty` preservation** - Line 192
3. **Updated documentation** - Updated method comments to mention AI settings

---

## 🧪 Testing

### Test Coverage

Created comprehensive test suite: `AIPlayerRestartTests.swift`

**Tests Include**:
1. ✅ Play Again preserves AI players
2. ✅ Mixed AI/Human configuration preservation
3. ✅ Cards reset but AI properties preserved
4. ✅ All difficulty levels preserved (Easy, Medium, Hard)
5. ✅ AI player helper function validation

### Test Example

```swift
@Test("Play Again preserves AI players")
func testPlayAgainPreservesAIPlayers() throws {
    let gameState = GameState()
    
    let players = [
        Player(name: "Human", team: Team(color: .blue), isAI: false),
        Player.aiPlayer(name: "Easy AI", team: Team(color: .green), difficulty: .easy),
        Player.aiPlayer(name: "Hard AI", team: Team(color: .red), difficulty: .hard)
    ]
    
    gameState.startGame(with: players)
    
    // Before fix: This would fail ❌
    // After fix: This passes ✅
    try gameState.restartGame()
    
    #expect(gameState.players[0].isAI == false)
    #expect(gameState.players[1].isAI == true)
    #expect(gameState.players[1].aiDifficulty == .easy)
    #expect(gameState.players[2].isAI == true)
    #expect(gameState.players[2].aiDifficulty == .hard)
}
```

---

## 📋 Affected Scenarios

### Before Fix (Broken) ❌

```
Initial Game:
- Player 1: Human
- Player 2: Easy AI
- Player 3: Hard AI

Click "Play Again"
↓
New Game:
- Player 1: Human ✅
- Player 2: Human ❌ (was Easy AI)
- Player 3: Human ❌ (was Hard AI)
```

### After Fix (Working) ✅

```
Initial Game:
- Player 1: Human
- Player 2: Easy AI
- Player 3: Hard AI

Click "Play Again"
↓
New Game:
- Player 1: Human ✅
- Player 2: Easy AI ✅
- Player 3: Hard AI ✅
```

---

## 🎯 Impact

### What Gets Preserved Now

✅ **Player names**  
✅ **Team assignments**  
✅ **Team colors**  
✅ **AI status** (isAI)  
✅ **AI difficulty** (easy/medium/hard)  

### What Gets Reset (As Expected)

🔄 **Cards in hand** - Re-dealt fresh  
🔄 **Game board** - Reset to initial state  
🔄 **Current turn** - Starts with first player  
🔄 **Sequences** - Cleared  
🔄 **Win state** - Cleared  

---

## 🔧 Related Code

### Player.swift

The `Player` struct has AI support built-in:

```swift
struct Player: Codable, Identifiable {
    var id = UUID()
    var name: String
    let team: Team
    var isPlaying: Bool = false
    var cards: [Card] = []
    
    var isAI: Bool = false
    var aiDifficulty: AIDifficulty?
}
```

### Helper Extension

Using the convenience initializer is recommended:

```swift
extension Player {
    static func aiPlayer(name: String, team: Team, difficulty: AIDifficulty) -> Player {
        return Player(
            name: name,
            team: team,
            isPlaying: false,
            cards: [],
            isAI: true,
            aiDifficulty: difficulty
        )
    }
}
```

---

## 🚀 How to Use

### Creating AI Players (Recommended Way)

```swift
// Use the convenience initializer
let easyAI = Player.aiPlayer(
    name: "Easy Bot",
    team: Team(color: .blue),
    difficulty: .easy
)

let hardAI = Player.aiPlayer(
    name: "Hard Bot",
    team: Team(color: .red),
    difficulty: .hard
)

gameState.startGame(with: [humanPlayer, easyAI, hardAI])
```

### Manual Creation (Alternative)

```swift
// Or create manually
let aiPlayer = Player(
    name: "AI Player",
    team: Team(color: .green),
    isPlaying: false,
    cards: [],
    isAI: true,
    aiDifficulty: .medium
)
```

---

## ✅ Verification Checklist

- [x] Bug identified in `restartGame()` method
- [x] Fix applied to preserve `isAI` and `aiDifficulty`
- [x] Documentation updated
- [x] Comprehensive test suite created
- [x] All test scenarios passing
- [x] Code follows existing patterns
- [x] No breaking changes introduced

---

## 📝 Additional Notes

### Why This Bug Occurred

The `Player` struct has default values for `isAI` (false) and `aiDifficulty` (nil). When the `restartGame()` method created new `Player` instances without explicitly setting these properties, they defaulted to human player values.

### Prevention

To prevent similar issues in the future:
1. Always explicitly set all Player properties when recreating players
2. Add tests for game restart/reset functionality
3. Consider using the `Player.aiPlayer()` helper for consistency
4. Review property preservation when adding new Player properties

---

## 🎓 Key Takeaways

1. **Default values can hide bugs** - Properties with defaults may not be obviously missing
2. **Test edge cases** - Game restart is an edge case that needs explicit testing
3. **Helper functions are useful** - `Player.aiPlayer()` makes intent clear
4. **Preserve state explicitly** - Don't rely on defaults when preserving configuration

---

**Status**: ✅ Fixed and Tested  
**Version**: v1.0  
**Date**: December 2, 2025  
**Priority**: High (affects core gameplay loop)

---

## Quick Test

To manually verify the fix:
1. Start a new game with AI players
2. Play until game ends
3. Click "Play Again"
4. Verify AI players still show AI behavior
5. Check that difficulty levels are maintained

✅ **All AI players should maintain their settings!**
