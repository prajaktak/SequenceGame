# Work Session - November 20, 2025 (Afternoon)
**Focus:** Critical bug fixes and architecture improvements  
**Based on:** `ISSUES_AND_IMPROVEMENTS_2025-11-18.md`

---

## 📋 Session Context

### Project: SequenceGame
- iOS board game implementation in SwiftUI
- CI is now working ✅ (GitHub Copilot helped fix it on Nov 19)
- Code review identified 16 issues requiring attention
- Full project details in `projectGist.md`

### Key Constraints (from CODING_CONVENTIONS.md)
- **One type per file**
- **Models must be platform-agnostic** (no SwiftUI imports)
- **Single source of truth** for state
- **Test-driven development** (one behavior per test)
- **No abbreviations**, descriptive naming
- **Separation of concerns**

### Communication Rules (from COMMUNICATION_RULES.md)
- ✅ Read first, then act
- ✅ Propose changes, don't just implement
- ✅ One task at a time
- ✅ Test after each change
- ✅ Ask before making architectural decisions

---

## 🎯 TODAY'S PRIORITY TASKS

### Session 1: Critical Fixes (~2 hours)

#### 1. 🐛 Fix Jack Cards Disappearing Bug ⚠️ CRITICAL
**File:** `models/Deck.swift` (`drawCardExceptJacks`)  
**Problem:** Jacks removed during board setup never return to deck. Players can't draw them.  
**Fix:** Reinsert rejected Jacks OR peek without removing  
**Test:** Verify all 8 Jacks available after board setup  
**Time:** 30 min

#### 2. 🏗️ Fix GameView Duplicate State Bug ⚠️ CRITICAL
**File:** `Views/GameView.swift` (lines 13-178)  
**Problem:** `@State` arrays for `players`, `teams`, `seats` never update after init. Violates single source of truth.  
**Fix:** Remove local state, create computed properties from `gameState`  
**Test:** Verify seating updates as turns advance  
**Time:** 45 min

#### 3. ✏️ Fix Accessibility Label
**File:** `Views/HandView.swift` (lines 33-57)  
**Problem:** Typo `accesabilityLable` and produces "Queenofclubs" (no spaces)  
**Fix:** Rename + add proper spacing: "Queen of Clubs"  
**Time:** 10 min

#### 4. 🔄 Update Navigation API
**File:** `Views/GameView.swift` (lines 70-146)  
**Problem:** Uses deprecated `presentationMode`  
**Fix:** Replace with `@Environment(\.dismiss)`  
**Time:** 15 min

---

### Session 2: Architecture Improvements (~2 hours)

#### 5. 🎨 Remove SwiftUI.Color from Models ⚠️ MAJOR REFACTOR
**Files:** `GameState.swift`, `BoardManager.swift`, `Team.swift`, `SequenceDetector.swift`  
**Problem:** Models import SwiftUI just for Color. Should be platform-agnostic.  
**Fix:**
1. Create `TeamIdentifier` enum (blue, green, red)
2. Replace `Color` with `TeamIdentifier` in all models
3. Create `ThemeColor.color(for: TeamIdentifier) -> Color` mapper
4. Update all views to use mapper
5. Remove `import SwiftUI` from models

**Time:** 1.5 hours  
**Note:** This is the biggest task but enables everything else

#### 6. 🔧 Fix GameOverlayView Dependencies
**File:** `Views/GameOverlay/GameOverlayView.swift`  
**Problem:** Uses `@EnvironmentObject gameState` unnecessarily. Breaks previews.  
**Fix:** Remove environment object, pass `winningTeam` explicitly  
**Time:** 30 min

#### 7. ⚠️ Fix Color-Based Team Comparison
**File:** `GameOverlayView.swift` (`teamName(for:)`)  
**Problem:** Comparing `Color` values is unreliable  
**Fix:** Use `TeamIdentifier` after task #5  
**Time:** 15 min

---

### Session 3: Quick Wins (if time allows)

#### 8. 🔢 Fix GameConstants Validation
**Files:** `GameConstants.swift` & `GameSettingsView.swift`  
**Problem:** `maxTeams` is 4 but only 3 colors available  
**Fix:** Tie `maxTeams` to `teamColors.count`  
**Time:** 20 min

#### 9. 📛 Rename Confusing Parameter
**Files:** `GameSettingsView.swift` & `GameView.swift`  
**Problem:** `numberOfPlayers` is actually `playersPerTeam`  
**Fix:** Rename for clarity  
**Time:** 10 min

---

## 🧹 Before Every Commit

- [ ] Run `swiftlint lint --strict`
- [ ] Run tests: `⌘U`
- [ ] Verify build succeeds
- [ ] Check `git status` for unintended changes

---

## 📊 Session Goals

**Minimum:** Tasks 1-4 (critical fixes)  
**Target:** Tasks 1-7 (critical + architecture)  
**Stretch:** Tasks 1-9 (everything above)

---

## 🔗 Reference Files

- **Full issue list:** `ISSUES_AND_IMPROVEMENTS_2025-11-18.md`
- **Coding standards:** `CODING_CONVENTIONS.md`
- **Project overview:** `projectGist.md`
- **Communication rules:** `COMMUNICATION_RULES.md`

---

## 📝 Session Notes

*(Update this as we work - track completed tasks, blockers, decisions made)*

### Completed:
- [ ] Task 1: Jack cards bug
- [ ] Task 2: GameView state
- [ ] Task 3: Accessibility label
- [ ] Task 4: Navigation API
- [ ] Task 5: Remove Color from models
- [ ] Task 6: GameOverlayView dependencies
- [ ] Task 7: Color comparison fix
- [ ] Task 8: GameConstants validation
- [ ] Task 9: Parameter rename

### Blockers/Questions:
*(None yet - add as we encounter them)*

### Decisions Made:
*(Document any architectural or design decisions)*

---

**Ready to start!** 🚀  
**Last Updated:** November 19, 2025
