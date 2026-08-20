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

**NavoTap branding: COMPLETE and CI-VALIDATED.**

**Production AdMob identifiers: CONFIGURED and CI-VALIDATED.**

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

## App Store Connect status

- NavoTap app exists for bundle ID `com.kamilunavo.onemoretap`.
- All five locked Non-Consumable IAPs have been created; user confirmed on 2026-08-20.
- Remaining IAP account work: confirm DE/EN localization, pricing/availability and add review screenshots/notes.
- First non-consumable IAPs must be attached to the first app-version submission that contains them.

## Production AdMob configuration

Production identifiers supplied by the publisher and merged to `main` in commit `1065c35b1805185dd171bed1ef98ac22866862db`:

- App ID: `ca-app-pub-8944085355624754~4792390111`
- Rewarded Continue: `ca-app-pub-8944085355624754/7162618768`
- Interstitial Restart: `ca-app-pub-8944085355624754/3694930864`
- Publisher ID for app-ads.txt: `pub-8944085355624754`

Dedicated web assets were added to the Kamilunavo website and merged to its `main` in commit `9f2d6d915ab74b65723a3e8b6e7e669408859fad`:

- Privacy policy: `https://kamilunavo.com/navotap/privacy`
- German alias: `https://kamilunavo.com/navotap/datenschutz`
- app-ads.txt: `https://kamilunavo.com/app-ads.txt`
- Expected seller declaration: `google.com, pub-8944085355624754, DIRECT, f08c47fec0942fa0`

The Kamilunavo website change passed TypeScript and Next.js production build in GitHub Actions run `32410968596`. Live deployment/reachability must still be confirmed before relying on the URLs in AdMob.

## Validation

- Core regression suite: 9/9.
- NavoTap rebrand GitHub Actions run `32409256186`: Core tests — success.
- NavoTap rebrand GitHub Actions run `32409256186`: Xcode 26.2 iOS Simulator `Build NavoTap` — success.
- Production-AdMob GitHub Actions run `32410958142`: Core tests — success.
- Production-AdMob GitHub Actions run `32410958142`: Xcode 26.2 iOS Simulator `Build NavoTap` — success.
- GoogleMobileAds 13.8.0 and GoogleUserMessagingPlatform 3.1.0 resolve in the iOS build.

## Remaining external release gates

1. AdMob: publish the European regulations/UMP consent message using `https://kamilunavo.com/navotap/privacy`.
2. Confirm the privacy URL and `app-ads.txt` are live after the Kamilunavo website deployment; later verify app-ads.txt status in AdMob once the App Store listing is crawlable.
3. App Store Connect: finish IAP DE/EN metadata, pricing/availability and review screenshots/notes.
4. Complete App Privacy answers for the final production Google Mobile Ads configuration.
5. Archive/sign and upload a TestFlight release candidate.
6. Physical iPhone QA for consent, gameplay, purchases, restore, rewarded/interstitial ads, Remove Ads, themes and lifecycle handling.
7. Submit only after `docs/RELEASE_CHECKLIST.md` is fully satisfied.
