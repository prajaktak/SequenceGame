# TODO List - From Code Reviews 2025-11-20

**Date Created:** 2025-11-20  
**Source:** All code review reports from 2025-11-20  
**Status:** Consolidated action items from 3 review reports

---

## 🎉 Completed Items (Reference)

All 9 priority tasks from WORK_SESSION_2025-11-20.md are **COMPLETE** ✅

- ✅ Task 1: Jack cards documentation
- ✅ Task 2: GameView duplicate state
- ✅ Task 3: Accessibility labels
- ✅ Task 4: Navigation API update
- ✅ Task 5: Remove SwiftUI.Color from models (TeamColor created)
- ✅ Task 6: GameOverlayView dependencies
- ✅ Task 7: Color comparison fix
- ✅ Task 8: GameConstants validation
- ✅ Task 9: Parameter naming clarity

---

## 🧹 Code Cleanup (High Priority)

### 1. Remove Commented-Out Code in BoardTile.swift
**Priority:** 🟡 Medium  
**Time:** ~2 minutes  
**File:** `BoardTile.swift` lines 17-19

**Current:**
```swift
//    static func isCornerTile(at position: (row: Int, col: Int)) -> Bool {
//        return GameConstants.cornerPositions.contains { $0.row == position.row && $0.col == position.col }
//    }
```

**Action:**
- [ ] Delete commented code if not needed
- [ ] OR uncomment and document if needed
- [ ] OR add `// TODO:` explaining why it's kept

**Why:** Clean code principle - remove dead code (git preserves history)

**Source:** CODE_REVIEW_REPORT_2025-11-20_UPDATED.md

---

### 2. Remove Commented Import Statements
**Priority:** 🟢 Low  
**Time:** ~2 minutes  
**Files:** `Team.swift`, `GameState.swift`

**Current:**
```swift
import Foundation
//import SwiftUI  // ⚠️ Remove this line
```

**Action:**
- [ ] Remove `//import SwiftUI` from Team.swift
- [ ] Remove `//import SwiftUI` from GameState.swift

**Why:** Clean code - remove unnecessary comments showing work-in-progress

**Source:** CODE_REVIEW_FINAL_2025-11-20.md

---

## 🎨 UI/UX Improvements (Medium Priority)

### 3. Add Missing Preview Blocks to Views
**Priority:** 🟡 Medium  
**Time:** ~30 minutes  
**Files:** 7 view files missing previews

**Files to review:**
- [ ] `Views/ScatteredItem.swift` - Add preview if it's a view
- [ ] `Views/GameOverlay/Hexagon.swift` - Review if preview needed (helper struct)
- [ ] `Views/Modifiers/OptionalSpringAnimation.swift` - Review if preview needed (modifier)
- [ ] `Views/ShimmerAnimations/ShimmerBorderSettings.swift` - Review if preview needed (settings)
- [ ] `Views/Theme/PrimaryButtonStyle.swift` - Consider preview to demonstrate style
- [ ] `Views/Theme/SecondaryButtonStyle.swift` - Consider preview to demonstrate style
- [ ] `Views/ShimmerAnimations/Shimmer.swift` - Review if preview needed (animation helper)

**Why:** CODING_CONVENTIONS.md states "Every view MUST have a `#Preview`"

**Note:** Some exceptions may be acceptable for modifiers/styles/helpers

**Source:** CODE_REVIEW_REPORT_2025-11-20.md

---

### 4. Centralize UI Constants
**Priority:** 🟡 Medium  
**Time:** ~1 hour  
**Files:** Multiple view files

**Action:**
- [ ] Extract magic numbers from BoardView.swift
  - Corner radius (4)
  - Border width (3)
  - Animation durations
- [ ] Create UIAnimation namespace or extend GameConstants
- [ ] Replace inline literals throughout views
- [ ] Group constants by domain (Board, Sizing, Animation)

**Example:**
```swift
// Create in GameConstants.swift
extension GameConstants {
    enum UIAnimation {
        static let cornerRadius: CGFloat = 4
        static let borderWidth: CGFloat = 3
        static let defaultDuration: Double = 0.3
        static let shimmerDuration: Double = 2.0
    }
}
```

**Why:** Consistency, maintainability, easier theming

**Source:** CODE_REVIEW_FINAL_2025-11-20.md (ChatGPT review)

---

### 5. Fix or Remove sequenceAnimationTrigger in BoardView
**Priority:** 🟡 Medium  
**Time:** ~15 minutes  
**File:** `BoardView.swift`

**Issue:** `sequenceAnimationTrigger` may be dead state (not connected to any view)

**Action:**
- [ ] Verify if trigger is used in view modifiers
- [ ] Option A: Connect to animation: `.animation(..., value: gameState.detectedSequence)`
- [ ] Option B: Use as view identity: `.id(sequenceAnimationTrigger)`
- [ ] Option C: Remove if unused

**Why:** Avoid non-functional state that doesn't affect UI

**Source:** CODE_REVIEW_FINAL_2025-11-20.md (ChatGPT review)

---

### 6. Extract Valid Placement Indicator Subview
**Priority:** 🟢 Low  
**Time:** ~30 minutes  
**File:** `BoardView.swift`

**Action:**
- [ ] Create `ValidPlacementIndicator` subview
- [ ] Extract shimmer border settings helper
- [ ] Reduce duplication in valid position rendering
- [ ] Make indicator reusable

**Why:** Better code organization, reusability, testability

**Source:** CODE_REVIEW_FINAL_2025-11-20.md (ChatGPT review)

---

## ♿️ Accessibility Improvements (Medium Priority)

### 7. Add Accessibility Labels to Tiles
**Priority:** 🟡 Medium  
**Time:** ~30 minutes  
**Files:** `TileView.swift`, `BoardView.swift`

**Action:**
- [ ] Add accessibility labels to board tiles
  - Card description (rank + suit)
  - Chip ownership (team color)
  - Position information (optional)
- [ ] Add labels to valid move indicators
- [ ] Test with VoiceOver

**Example:**
```swift
.accessibilityLabel("\(card.rank) of \(card.suit), \(team) chip")
```

**Why:** VoiceOver support, better accessibility for visually impaired users

**Source:** CODE_REVIEW_FINAL_2025-11-20.md (ChatGPT review)

---

### 8. Add Non-Color Cues for Valid Moves
**Priority:** 🟢 Low  
**Time:** ~1 hour  
**Files:** `BoardView.swift`, indicator views

**Action:**
- [ ] Add haptic feedback for valid move selection
- [ ] Add sound cues (optional)
- [ ] Add shape/pattern indicators (not just color)
- [ ] Test with color blind simulation

**Why:** Accessibility, color-blind users, better UX

**Source:** CODE_REVIEW_FINAL_2025-11-20.md (ChatGPT review)

---

## 📝 Documentation (Low Priority)

### 9. Add Documentation to Complex Algorithms
**Priority:** 🟢 Low  
**Time:** ~1 hour  
**Files:** Multiple

**Files needing more documentation:**
- [ ] `SequenceDetector.swift` - Add doc comments to detection algorithms
- [ ] `BoardManager.swift` - Document board management logic
- [ ] `CardPlayValidator.swift` - Document card validation rules

**Action:**
- [ ] Add `///` documentation comments
- [ ] Explain the "why" and behavior
- [ ] Document complexity (Big O notation if relevant)
- [ ] Add invariants and edge cases

**Why:** Maintainability, onboarding new developers, code understanding

**Source:** CODE_REVIEW_REPORT_2025-11-20.md

---

### 10. Create Architecture Documentation
**Priority:** 🟢 Low  
**Time:** ~30 minutes  
**File:** Create `ARCHITECTURE.md`

**Action:**
- [ ] Create ARCHITECTURE.md in project root
- [ ] Document data flow (GameState → Views → Actions → GameState)
- [ ] Document module responsibilities
- [ ] Explain TeamColor/ThemeColor separation
- [ ] Add diagram (optional)

**Example sections:**
- Overview
- Model Layer (Platform-agnostic)
- View Layer (SwiftUI)
- Mapping Functions (Bridge)
- State Management
- Data Flow

**Why:** Onboarding, architectural clarity, design documentation

**Source:** CODE_REVIEW_FINAL_2025-11-20.md (ChatGPT review)

---

## ✅ Verification Tasks

### 11. Run SwiftLint Verification
**Priority:** 🟡 Medium  
**Time:** ~5 minutes  
**Command:** `swiftlint lint --strict`

**Action:**
- [ ] Run `swiftlint lint --strict` from project root
- [ ] Verify zero errors/warnings
- [ ] Address any violations found
- [ ] Ensure CI/CD catches linting issues

**Expected:** No violations (zero linting errors per conventions)

**Source:** All review reports

---

### 12. Test Coverage Review
**Priority:** 🟢 Low  
**Time:** ~1 hour  
**Files:** Test files

**Action:**
- [ ] Review test coverage for refactored code
  - GameView computed properties (Task 2)
  - GameConstants validation (Task 8)
  - Navigation dismiss behavior (Task 4)
  - TeamColor enum functionality
- [ ] Add tests for edge cases
- [ ] Ensure one behavior per test
- [ ] Verify all tests passing

**Why:** Ensure refactored code is properly tested

**Source:** CODE_REVIEW_REPORT_2025-11-20_UPDATED.md

---

### 13. Add Unit Tests for GameState
**Priority:** 🟡 Medium  
**Time:** ~2 hours  
**File:** Create or expand `GameStateTests.swift`

**Test cases to add:**
- [ ] Computing valid positions for cards
- [ ] Turn transition logic
- [ ] Sequence detection (including corners/edges)
- [ ] Wildcard handling (if applicable)
- [ ] Jack card handling (if applicable)
- [ ] Win condition evaluation
- [ ] Edge cases and boundary conditions

**Why:** Core game logic needs comprehensive test coverage

**Source:** CODE_REVIEW_FINAL_2025-11-20.md (ChatGPT review)

---

## 🚀 Performance Optimizations (Low Priority)

### 14. Optimize Sequence Detection Lookups
**Priority:** 🟢 Low  
**Time:** ~30 minutes  
**File:** Sequence detection code

**Current:** Likely O(n) membership checks across tiles

**Optimization:**
- [ ] Precompute `Set<Tile.ID>` for detected sequences
- [ ] Use O(1) lookups instead of array contains
- [ ] Profile before/after to verify improvement

**Why:** Performance improvement for large sequence sets

**Note:** Measure before optimizing - may not be needed

**Source:** CODE_REVIEW_FINAL_2025-11-20.md (ChatGPT review)

---

### 15. Refactor Board Initialization (Optional)
**Priority:** 🟢 Very Low  
**Time:** ~30 minutes  
**File:** `Board.swift`

**Current:**
```swift
var initialTiles: [[BoardTile]] = []
for _ in 0..<row {
    var rowTiles: [BoardTile] = []
    for _ in 0..<col {
        rowTiles.append(BoardTile(...))
    }
    initialTiles.append(rowTiles)
}
```

**Optional improvement:**
```swift
self.boardTiles = (0..<row).map { _ in
    (0..<col).map { _ in
        BoardTile(...)
    }
}
```

**Why:** More concise, functional style

**Note:** Current code is perfectly fine! This is optional style preference.

**Source:** CODE_REVIEW_FINAL_2025-11-20.md

---

## 📚 Documentation Updates

### 16. Update Work Session Documentation
**Priority:** 🟡 Medium  
**Time:** ~10 minutes  
**File:** `WORK_SESSION_2025-11-20.md`

**Action:**
- [ ] Mark all tasks (1-9) as completed ✅
- [ ] Add notes about TeamColor implementation
- [ ] Document the architectural improvements
- [ ] Close out the work session
- [ ] Add summary of achievements

**Why:** Keep project documentation up-to-date

**Source:** CODE_REVIEW_FINAL_2025-11-20.md

---

## 📊 Summary

### By Priority

**🔴 High Priority (Critical):**
- None - All critical tasks completed! ✅

**🟡 Medium Priority (Important):**
- 1. Remove commented-out code in BoardTile.swift (~2 min)
- 3. Add missing preview blocks (~30 min)
- 4. Centralize UI constants (~1 hour)
- 5. Fix/remove sequenceAnimationTrigger (~15 min)
- 7. Add accessibility labels to tiles (~30 min)
- 11. Run SwiftLint verification (~5 min)
- 13. Add unit tests for GameState (~2 hours)
- 16. Update work session documentation (~10 min)

**🟢 Low Priority (Nice to Have):**
- 2. Remove commented import statements (~2 min)
- 6. Extract valid placement indicator subview (~30 min)
- 8. Add non-color cues for valid moves (~1 hour)
- 9. Add documentation to complex algorithms (~1 hour)
- 10. Create architecture documentation (~30 min)
- 12. Test coverage review (~1 hour)
- 14. Optimize sequence detection lookups (~30 min)
- 15. Refactor board initialization (optional) (~30 min)

---

### Time Estimates

**Quick Wins (< 15 min):**
- Items 1, 2, 11, 16 (~19 min total)

**Short Tasks (15-60 min):**
- Items 3, 5, 6, 7, 10, 14, 15 (~3.5 hours total)

**Longer Tasks (1-2+ hours):**
- Items 4, 8, 9, 12, 13 (~7 hours total)

**Total Estimated Time:** ~10.5 hours for all remaining items

**Recommended Next Session:**
- Quick wins (items 1, 2, 11, 16) = ~20 min
- Then medium priority items (3, 4, 5, 7, 13)

---

### By Category

**Code Cleanup:** Items 1, 2  
**UI/UX:** Items 3, 4, 5, 6  
**Accessibility:** Items 7, 8  
**Documentation:** Items 9, 10, 16  
**Testing:** Items 11, 12, 13  
**Performance:** Items 14, 15  

---

## 🎯 Recommended Action Plan

### Session 1: Quick Wins (~20 min)
1. ✅ Run SwiftLint verification
2. 🧹 Remove commented-out code
3. 🧹 Remove commented imports
4. 📝 Update work session docs

### Session 2: UI & Accessibility (~2 hours)
5. 🎨 Add missing preview blocks
6. 🎨 Fix/remove sequenceAnimationTrigger
7. ♿️ Add accessibility labels

### Session 3: Architecture & Testing (~3 hours)
8. 🎨 Centralize UI constants
9. ✅ Add GameState unit tests
10. 📝 Create architecture documentation

### Session 4: Polish (Optional, ~3.5 hours)
11. ♿️ Non-color cues for valid moves
12. 📝 Document complex algorithms
13. ✅ Test coverage review
14. 🚀 Performance optimizations

---

## ✅ Current Status

**Overall Compliance:** 99.2% ⭐⭐⭐⭐⭐  
**Completed Tasks:** 9/9 (100%) ✅  
**Code Quality:** Professional-grade  
**Architecture:** Exemplary  

**Outstanding:** Minor cleanup and optional improvements

---

## 📚 References

**Source Documents:**
- CODE_REVIEW_REPORT_2025-11-20.md
- CODE_REVIEW_REPORT_2025-11-20_UPDATED.md
- CODE_REVIEW_FINAL_2025-11-20.md
- CODING_CONVENTIONS.md
- WORK_SESSION_2025-11-20.md

---

**Created:** 2025-11-20  
**Status:** Ready for action  
**Next Update:** After completing todo items

---

*End of TODO List*
