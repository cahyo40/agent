---
name: app-store-publisher
description: "Expert mobile app publishing including App Store Connect, Google Play Console, release management, versioning, and ASO"
---

# App Store Publisher

## Overview

This skill helps you publish and manage mobile apps on Apple App Store and Google Play Store, including release management, versioning, and app store optimization.

## When to Use This Skill

- Use when publishing apps to stores
- Use when managing app releases
- Use when optimizing store listings
- Use when handling app review issues

## How It Works

### Step 1: Version Management

```
VERSIONING STRATEGY
├── Version Number (User-facing)
│   └── MAJOR.MINOR.PATCH (e.g., 2.1.0)
│       ├── MAJOR: Breaking changes, redesigns
│       ├── MINOR: New features
│       └── PATCH: Bug fixes
│
└── Build Number (Internal)
    └── Incremental integer (e.g., 142)
    └── Always increment for each upload
```

### Step 2: iOS App Store Connect

```bash
# Using Fastlane for iOS
# Fastfile
lane :release do
  increment_build_number
  build_app(scheme: "MyApp")
  upload_to_app_store(
    skip_screenshots: true,
    skip_metadata: false,
    submit_for_review: true,
    automatic_release: false,
    submission_information: {
      add_id_info_uses_idfa: false
    }
  )
end

# TestFlight beta
lane :beta do
  build_app(scheme: "MyApp")
  upload_to_testflight(
    skip_waiting_for_build_processing: true
  )
end
```

### Step 3: Google Play Console

```bash
# Fastlane for Android
lane :release do
  gradle(task: "bundleRelease")
  upload_to_play_store(
    track: "production",
    release_status: "completed",
    aab: "app/build/outputs/bundle/release/app-release.aab"
  )
end

# Staged rollout
lane :staged_rollout do
  upload_to_play_store(
    track: "production",
    rollout: "0.1"  # 10% rollout
  )
end
```

### Step 4: App Store Optimization (ASO)

```markdown
## ASO Checklist

### Title & Subtitle
- [ ] Include primary keyword
- [ ] Keep under character limit (30 chars iOS)
- [ ] Make it memorable

### Keywords (iOS)
- [ ] Use all 100 characters
- [ ] No spaces after commas
- [ ] No duplicates from title

### Screenshots
- [ ] Show key features first
- [ ] Add compelling captions
- [ ] Use device frames

### Description
- [ ] First 3 lines are crucial
- [ ] Include social proof
- [ ] Clear call-to-action
```

## Best Practices

### ✅ Do This

- ✅ Test on TestFlight/Internal Testing first
- ✅ Use staged rollouts for major updates
- ✅ Localize store listings
- ✅ Monitor crash reports post-release
- ✅ Respond to user reviews

### ❌ Avoid This

- ❌ Don't forget to increment build number
- ❌ Don't skip metadata review
- ❌ Don't ignore rejection feedback

## Related Skills

- `@senior-ios-developer` - iOS development
- `@senior-android-developer` - Android development
