# Local Command Line Build Debugging Guide

**Issue:** "Simulator not found" error when building from command line  
**Date:** November 19, 2025

---

## 🔍 STEP-BY-STEP DEBUGGING

Run these commands **in order** and share the output with me:

---

### STEP 1: Check Xcode Installation

```bash
# What Xcode version do you have?
xcodebuild -version

# Where is Xcode installed?
xcode-select -p

# List all installed Xcode versions
ls -la /Applications/ | grep Xcode
```

**Expected Output:**
```
Xcode 16.1
Build version 16B40
/Applications/Xcode.app/Contents/Developer
```

---

### STEP 2: List ALL Available Simulators

```bash
# List ALL iOS simulators (available and unavailable)
xcrun simctl list devices iOS

# List just available ones
xcrun simctl list devices available iOS

# Check iOS runtimes installed
xcrun simctl list runtimes iOS
```

**What to Look For:**
- Do you see "iPhone 16" in the list?
- Do you see "iOS 18.1" runtime?
- Are any simulators marked "(unavailable)"?

---

### STEP 3: Check Valid Destinations for Your Project

```bash
# Navigate to your project first
cd /path/to/your/SequenceGame/parent/directory

# Show destinations (like Composer does)
xcodebuild -showdestinations \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame 2>&1
```

**This will show EXACTLY which destinations are valid!**

---

### STEP 4: Verify Scheme is Shared

```bash
# Check if scheme exists in shared location
ls -la SequenceGame/SequenceGame.xcodeproj/xcshareddata/xcschemes/

# Should show: SequenceGame.xcscheme
```

**If you see "No such file or directory":**
- ❌ Your scheme is NOT shared
- ✅ Follow STEP 1 in `XCODE_PROJECT_SETTINGS_FOR_CI.md`

---

### STEP 5: Try Different Destination Formats

Try these commands **one by one** and see which works:

**Option A: Explicit iPhone 16 with OS**
```bash
xcodebuild build \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

**Option B: iPhone 16 without OS (auto-detect)**
```bash
xcodebuild build \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

**Option C: iPhone 15 (fallback)**
```bash
xcodebuild build \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

**Option D: Any available simulator**
```bash
xcodebuild build \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,OS=latest' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

**Option E: Let Xcode pick**
```bash
xcodebuild build \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -sdk iphonesimulator \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

---

## 🚨 COMMON CAUSES & FIXES

### Cause 1: Scheme Not Shared
**Symptom:** "Scheme SequenceGame does not exist"

**Fix:**
1. Open Xcode
2. Product → Scheme → Manage Schemes (⌘<)
3. Check "Shared" next to SequenceGame
4. Close Xcode
5. Try command again

---

### Cause 2: Wrong Xcode Selected
**Symptom:** "Simulator not found" or old iOS version

**Fix:**
```bash
# If you have multiple Xcode versions:
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# Or if you have Xcode 16.1 specifically:
sudo xcode-select -s /Applications/Xcode_16.1.app/Contents/Developer

# Run first launch (may be needed)
sudo xcodebuild -runFirstLaunch

# Try build again
```

---

### Cause 3: iPhone 16 Not Available on Your Mac
**Symptom:** iPhone 16 listed but marked "(unavailable)"

**Possible Reasons:**
- You have Xcode 15.x (doesn't have iPhone 16)
- iOS 18.1 runtime not installed
- Simulator corrupted

**Fix:**
```bash
# Check your actual Xcode version
xcodebuild -version

# If it's NOT 16.1 or higher, you don't have iPhone 16
# Use iPhone 15 instead in your destination
```

---

### Cause 4: Deployment Target Too High
**Symptom:** Build fails with "unsupported minimum deployment target"

**Fix:**
1. Open project in Xcode
2. Select SequenceGame target
3. Build Settings → iOS Deployment Target
4. Set to match available iOS runtime (check STEP 2 output)

---

### Cause 5: Simulator Runtime Not Downloaded
**Symptom:** iPhone exists but runtime is missing

**Fix:**
```bash
# Download iOS 18.1 runtime (if not installed)
# This takes 5-8 GB and 10-30 minutes!
xcodebuild -downloadPlatform iOS

# Check available runtimes again
xcrun simctl list runtimes iOS
```

---

## 💡 QUICK DIAGNOSTICS

### Run this all-in-one diagnostic:

```bash
echo "=== DIAGNOSTIC START ==="
echo ""
echo "1. Xcode Version:"
xcodebuild -version
echo ""
echo "2. Xcode Path:"
xcode-select -p
echo ""
echo "3. Available iPhones:"
xcrun simctl list devices available | grep iPhone | head -10
echo ""
echo "4. iOS Runtimes:"
xcrun simctl list runtimes iOS
echo ""
echo "5. Scheme Check:"
ls -la SequenceGame/SequenceGame.xcodeproj/xcshareddata/xcschemes/ 2>&1
echo ""
echo "6. Valid Destinations:"
xcodebuild -showdestinations -project SequenceGame/SequenceGame.xcodeproj -scheme SequenceGame 2>&1 | grep -i simulator
echo ""
echo "=== DIAGNOSTIC END ==="
```

**Copy and paste ALL the output** and I can tell you exactly what's wrong!

---

## 🎯 MOST LIKELY SOLUTIONS

Based on typical "simulator not found" errors:

### Solution 1: You Don't Have iPhone 16 (Most Common)

**If you have Xcode 15.x:**
```bash
# Use iPhone 15 instead
xcodebuild build \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

### Solution 2: Scheme Not Shared
Follow Xcode Settings guide STEP 1 to share the scheme.

### Solution 3: Wrong Xcode Selected
```bash
# Point to correct Xcode
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

---

## 📋 WHAT TO SHARE WITH ME

Please run these and share the output:

```bash
# 1. Your Xcode version
xcodebuild -version

# 2. Available simulators
xcrun simctl list devices available | grep iPhone

# 3. What destinations are valid
xcodebuild -showdestinations \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame 2>&1

# 4. The EXACT error message you're getting
# (Copy the full error from your terminal)
```

With this information, I can give you the **exact command** that will work on your Mac! 🎯

---

## 🔧 TEMPORARY WORKAROUND

While we debug, you can **build in Xcode** normally:
1. Open SequenceGame.xcodeproj in Xcode
2. Select any simulator (iPhone 15, 16, etc.)
3. Press ⌘B to build
4. Press ⌘U to run tests

This proves your project works - we just need to figure out the right command-line destination!

---

**Next Step:** Share the output of the diagnostic commands above and I'll give you the exact fix! 🚀
