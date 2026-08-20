# One More Tap

A fast, one-finger iPhone arcade game built with SwiftUI + SpriteKit.

## Classic mode

- One rule: tap when the orbiting orb reaches the highlighted target arc.
- Perfect hits build combo and award bonus score/coins.
- Speed ramps up, the target shrinks, and direction changes begin at higher scores.
- A miss ends the run immediately, with one optional rewarded-video continue per run.
- Best score, coins, selected theme, sound and haptic preferences persist locally.
- Pause/resume, background handling, instant retry, and a polished game-over loop are included.

## Monetization shell

- StoreKit 2 non-consumables: Remove Ads and cosmetic theme packs.
- Google Mobile Ads rewarded continue and conservative interstitial pacing.
- Google UMP consent gate before ad requests, plus Privacy Options when required.
- Automatic interstitials begin only on the fourth restart and then every third restart.
- Remove Ads removes automatic interstitials; rewarded continue remains optional.
- Neon is free; Fire, Galaxy and Retro are cosmetic paid themes, with All Themes bundle support.

Development builds use Google's official public test ad identifiers. Production AdMob IDs, App Store Connect products and final privacy disclosures are release configuration, not hard-coded secrets.

## Tech

- iOS 17+
- Swift 6
- SwiftUI shell + SpriteKit game scene
- Pure Swift `OneMoreTapCore` package for deterministic gameplay rules and Linux/macOS unit tests
- StoreKit 2
- Google Mobile Ads SDK + Google User Messaging Platform through Swift Package Manager
- Privacy manifest included for local app storage; third-party SDK privacy manifests are supplied by their packages

## Build

Open `OneMoreTap.xcodeproj`, select the `OneMoreTap` scheme, resolve Swift packages, and run on an iPhone or iPhone Simulator.

The project uses bundle identifier `com.kamilunavo.onemoretap`. Set the Apple Development Team in Xcode before installing on a physical device or archiving.

## Test

```sh
cd OneMoreTapCore
swift test
```

CI also builds the iOS app for the Simulator with code signing disabled.

## Status

Classic is locked and complete. The monetization implementation is on `feat/monetization-shell`; production store/ad configuration and physical-device/TestFlight QA remain release gates.
