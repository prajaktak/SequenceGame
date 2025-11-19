# Xcode Project Settings for CI Alignment
## Configuration Guide for SequenceGame

**Purpose:** Align Xcode project settings with `ci_claude.yml` for successful CI builds and tests

**Date:** November 19, 2025

---

## 🎯 Critical Settings Checklist

### ✅ STEP 1: Share the Scheme (MOST IMPORTANT)

**Why:** GitHub Actions cannot access private/user schemes. The scheme MUST be shared.

**How to Fix:**
1. Open `SequenceGame.xcodeproj` in Xcode
2. Go to: **Product → Scheme → Manage Schemes...** (or press `⌘<`)
3. Find your `SequenceGame` scheme in the list
4. ✅ **CHECK the "Shared" checkbox** next to `SequenceGame`
5. Click "Close"

**What this does:**
- Moves scheme from `xcuserdata` (user-specific, not in git)
- To `xcshareddata` (shared, committed to git)
- CI can now see and use the scheme

**Verify:**
```bash
# Run this in Terminal to verify the scheme is shared:
ls -la SequenceGame/SequenceGame.xcodeproj/xcshareddata/xcschemes/

# You should see: SequenceGame.xcscheme
```

**After fixing, commit this file:**
```
SequenceGame/SequenceGame.xcodeproj/xcshareddata/xcschemes/SequenceGame.xcscheme
```

---

### ✅ STEP 2: Configure Test Action in Scheme

**Why:** CI needs tests enabled and properly configured

**How to Fix:**
1. **Product → Scheme → Edit Scheme...** (or press `⌘<` then click "Edit")
2. Select **"Test"** in the left sidebar
3. In the "Info" tab, verify:
   - ✅ **"SequenceGameTests"** is checked (enabled)
   - ✅ Any other test targets are also checked
4. Click the **Options** tab
5. Verify settings:
   - ✅ **Code Coverage:** Check "Gather coverage for: Some targets" or "All targets"
   - ✅ **Language & Region:** Set to your preference (or leave default)
   - ✅ **Application Language:** System Language (recommended)
6. Click "Close"

**What to Check:**
- Under "Test" action, expand your test target
- Make sure all test classes are included (not greyed out)

---

### ✅ STEP 3: Build Settings - Code Signing

**Why:** CI builds don't have signing certificates, must be disabled for testing

**How to Fix:**
1. Select **SequenceGame project** (blue icon) in Project Navigator
2. Select **SequenceGame target** (under TARGETS)
3. Click **"Build Settings"** tab
4. Search for: `code sign`
5. Configure these settings:

**For the Debug configuration:**
- ✅ **Code Signing Identity → Debug → Any iOS SDK:** "Apple Development" (default is fine)
- ✅ **Code Signing Required:** `YES` (default is fine - CI overrides this)
- ✅ **Code Signing Style:** "Automatic" (default is fine)

**Note:** The CI already overrides these with:
```yaml
CODE_SIGN_IDENTITY=""
CODE_SIGNING_REQUIRED=NO
```
So your local settings can stay as-is. CI will disable them.

---

### ✅ STEP 4: Build Settings - Deployment Target

**Why:** Must be compatible with simulator versions in CI

**How to Fix:**
1. In **Build Settings** tab
2. Search for: `deployment target`
3. Find: **iOS Deployment Target**
4. Set to: **17.0 or higher** (CI uses iOS 18.1, so 17.0+ is safe)

**Recommended:** iOS 17.0
- Compatible with Xcode 16.1
- Works on iOS 18.1 simulators in CI
- Still supports most users (iOS 17+)

---

### ✅ STEP 5: Test Target Configuration

**Why:** Test target needs proper host application

**How to Fix:**
1. Select **SequenceGameTests target** (under TARGETS)
2. Go to **"General"** tab
3. Verify:
   - ✅ **Host Application:** Must be set to "SequenceGame"
   - ✅ **Testing** section shows it's an application test bundle
4. Go to **"Build Settings"** tab
5. Search for: `test host`
6. Verify:
   - ✅ **Bundle Loader:** Should point to `$(TEST_HOST)`
   - ✅ **Test Host:** Should be `$(BUILT_PRODUCTS_DIR)/SequenceGame.app/SequenceGame`

**If these are blank or wrong:**
- Your tests won't run in CI
- Fix by setting Host Application in General tab

---

### ✅ STEP 6: Scheme - Build Configuration

**Why:** Ensure Debug configuration is used for testing

**How to Fix:**
1. **Product → Scheme → Edit Scheme...**
2. Select **"Test"** in left sidebar
3. At the top: **Build Configuration** dropdown
4. Set to: **Debug** (should be default)
5. Click "Close"

---

### ✅ STEP 7: Enable Testability

**Why:** Some tests need access to internal members

**How to Fix:**
1. Select **SequenceGame target** (under TARGETS)
2. Go to **"Build Settings"** tab
3. Search for: `testability`
4. Find: **Enable Testability**
5. Set **Debug** to: **Yes**
6. Set **Release** to: **No** (default)

**What this does:**
- Allows `@testable import SequenceGame` in test files
- Only enabled for Debug builds (not in production)

---

### ✅ STEP 8: Build Phases - Headers

**Why:** Sometimes private headers cause CI issues

**How to Fix:**
1. Select **SequenceGame target**
2. Click **"Build Phases"** tab
3. Check if there's a **"Headers"** phase
4. If exists: Make sure no headers are marked "Private"
5. If any issues: Set headers to "Project" or "Public"

**For most iOS apps:** You likely don't have a Headers phase - that's fine!

---

### ✅ STEP 9: Simulator Compatibility Check

**Why:** Ensure app runs on simulators CI will use

**How to Fix:**
1. In Xcode, select simulator: **iPhone 16** or **iPhone 15**
2. Build and run: **⌘R**
3. Run tests: **⌘U**
4. If both succeed locally → should work in CI

**Test these simulators:**
- ✅ iPhone 16 (iOS 18.x) - Primary CI target
- ✅ iPhone 15 (iOS 18.x) - Fallback target

---

### ✅ STEP 10: Remove Hardcoded Paths

**Why:** Absolute paths break in CI environment

**How to Check:**
1. In **Build Settings**, search for each:
   - `framework search paths`
   - `library search paths`
   - `header search paths`
2. Make sure NO paths contain:
   - ❌ `/Users/yourname/...`
   - ❌ Absolute paths starting with `/`
3. Use relative paths or Xcode variables:
   - ✅ `$(SRCROOT)/Frameworks`
   - ✅ `$(PROJECT_DIR)/Libraries`
   - ✅ `$(inherited)`

---

## 🔧 ADVANCED SETTINGS (If Issues Persist)

### Setting A: Package Dependencies
If you use Swift Package Manager dependencies:

1. **File → Packages → Resolve Package Versions**
2. Make sure `Package.resolved` is committed to git
3. In CI, packages will auto-download

### Setting B: Derived Data Location
If builds are inconsistent:

1. **Xcode → Settings... → Locations**
2. **Derived Data:** Set to "Relative" or specific location
3. CI uses: `-derivedDataPath .build` (already configured)

### Setting C: Build System
Ensure modern build system:

1. **File → Project Settings...** (or Workspace Settings)
2. **Build System:** "New Build System" (default in Xcode 14+)
3. Should already be set correctly

---

## 📋 VERIFICATION STEPS

### Local Testing (Before Pushing to CI)

**Step 1: Clean Build from Command Line**
```bash
# Navigate to your project directory
cd /path/to/SequenceGame

# Clean
xcodebuild clean \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame

# Build
xcodebuild build \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO

# If successful, run tests
xcodebuild test \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

**Expected Output:**
```
** BUILD SUCCEEDED **
** TEST SUCCEEDED **
```

**If this works locally → CI should work too!**

### Step 2: Verify Scheme is Shared
```bash
# Check if scheme exists in shared location
cat SequenceGame/SequenceGame.xcodeproj/xcshareddata/xcschemes/SequenceGame.xcscheme

# Should output XML scheme configuration
```

### Step 3: Check Git Status
```bash
git status

# You should see (if not already committed):
# modified:   SequenceGame/SequenceGame.xcodeproj/project.pbxproj
# new file:   SequenceGame/SequenceGame.xcodeproj/xcshareddata/xcschemes/SequenceGame.xcscheme
```

**Commit these changes!**

---

## 🚨 COMMON ISSUES & FIXES

### Issue 1: "Scheme not found"
**Symptom:** CI says "Scheme SequenceGame does not exist"

**Fix:**
- ✅ Follow STEP 1 - Share the scheme
- ✅ Commit the `.xcscheme` file
- ✅ Push to GitHub

### Issue 2: "No tests ran"
**Symptom:** Build succeeds but "Executed 0 tests"

**Fix:**
- ✅ Follow STEP 2 - Enable test target in scheme
- ✅ Follow STEP 5 - Configure host application
- ✅ Verify test target builds for testing

### Issue 3: "Code signing error"
**Symptom:** CI fails with provisioning profile error

**Fix:**
- ✅ Already handled in `ci_claude.yml` with:
  ```yaml
  CODE_SIGN_IDENTITY=""
  CODE_SIGNING_REQUIRED=NO
  ```
- ✅ If still failing, check STEP 3

### Issue 4: "@testable import not working"
**Symptom:** Tests can't access app code

**Fix:**
- ✅ Follow STEP 7 - Enable Testability
- ✅ Make sure you're using `@testable import SequenceGame` in test files

### Issue 5: "Simulator not found" (Still!)
**Symptom:** Even with new CI config

**Fix:**
- ✅ Check STEP 4 - Deployment target too high?
- ✅ If deployment target is iOS 19.0 → set to iOS 17.0
- ✅ CI runs iOS 18.1 simulators

---

## 📝 SETTINGS SUMMARY TABLE

| Setting | Location | Required Value | Why |
|---------|----------|----------------|-----|
| Shared Scheme | Manage Schemes | ✅ Checked | CI can access |
| Test Action | Edit Scheme → Test | ✅ Enabled | Tests run in CI |
| Code Coverage | Edit Scheme → Test → Options | ✅ Enabled | Coverage reports |
| Deployment Target | Build Settings | iOS 17.0+ | Simulator compatibility |
| Host Application | Test Target → General | SequenceGame | Tests need host |
| Enable Testability | Build Settings → Debug | ✅ Yes | @testable imports |
| Build Configuration | Edit Scheme → Test | Debug | Proper build type |

---

## 🎯 QUICK START CHECKLIST

Before running CI, verify:

- [ ] Scheme is shared (checkbox in Manage Schemes)
- [ ] Tests are enabled in scheme (Edit Scheme → Test)
- [ ] Code coverage is enabled (Edit Scheme → Test → Options)
- [ ] Deployment target is iOS 17.0 or higher
- [ ] Test target has SequenceGame as host application
- [ ] Enable Testability is YES for Debug
- [ ] Project builds locally with `xcodebuild` command
- [ ] Tests run locally with `xcodebuild test` command
- [ ] Shared scheme file is committed to git
- [ ] No hardcoded absolute paths in build settings

---

## 🔍 DEBUGGING COMMANDS

If CI still fails, run these locally to diagnose:

```bash
# List all schemes (verify SequenceGame is shared)
xcodebuild -list -project SequenceGame/SequenceGame.xcodeproj

# Show build settings
xcodebuild -showBuildSettings \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame

# Verbose test run
xcodebuild test \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -verbose

# Check test target configuration
xcodebuild test \
  -project SequenceGame/SequenceGame.xcodeproj \
  -scheme SequenceGame \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -dry-run
```

---

## 📦 FILES TO COMMIT

After making these changes, commit:

```
✅ SequenceGame/SequenceGame.xcodeproj/project.pbxproj
✅ SequenceGame/SequenceGame.xcodeproj/xcshareddata/xcschemes/SequenceGame.xcscheme
✅ ci_claude.yml (your new CI config)
```

**DO NOT COMMIT:**
```
❌ SequenceGame/SequenceGame.xcodeproj/xcuserdata/ (user-specific)
❌ SequenceGame/SequenceGame.xcodeproj/project.xcworkspace/xcuserdata/ (user-specific)
```

Make sure your `.gitignore` includes:
```
xcuserdata/
*.xcworkspace/xcuserdata/
```

---

## 🎓 BEST PRACTICES

### For Ongoing Maintenance:

1. **Always test locally first:**
   ```bash
   xcodebuild test -project ... -scheme ... -destination '...'
   ```

2. **Keep schemes shared:**
   - Never uncheck "Shared" in Manage Schemes
   - Commit scheme changes with project changes

3. **Monitor deployment target:**
   - When updating Xcode, verify deployment target compatibility
   - CI uses latest iOS runtime available

4. **Regular CI testing:**
   - Push to feature branch first
   - Verify CI passes before merging to main

5. **Keep CI config updated:**
   - When new Xcode versions release
   - Update runner version in ci_claude.yml

---

## 📞 STILL HAVING ISSUES?

If CI still fails after all these steps:

1. **Check the CI logs carefully** - look for the exact error
2. **Run the exact command locally** that CI runs
3. **Compare your local success with CI failure** - what's different?
4. **Verify GitHub runner compatibility:**
   - macos-15 = macOS 15.x
   - Xcode 16.1 = iOS 18.1 simulators

**Most common root cause:** Scheme not shared (STEP 1)

---

## ✅ SUCCESS CRITERIA

You'll know it's working when:

1. ✅ Local `xcodebuild test` command succeeds
2. ✅ CI runs without "scheme not found" error
3. ✅ CI runs without "simulator not found" error
4. ✅ Tests execute and report results
5. ✅ Green checkmark on GitHub Actions

---

**End of Configuration Guide**

**Next Step:** Make the changes in Xcode, commit the scheme, and push to GitHub. The `ci_claude.yml` + these settings = working CI! 🚀
