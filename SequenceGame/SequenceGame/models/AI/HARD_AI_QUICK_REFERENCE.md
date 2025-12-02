# Hard AI Strategy - Quick Reference Guide

## 🎯 Decision Tree

```
AI Turn Start
│
├─ CAN I WIN?
│  └─ YES → Play winning move ✅
│
├─ CAN OPPONENT WIN NEXT TURN?
│  └─ YES → Block it! 🛡️
│
├─ HAVE ONE-EYED JACK? (♥️ ♠️)
│  └─ Is there a threatening opponent chip?
│     └─ YES → Remove it 👁️
│
├─ HAVE TWO-EYED JACK? (♣️ ♦️)
│  └─ Can it complete/extend sequence?
│     └─ YES → Use it strategically 🃏
│
├─ CAN EXTEND MY SEQUENCE?
│  └─ YES → Build toward win 📈
│
├─ CAN BLOCK OPPONENT DEVELOPMENT?
│  └─ YES → Prevent their sequences 🚧
│
└─ FALLBACK
   └─ Play random valid card 🎲
```

## 🎴 Jack Strategy

### Two-Eyed Jacks (Wild - Place Anywhere)
**Clubs ♣️ & Diamonds ♦️**

**Priority Uses**:
1. Complete a sequence (instant win if it's your 2nd sequence)
2. Extend a sequence from 3 → 4 chips
3. Create a fork (multiple threats)
4. Take strategic center position

**Example**:
```
Before:          After (with 2-eyed Jack):
🔵🔵🔵__         🔵🔵🔵🔵_
                Opponent must now block!
```

### One-Eyed Jacks (Remove Opponent Chip)
**Hearts ♥️ & Spades ♠️**

**Priority Uses**:
1. Break opponent's 4-in-a-row (prevent their win)
2. Remove chip blocking your sequence
3. Disrupt opponent's fork situation
4. Break opponent's developing sequence

**Important**: Cannot remove chips in completed sequences!

**Example**:
```
Before:             After (with 1-eyed Jack):
🔴🔴🔴🔴_           🔴🔴__🔴_
(Threatening!)      (Threat neutralized!)
```

## 📊 Position Scoring System

### What Makes a Position Good?

**🏆 BEST (Score: 10)**
- Completes your sequence
- You're one sequence away from winning

**🛡️ CRITICAL (Score: 9)**
- Blocks opponent from completing sequence
- Opponent is one sequence away from winning

**🔱 EXCELLENT (Score: 8)**
- Creates fork (2+ potential sequences)
- Forces opponent into defensive play

**📈 GOOD (Score: 6-7)**
- Extends sequence (3 → 4 or 4 → 5)
- Has 2+ adjacent friendly chips

**🎯 OKAY (Score: 4-5)**
- Has 1 adjacent friendly chip
- Center board position
- Blocks opponent development

**🎲 MEH (Score: 1-3)**
- Valid but isolated position
- Edge of board
- No strategic value

## 🧮 Sequence Detection Logic

### How Hard AI Counts Chips in a Line:

```swift
Direction checks (from any position):
→  Horizontal    (0, 1)
↓  Vertical      (1, 0)
↘  Diagonal \    (1, 1)
↙  Diagonal /    (1, -1)

For each direction:
- Count forward (e.g., →→→)
- Count backward (e.g., ←←←)
- Add counts + 1 (the position itself)
- If total ≥ 5, it's a sequence!
```

### Example:

```
Board:
_ _ 🔵 _ _
_ 🔵 _ _ _
🔵 _ _ _ _
_ _ _ _ _

Position (2, 0):
- Count diagonal ↗: 🔵 + 🔵 + 🔵 = 3
- This is part of a developing sequence!
```

## 🎮 Common Patterns

### Pattern 1: The Fork
```
Create double threat:

🔵🔵🔵__
    |
    🔵
    |
    🔵
    |
    _

Playing at intersection creates two ways to win!
Opponent can only block one.
```

### Pattern 2: The Block
```
Opponent threat:
🔴🔴🔴🔴_

Your move:
🔴🔴🔴🔴🔵 ✅ Blocked!
```

### Pattern 3: The Extend
```
Your chips:
🔵🔵__

Next turn:
🔵🔵🔵_ (Getting closer!)

Then:
🔵🔵🔵🔵_ (Almost there!)

Finally:
🔵🔵🔵🔵🔵 ✅ SEQUENCE!
```

## 🎯 Win Conditions

```swift
let sequencesToWin = 2

Current sequences: 0 → Keep building
Current sequences: 1 → One more to win! 🔥
Current sequences: 2 → VICTORY! 🏆
```

## 🐛 Debugging AI Decisions

### Console Output Guide:

```
🤖 = AI turn start
🧠🔥 = Found WINNING move!
🧠🛡️ = BLOCKING opponent's winning move
🧠👁️ = Using one-eyed Jack
🧠🃏 = Using two-eyed Jack
🧠📈 = Extending sequence
🧠🔱 = Creating fork
🧠🎯 = Taking strategic position
🧠🎲 = Random fallback
✅ = Move executed successfully
❌ = Error occurred
🎴 = Dead card handling
```

### Example Console Output:
```
🤖 AI (Hard): Starting turn...
🧠🛡️ Hard AI: BLOCKING opponent's winning move!
🧠🛡️ Hard AI: Blocking opponent's sequence!
✅ AI Controller: Successfully executed move
```

## 💡 Tips for Beating Hard AI

### 1. Create Multiple Threats Early
```
Don't focus on one sequence!
Build 2-3 potential sequences simultaneously.
```

### 2. Control the Center
```
Center tiles = More directions = More opportunities
```

### 3. Save Your Jacks
```
Don't waste Jacks on insignificant moves.
Save them for critical moments:
- Completing your 2nd sequence
- Blocking AI's 2nd sequence
```

### 4. Watch AI's Sequences
```
If AI has 1 sequence already:
→ Monitor all their developing sequences
→ Block before they reach 4-in-a-row
→ Use one-eyed Jack if needed
```

### 5. Create Forks
```
Force AI to choose which threat to block.
AI can only block one position per turn!
```

## 🧪 Testing Hard AI

### Test Scenario 1: Can AI Win?
```swift
Setup:
- Give AI 4 chips in a row with 5th position available
- Give AI a card that matches the 5th position

Expected: AI completes sequence
```

### Test Scenario 2: Will AI Block?
```swift
Setup:
- Give opponent 4 chips in a row with 5th position available
- Give AI a card that matches the 5th position
- Opponent has 1 sequence already (critical!)

Expected: AI blocks the winning position
```

### Test Scenario 3: Jack Usage
```swift
Setup:
- Give AI two-eyed Jack
- Create situation where AI can extend sequence with Jack

Expected: AI uses Jack strategically
```

### Test Scenario 4: Fork Creation
```swift
Setup:
- Create board where AI can create fork
- Give AI appropriate card

Expected: AI creates multiple threats
```

## 📈 Performance Metrics

### Expected Behavior:

| Metric | Target | Notes |
|--------|--------|-------|
| Win Detection | 100% | Always finds winning move |
| Block Detection | 100% | Always blocks critical threats |
| Fork Recognition | 80%+ | Usually finds forks |
| Jack Usage | 90%+ | Uses Jacks well |
| Decision Time | < 2s | Including thinking delay |
| Move Validity | 100% | Never makes illegal moves |

## 🔍 Algorithm Complexity

```
Time Complexity:
- Card Selection: O(cards × positions × directions)
  ≈ O(7 × 10 × 8) = O(560) operations max
  
- Position Evaluation: O(positions × directions)
  ≈ O(10 × 8) = O(80) operations max

Total: ~640 operations (very fast!)
```

## 🚀 Integration Code

```swift
// In your GameState or ViewModel:

func executeAITurn() {
    guard let currentPlayer = currentPlayer,
          currentPlayer.isAI else { return }
    
    let controller = AIPlayerController(difficulty: currentPlayer.aiDifficulty)
    
    Task {
        // Async execution with thinking delay
        let success = await controller.executeTurnAsync(in: self)
        
        if success {
            // AI made a move, handle turn transition
            advanceToNextTurn()
        } else {
            // Handle error (shouldn't happen with proper setup)
            print("AI failed to make a move")
        }
    }
}
```

## 🎓 Key Principles

1. **Safety First**: Always validate moves before executing
2. **Win Immediately**: Never miss a winning opportunity
3. **Block Critical Threats**: Prevent opponent victories
4. **Think Ahead**: Consider future sequence possibilities
5. **Use Jacks Wisely**: They're powerful tools
6. **Center Control**: Middle positions are valuable
7. **Create Forks**: Multiple threats are powerful

---

**Remember**: Hard AI plays optimally but fairly. It follows the same rules as human players and makes strategic decisions based on board state, not by "cheating" or looking at opponent cards!

Last Updated: December 2, 2025
