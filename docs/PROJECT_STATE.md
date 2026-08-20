# NavoTap — Project State

Last updated: 2026-08-20

## Identity

**Customer-facing product name: NavoTap — LOCKED.**

The former working name `One More Tap` is retired because an existing App Store game already uses that name and closely overlaps the mechanic. Do not reuse it in store metadata or branding.

Technical identifiers created before the rename remain intentionally stable:

- Bundle ID: `com.kamilunavo.onemoretap`
- StoreKit product IDs under `com.kamilunavo.onemoretap.*`
- Source directory / core-package legacy paths may still contain `OneMoreTap`

These are implementation identifiers, not customer-facing branding, and must not be renamed casually after store setup.

## Current milestone

**Classic mode: COMPLETE and locked.**

**Monetization/release code: COMPLETE and merged to `main`.**

NavoTap includes rotating-orb Classic gameplay, target/perfect zones, combo, score, coins, progressive difficulty, direction reversals, game-over/retry, one rewarded continue per run, conservative interstitials, Remove Ads, cosmetic themes, StoreKit 2 restore/entitlements, UMP consent/privacy-options flow, sound, haptics and local persistence.

## Product rules locked for Classic

- Portrait iPhone-first game.
- One-finger input; no swipe/drag controls.
- Run starts and restarts immediately.
- One miss ends the run unless the player uses the single rewarded continue.
- Difficulty increases continuously rather than via authored levels.
- Perfect hits are rewarded but not required.
- No pay-to-win purchases.
- Theme purchases are cosmetic only.

## Monetization rules

- One optional rewarded-video continue per run.
- Continue preserves score/coins, resets combo and cannot double-commit a run.
- First automatic interstitial is on restart #4, then every third restart (#7, #10, ...), if loaded.
- Remove Ads disables automatic interstitials only; rewarded continue remains optional.
- Neon is free; Fire, Galaxy, Retro and All Themes are supported.

## Validation baseline

Before the NavoTap branding pass, the release implementation passed:

- 9/9 core regression tests.
- Xcode 26.2 iOS Simulator build.
- GoogleMobileAds 13.8.0 and GoogleUserMessagingPlatform 3.1.0 package resolution.

The NavoTap rebrand must pass the same CI gates before merge.

## Branding implementation

- Home title: `NAVOTAP`.
- iOS `CFBundleDisplayName`: `NavoTap`.
- Swift app entry point: `NavoTapApp`.
- Xcode target/product: `NavoTap` / `NavoTap.app`.
- Shared Xcode scheme: `NavoTap`.
- Local StoreKit configuration file: `NavoTap.storekit`.
- App Store Connect / AdMob documentation uses NavoTap.

## Remaining external release gates

1. App Store Connect: create/select **NavoTap** and create the five locked non-consumable IAPs.
2. AdMob: create the NavoTap iOS app plus rewarded/interstitial ad units and replace sample/test IDs.
3. Configure production UMP Privacy & Messaging.
4. Complete App Privacy answers for the final production ads configuration.
5. Archive/sign and upload a TestFlight release candidate.
6. Physical iPhone QA for gameplay, purchases, restore, ads, themes and lifecycle handling.
7. Submit only after `docs/RELEASE_CHECKLIST.md` is fully satisfied.
