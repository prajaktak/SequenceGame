# CI Troubleshooting Summary - 2025-11-18

## 🐛 Error Encountered

```
xcodebuild: error: Unable to read project 'SequenceGame.xcodeproj'
Reason: The project 'SequenceGame' is damaged and cannot be opened
Exception: didn't find classname for 'isa' key
Error: Process completed with exit code 74
```

## 🔍 Root Cause

The error "didn't find classname for 'isa' key" typically indicates:
1. **Git line ending issues** - The project.pbxproj file is being corrupted during checkout
2. **Binary vs text handling** - Git may be treating the file incorrectly
3. **Simulator specification** - Specifying exact iOS version can fail if unavailable

## ✅ Fixes Applied

### 1. Created `.gitattributes` File
- Ensures project.pbxproj uses correct line endings (LF)
- Prevents Git from corrupting Xcode project files
- Sets proper binary/text handling for all file types

### 2. Enhanced Checkout
- Added `clean: true` for pristine checkout
- Added `fetch-depth: 1` for faster cloning

### 3. Improved Simulator Destination
- Changed from: `platform=iOS Simulator,name=iPhone 15,OS=17.2`
- Changed to: `platform=iOS Simulator,name=any iOS Simulator`
- More flexible, works across Xcode versions

### 4. Added Code Signing Flags
- `CODE_SIGN_IDENTITY=""`
- `CODE_SIGNING_REQUIRED=NO`
- **No Apple Developer account needed!**

### 5. Better Diagnostics
- Added project file validation
- Checks for encoding issues
- Shows file contents if problems detected

## 📝 What You Need to Do

### Step 1: Commit the changes
```bash
# The CI file has been updated automatically
git add ci.yml

# Add the new .gitattributes file
git add .gitattributes

# Commit everything
git commit -m "fix: Resolve CI project file corruption issue

- Add .gitattributes to handle Xcode files properly
- Use 'any iOS Simulator' instead of specific version
- Add code signing bypass flags (no Apple account needed)
- Enhanced checkout with clean: true
- Better diagnostic steps for troubleshooting"

# Push to trigger CI
git push
```

### Step 2: If It Still Fails

If the error persists, run this locally to fix the project file:

```bash
# 1. Normalize the project file
cd SequenceGame
git rm --cached SequenceGame.xcodeproj/project.pbxproj
git add SequenceGame.xcodeproj/project.pbxproj

# 2. Open in Xcode and save
open SequenceGame.xcodeproj
# In Xcode: File → Save (Cmd+S)
# Close Xcode

# 3. Commit the normalized file
git add SequenceGame.xcodeproj/project.pbxproj
git commit -m "fix: Normalize project.pbxproj line endings"
git push
```

### Step 3: Check the Diagnostic Output

The new diagnostic step will show:
- ✅ File encoding (should be UTF-8)
- ✅ Basic structure validation
- ✅ Scheme listing (this is where it was failing)
- ❌ If it fails, it will show the first 100 lines of project.pbxproj

## 🎯 Why No Apple Developer Account Needed

### Tests on Simulators = FREE
- ✅ Unit tests run on simulators
- ✅ UI tests run on simulators
- ✅ Simulators don't require code signing
- ✅ Code signing is only needed for real devices

### When You WOULD Need It
- ❌ Testing on physical devices
- ❌ Distributing to TestFlight
- ❌ Publishing to App Store
- ❌ Using certain entitlements (push notifications, etc.)

### CI Best Practices
We've added explicit flags to bypass signing:
```bash
CODE_SIGN_IDENTITY=""        # No signing identity
CODE_SIGNING_REQUIRED=NO     # Don't require signing
```

## 📊 Expected Results After This Fix

### The Diagnostic Step Will Show:
```
📋 Checking project.pbxproj file...
SequenceGame/SequenceGame.xcodeproj/project.pbxproj: UTF-8 Unicode text

🔍 Searching for potential issues...
✅ Basic checks passed

📋 Attempting to list schemes...
Information about project "SequenceGame":
    Targets:
        SequenceGame
        SequenceGameTests
        SequenceGameUITests
    Schemes:
        SequenceGame
✅ Successfully listed schemes
```

### Then Build & Tests Will Run Successfully

## 🔧 Additional Troubleshooting Commands

If you still have issues, run these locally:

```bash
# Check what Xcode version CI is using
xcodebuild -version

# List available simulators
xcrun simctl list devices available

# Verify project locally
xcodebuild -project SequenceGame/SequenceGame.xcodeproj -list

# Check file encoding
file SequenceGame/SequenceGame.xcodeproj/project.pbxproj

# Validate no merge conflicts
grep -n "<<<\|>>>" SequenceGame/SequenceGame.xcodeproj/project.pbxproj
```

## 📚 Files Modified

1. ✅ `ci.yml` - Updated with fixes
2. ✅ `.gitattributes` - Created (ensures proper file handling)
3. ✅ `CI_TROUBLESHOOTING.md` - This document

## 🎉 Next Steps

1. **Commit and push the changes above**
2. **Watch the GitHub Actions workflow run**
3. **Check the diagnostic output**
4. **If successful, tests will run!**
5. **If it fails, check the diagnostic output and share it**

## 💡 Pro Tip

The `.gitattributes` file is crucial for any Xcode project in Git. It prevents:
- Line ending issues across different OS
- Merge conflicts in project files
- File corruption during checkout
- Binary files being treated as text

**Always include `.gitattributes` in your iOS/macOS projects!**

---

**Created**: 2025-11-18  
**Issue**: Exit code 74 - Corrupted project file  
**Status**: Fixes applied, awaiting test  
**Confidence**: High - This is a known Git + Xcode issue
