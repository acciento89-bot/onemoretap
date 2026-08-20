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

**NavoTap branding pass: COMPLETE and CI-VALIDATED.**

**App Store / monetization account setup: COMPLETE through IAPs, App Privacy, production AdMob IDs and UMP consent configuration.**

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

## Branding implementation

- Home title: `NAVOTAP`.
- iOS `CFBundleDisplayName`: `NavoTap`.
- Swift app entry point: `NavoTapApp`.
- Xcode target/product: `NavoTap` / `NavoTap.app`.
- Shared Xcode scheme: `NavoTap`.
- Local StoreKit configuration file: `NavoTap.storekit`.
- App Store Connect / AdMob documentation uses NavoTap.

## Validation

- Core regression suite: 9/9.
- NavoTap rebrand GitHub Actions run `32409256186`: Core tests — success.
- NavoTap rebrand GitHub Actions run `32409256186`: Xcode 26.2 iOS Simulator `Build NavoTap` — success.
- Production AdMob GitHub Actions run `32410958142`: Core tests + Xcode 26.2 `Build NavoTap` — success.
- GoogleMobileAds 13.8.0 and GoogleUserMessagingPlatform 3.1.0 resolve in the iOS build.

## Account-side release state

- App Store Connect NavoTap record: complete.
- Five Non-Consumable IAPs: complete, user confirmed 2026-08-20.
- App Privacy: complete, user confirmed 2026-08-20.
- Production AdMob IDs: complete and merged to `main`.
- AdMob European regulations / UMP message: complete, user confirmed 2026-08-20.
- Dedicated NavoTap privacy page and app-ads.txt: code merged to Kamilunavo website.

## Remaining release gates

1. Verify the production website serves `/navotap/privacy` and `/app-ads.txt` publicly.
2. Run the guarded TestFlight workflow for NavoTap 0.2.0 (2) from `main` once the repository has the App Store Connect API secrets.
3. Confirm the build appears in App Store Connect/TestFlight.
4. Attach the first Non-Consumable IAPs to the first app-version review submission when selecting the version/build.
5. Physical iPhone QA for consent/privacy options, gameplay, purchases, restore, rewarded continue, interstitial cadence, Remove Ads, themes and lifecycle handling.
6. Submit only after `docs/RELEASE_CHECKLIST.md` is fully satisfied.
