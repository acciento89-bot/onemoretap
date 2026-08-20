# One More Tap

A fast, one-finger iPhone arcade game built with SwiftUI + SpriteKit.

## Classic mode

- One rule: tap when the orbiting orb reaches the highlighted target arc.
- Perfect hits build combo and award bonus score/coins.
- Speed ramps up, the target shrinks, and direction changes begin at higher scores.
- A miss ends the run immediately.
- Best score, coins, sound and haptic preferences persist locally.
- Pause/resume, automatic background pausing, instant retry, and a polished game-over loop are included.

## Tech

- iOS 17+
- Swift 6
- SwiftUI shell + SpriteKit game scene
- Pure Swift `OneMoreTapCore` package for deterministic gameplay rules and Linux/macOS unit tests
- No third-party runtime dependencies
- Privacy manifest included; Classic mode collects no user data and performs no tracking

## Build

Open `OneMoreTap.xcodeproj`, select the `OneMoreTap` scheme, and run on an iPhone or iPhone Simulator.

The project currently uses bundle identifier `com.kamilunavo.onemoretap`. Set the Apple Development Team in Xcode before installing on a physical device or archiving.

## Test

```sh
cd OneMoreTapCore
swift test
```

CI also builds the iOS app for the Simulator with code signing disabled.

## Status

Classic is feature-complete. Monetization (rewarded continue, interstitial pacing, remove-ads and cosmetic packs) is intentionally kept out of the gameplay core and can be added as the next pass without changing Classic's mechanics.
