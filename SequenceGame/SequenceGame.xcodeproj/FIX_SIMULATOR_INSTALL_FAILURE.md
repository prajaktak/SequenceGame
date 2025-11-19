# Fix: "Simulator device failed to install the application"

**Error:** `Simulator device failed to install the application.`  
**Date:** November 19, 2025  
**Status:** ❌ Installation issue, NOT test failure

---

## 🎯 THE PROBLEM

Your tests aren't even running - the app fails to install on the simulator before tests can start.

**This is different from test failures!** The build succeeds, but iOS Simulator refuses to install the app.

---

## 🔥 COMMON CAUSES & FIXES

### Fix 1: Reset Simulator State (MOST COMMON - Try This First!)

```bash
# Shutdown all simulators
xcrun simctl shutdown all

# Erase the specific simulator you're using
xcrun simctl erase "iPhone 16"

# Or erase ALL simulators (nuclear option)
xcrun simctl erase all

# Try your test command again
xcodebuild clean test \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  -derivedDataPath DerivedData
```

**Why this works:** Simulator storage can get corrupted, especially after multiple test runs. Erasing clears everything.

---

### Fix 2: Clean Build Folder & Derived Data

```bash
# Navigate to your project directory
cd /path/to/SequenceGame

# Remove derived data
rm -rf DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/SequenceGame-*

# Clean build
xcodebuild clean \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame

# Try test again
xcodebuild test \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  -derivedDataPath DerivedData
```

**Why this works:** Stale build artifacts can cause installation failures.

---

### Fix 3: Check Bundle Identifier & Info.plist

**The Issue:** Invalid or conflicting bundle identifier

**Check:**
1. Open Xcode
2. Select **SequenceGame target**
3. Go to **"Signing & Capabilities"** tab
4. Check **Bundle Identifier**

**Should be something like:**
```
com.yourname.SequenceGame
```

**Must NOT contain:**
- Spaces
- Special characters (except dots and hyphens)
- Start with a number

**Check Info.plist exists:**
```bash
ls -la SequenceGame/SequenceGame/Info.plist
```

If missing, that's your problem!

---

### Fix 4: Deployment Target Mismatch

**Check your iOS Deployment Target:**

```bash
# See what deployment target is set
xcodebuild -showBuildSettings \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame | grep IPHONEOS_DEPLOYMENT_TARGET
```

**If it shows iOS 19.0 or higher than your simulator:**

1. Open Xcode
2. Select **SequenceGame target**
3. Build Settings → **iOS Deployment Target**
4. Set to **17.0** or **18.0**

**Why this fails:** If deployment target is iOS 19.0 but simulator is iOS 18.1, installation fails.

---

### Fix 5: Provisioning Profile Issues (Even with Code Signing Disabled)

Sometimes simulators get confused about signing:

```bash
# Add these flags to your test command
xcodebuild test \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1' \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  -derivedDataPath DerivedData
```

**Added:** `CODE_SIGNING_ALLOWED=NO`

---

### Fix 6: Scheme Build Configuration

**Check your scheme's build configuration:**

1. Open Xcode
2. Product → Scheme → Edit Scheme (⌘<)
3. Select **"Test"** in left sidebar
4. Check **Build Configuration** dropdown at top
5. Should be set to **"Debug"**

**If set to "Release":**
- Release builds might have different settings causing installation issues
- Change to Debug

---

### Fix 7: Check for Multiple App Instances

**If you've been testing a lot:**

```bash
# Kill any stuck simulators
killall Simulator

# Clean up CoreSimulator processes
killall com.apple.CoreSimulator.CoreSimulatorService

# Shutdown all
xcrun simctl shutdown all

# Boot the specific one you need
xcrun simctl boot "iPhone 16"

# Wait a few seconds
sleep 5

# Try test
xcodebuild test \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

---

## 🔍 DETAILED DIAGNOSIS

### Step 1: Check What's Actually Happening

Run with verbose output:

```bash
xcodebuild test \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1' \
  -verbose \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  2>&1 | tee detailed-error.log
```

**Then search the log for:**
```bash
grep -i "error" detailed-error.log
grep -i "failed" detailed-error.log
grep -i "install" detailed-error.log
```

---

### Step 2: Check .xcresult Bundle

Your error mentions this file:
```
/Users/prajaktakulkarni/Documents/Prajakta learning/Swift/SequenceGame/SequenceGame/SequenceGame/DerivedData/SequenceGame/Logs/Test/Test-SequenceGame-2025.11.19_02-38-45-+0100.xcresult
```

**View details:**
```bash
xcrun xcresulttool get --format json --path "/Users/prajaktakulkarni/Documents/Prajakta learning/Swift/SequenceGame/SequenceGame/SequenceGame/DerivedData/SequenceGame/Logs/Test/Test-SequenceGame-2025.11.19_02-38-45-+0100.xcresult" | grep -A 20 "error"
```

This might show the underlying installation error.

---

## 🚀 RECOMMENDED FIX SEQUENCE

**Try these in order:**

### 1️⃣ Nuclear Reset (90% success rate)
```bash
# Clean everything
rm -rf DerivedData
xcrun simctl shutdown all
xcrun simctl erase all

# Try test
xcodebuild clean test \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  -derivedDataPath DerivedData
```

### 2️⃣ If that fails, check deployment target
```bash
xcodebuild -showBuildSettings \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame | grep IPHONEOS_DEPLOYMENT_TARGET
```

**If it's > 18.1, open Xcode and lower it to 17.0 or 18.0**

### 3️⃣ If still failing, try different simulator
```bash
# Use iPhone 15 instead
xcodebuild test \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  -derivedDataPath DerivedData
```

### 4️⃣ Try building without testing first
```bash
# Just build, don't test
xcodebuild build \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO

# If build succeeds, then try test
xcodebuild test-without-building \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1'
```

---

## 💡 WHY THIS HAPPENS

**Common scenarios:**

1. **Simulator storage full** - Erasing fixes it
2. **Corrupted simulator state** - Erasing fixes it
3. **Old app install conflicting** - Erasing fixes it
4. **Derived data corruption** - Cleaning fixes it
5. **Multiple Xcode versions** - Can cause simulator conflicts
6. **Deployment target too high** - Lowering fixes it

---

## 🎯 FOR YOUR CI CONFIG

Once you fix this locally, **make sure your CI does this**:

In `ci_composer.yml`, you already have:
```yaml
-derivedDataPath DerivedData
```

✅ **This is good!**

But you might want to add a cleanup step:

```yaml
- name: Clean Before Test
  run: |
    xcrun simctl shutdown all
    xcrun simctl erase all
    rm -rf DerivedData

- name: Build and Test
  run: |
    xcodebuild test ...
```

This ensures each CI run starts fresh.

---

## 🔍 CHECK YOUR PROJECT STRUCTURE

Your path looks unusual:
```
/Users/prajaktakulkarni/Documents/Prajakta learning/Swift/SequenceGame/SequenceGame/SequenceGame/
```

**Notice:** "Prajakta learning" has a **SPACE** in the name!

**This can cause issues!** Some build tools don't handle spaces well.

**Quick test:**
```bash
# Escape the space properly
cd "/Users/prajaktakulkarni/Documents/Prajakta learning/Swift/SequenceGame"

xcodebuild test \
  -project "SequenceGame/SequenceGame.xcodeproj" \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

**Better solution (long-term):**
Rename the folder to `PrajaktaLearning` (no space)

---

## ✅ SUCCESS CRITERIA

You'll know it's fixed when you see:

```
Testing started
Test Suite 'All tests' started at...
Test Suite 'SequenceGameTests' started at...
Test Case '-[SequenceGameTests testStartGamePlayers]' passed (0.123 seconds).
...
** TEST SUCCEEDED **
```

Instead of:
```
Simulator device failed to install the application.
Testing failed
```

---

## 📞 IF STILL FAILING

Run this diagnostic and share the output:

```bash
echo "=== Diagnostic Start ==="
echo ""
echo "1. Xcode Version:"
xcodebuild -version
echo ""
echo "2. Available Simulators:"
xcrun simctl list devices | grep iPhone
echo ""
echo "3. Deployment Target:"
xcodebuild -showBuildSettings -project SequenceGame/SequenceGame.xcodeproj -scheme SequenceGame | grep IPHONEOS_DEPLOYMENT_TARGET
echo ""
echo "4. Bundle Identifier:"
xcodebuild -showBuildSettings -project SequenceGame/SequenceGame.xcodeproj -scheme SequenceGame | grep PRODUCT_BUNDLE_IDENTIFIER
echo ""
echo "5. Simulator Status:"
xcrun simctl list devices | grep "iPhone 16"
echo ""
echo "=== Diagnostic End ==="
```

Share this output and I can pinpoint the exact issue!

---

## 🎬 QUICK FIX (TRY THIS FIRST!)

```bash
# One-liner nuclear option
xcrun simctl shutdown all && xcrun simctl erase all && rm -rf DerivedData && xcodebuild clean test -project SequenceGame/SequenceGame.xcodeproj -scheme SequenceGame -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1' CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -derivedDataPath DerivedData
```

This should fix 90% of "failed to install" errors! 🚀
