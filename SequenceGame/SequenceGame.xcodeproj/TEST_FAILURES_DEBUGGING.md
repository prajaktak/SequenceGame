# Test Failures Debugging Guide

**Issue:** Tests fail when running from command line  
**Date:** November 19, 2025

---

## 🔍 FIRST: WHAT'S THE ACTUAL ERROR?

Please share the **full error output** from your terminal. Look for:

1. **Which test(s) failed?**
2. **What's the error message?**
3. **Is it a crash, assertion failure, or timeout?**

---

## 🎯 COMMON TEST FAILURE CAUSES

### 1. **Tests Pass in Xcode but Fail in Command Line**

**Symptoms:**
- ✅ Tests pass when you press `⌘U` in Xcode
- ❌ Tests fail with `xcodebuild test` command

**Common Causes:**

#### A. Scheme Not Configured for Testing
```
Error: Scheme has no test action configured
```

**Fix:**
1. Open Xcode
2. Product → Scheme → Edit Scheme (⌘<)
3. Select "Test" in left sidebar
4. Make sure "SequenceGameTests" is **checked** (enabled)
5. Make sure all test classes are included

#### B. Test Target Not Set as "Host Application"
```
Error: Test target has no host application
Error: Could not launch test runner
```

**Fix:**
1. Select **SequenceGameTests** target in Xcode
2. Go to "General" tab
3. Under "Testing", set **Host Application** to "SequenceGame"
4. Under "Build Settings", verify:
   - **Test Host** is set
   - **Bundle Loader** is set

#### C. Missing @testable Import
```
Error: Use of unresolved identifier 'GameState'
Error: Cannot find 'Deck' in scope
```

**Fix:**
Make sure your test files have:
```swift
@testable import SequenceGame
```

And in **Build Settings** for SequenceGame target:
- **Enable Testability** (Debug) = YES

---

### 2. **Specific Test Failures**

Based on your test suite, here are tests that commonly fail:

#### Test: "computePlayableTiles: two-eyed jack returns all empty non-corner tiles"

**Expected to fail:** This test has a comment saying:
```swift
// This will fail with current implementation (returns 0), should pass after implementation
```

**If failing:**
- This is **EXPECTED** - the test documents that Jack handling isn't implemented yet
- Not a CI problem, it's a known feature gap

**Fix:**
Implement Jack handling in `computePlayableTiles` method, or mark this test as expected to fail.

#### Test: "computePlayableTiles: one-eyed jack returns only tiles with chips"

**Expected to fail:** Same as above - Jack implementation pending

**If failing:**
- This is **EXPECTED**
- The test comments indicate this feature isn't implemented yet

**Fix:**
Either:
1. Implement the Jack logic
2. Or skip these tests in CI temporarily:
```swift
@Test(.disabled("Jack logic not yet implemented"))
func computePlayableTiles_twoEyedJack_returnsAllEmptyNonCornerTiles() {
    // ...
}
```

---

### 3. **Flaky Tests (Sometimes Pass, Sometimes Fail)**

#### Tests Using `shuffle()`
```swift
@Test("Test Shuffle")
func testShuffle() {
    let deck = Deck()
    deck.shuffle()
    let firstCard = deck.drawCard()
    let secondCard = deck.drawCard()
    #expect(firstCard?.cardFace != secondCard?.cardFace || firstCard?.suit != secondCard?.suit)
}
```

**Problem:** This can randomly fail if shuffle happens to put two identical cards next to each other (unlikely but possible with double deck).

**Fix:** Make test more robust:
```swift
@Test("Test Shuffle changes order")
func testShuffle() {
    let deck1 = Deck()
    let deck2 = Deck()
    
    deck2.shuffle()
    
    // Draw several cards and ensure they're not in the same order
    let unshuffled = (0..<5).compactMap { _ in deck1.drawCard() }
    let shuffled = (0..<5).compactMap { _ in deck2.drawCard() }
    
    #expect(unshuffled != shuffled, "Shuffle should change card order")
}
```

---

### 4. **Simulator-Related Test Failures**

**Symptoms:**
```
Error: Lost connection to test runner
Error: Test runner crashed
Error: Simulator failed to boot
```

**Causes:**
- Simulator not properly booted
- UI tests trying to run (not applicable here)
- Memory issues

**Fix:**
```bash
# Reset simulators
xcrun simctl shutdown all
xcrun simctl erase all

# Try test again
xcodebuild test \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1'
```

---

### 5. **Timeout Failures**

**Symptoms:**
```
Error: Test case timed out
```

**Common in tests:**
- Tests with many loops
- Tests that shuffle repeatedly

**Fix:**
Increase timeout or optimize test:
```swift
@Test(.timeLimit(.minutes(5)))
func testLongRunningOperation() {
    // ...
}
```

---

## 🧪 DEBUGGING COMMANDS

### Run Specific Test
```bash
xcodebuild test \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1' \
  -only-testing:SequenceGameTests/SequenceGameTests/testStartGamePlayers
```

### Run All Tests with Verbose Output
```bash
xcodebuild test \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1' \
  -verbose \
  2>&1 | tee test-verbose.log
```

### Check Test List
```bash
xcodebuild test \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1' \
  -dry-run
```

---

## 🔍 IDENTIFY WHICH TESTS ARE FAILING

Run this to get a summary:
```bash
xcodebuild test \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1' \
  2>&1 | grep -E "(Test Case|failed|passed|error)"
```

---

## 🎯 KNOWN ISSUES IN YOUR TEST SUITE

Based on code review, these tests are **expected to fail**:

### 1. Jack Tests (2 tests)
```swift
testComputePlayableTiles_twoEyedJack_returnsAllEmptyNonCornerTiles
testComputePlayableTiles_oneEyedJack_returnsOnlyTilesWithChips
```

**Reason:** Test comments say "will fail with current implementation"

**Options:**
- **Option A:** Disable these tests temporarily:
```swift
@Test(.disabled("Jack logic pending implementation"))
func computePlayableTiles_twoEyedJack_returnsAllEmptyNonCornerTiles() {
```

- **Option B:** Implement Jack handling in GameState
- **Option C:** Accept that 2 tests fail (not recommended for CI)

### 2. Randomness-Based Tests
```swift
testShuffle
testShuffleAndCardDraw
```

**Potential Issue:** Random failures due to shuffle randomness

**Fix:** If these fail occasionally, make them deterministic or use seeded random.

---

## 📝 FIX CHECKLIST FOR CI

- [ ] All tests pass locally in Xcode (⌘U)
- [ ] All tests pass from command line
- [ ] Known failing tests are marked with `.disabled()`
- [ ] Test target has Host Application set
- [ ] Scheme has Test action enabled and shared
- [ ] Enable Testability is YES for Debug builds
- [ ] No flaky tests based on randomness
- [ ] No hardcoded paths in tests
- [ ] No tests requiring specific user data

---

## 🚀 QUICK FIX WORKFLOW

1. **Run tests in Xcode first:**
   - Press ⌘U
   - See which tests fail
   - Fix those tests

2. **Then run from command line:**
   ```bash
   xcodebuild test \
     -project SequenceGame/SequenceGame.xcodeproj \
     -scheme SequenceGame \
     -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1'
   ```

3. **If command line fails but Xcode passes:**
   - Check scheme configuration
   - Check test target settings
   - Verify scheme is shared

4. **If specific tests fail:**
   - Read the test code and comments
   - Check for "expected to fail" comments
   - Mark as `.disabled()` if implementation pending

---

## 💡 TEMPORARY CI WORKAROUND

If you need CI to pass NOW while fixing tests:

### Option 1: Disable Known Failing Tests
Mark Jack tests as disabled:
```swift
@Test(.disabled("Jack logic not yet implemented"))
func computePlayableTiles_twoEyedJack_returnsAllEmptyNonCornerTiles() {
```

### Option 2: Separate CI from Dev Tests
Create two schemes:
- **SequenceGame** - all tests (for development)
- **SequenceGame-CI** - only stable tests (for CI)

Then in CI:
```yaml
-scheme SequenceGame-CI
```

### Option 3: Accept Test Failures (Not Recommended)
In `ci_composer.yml`, allow test failures:
```yaml
- name: Run Tests
  continue-on-error: true  # Not recommended!
```

---

## 📞 NEXT STEPS

**Please share:**
1. The exact error output from terminal
2. Which test(s) are failing
3. Does `⌘U` in Xcode pass all tests?

**Then I can give you:**
- Exact fix for the specific failing tests
- Whether to disable tests or fix implementation
- How to update CI to handle it

---

## 🎓 COMMON PATTERNS IN YOUR TESTS

Your test suite uses **Swift Testing** framework (not XCTest), which means:

✅ **Good:**
- Modern `#expect()` syntax
- Clear test names with `@Test("description")`
- Struct-based test organization

⚠️ **Watch Out:**
- No `setUp()` or `tearDown()` - state must be reset in each test
- Tests must be independent
- Flaky tests will randomly fail

**Best Practice:**
Each test should:
1. Create fresh `GameState()`
2. Set up test data
3. Perform action
4. Verify result
5. Not depend on other tests

Your tests follow this pattern well! ✅

---

**To get specific help, please share the test failure output!** 🚀
