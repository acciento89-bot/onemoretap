# NavoTap — Project State

Last updated: 2026-08-21

## Identity

**Customer-facing product name: NavoTap — LOCKED.**

The former working name `One More Tap` is retired because an existing App Store game already uses that name and closely overlaps the mechanic. Do not reuse it in store metadata or branding.

Technical identifiers created before the rename remain intentionally stable:

- Bundle ID: `com.kamilunavo.onemoretap`
- Most StoreKit product IDs remain under `com.kamilunavo.onemoretap.*`
- **Fire is a locked legacy exception:** the App Store Connect product was created as `om.kamilunavo.onemoretap.theme.fire` (missing the leading `c`). The app must use that exact live ID.
- Source directory / core-package legacy paths may still contain `OneMoreTap`.

These are implementation identifiers, not customer-facing branding, and must not be renamed casually after store setup.

## Current milestone

**Classic mode: COMPLETE and locked.**

**Monetization/release code: COMPLETE and merged to `main`.**

**Physical-device QA: IN PROGRESS on TestFlight.**

Build `0.2.0 (2)` reached TestFlight and passed the initial physical-iPhone smoke test: Home, Classic gameplay, score/combo HUD and Shop rendered and ran. Physical QA then found two release bugs:

1. Fire remained on `LOADING` while the other StoreKit products resolved.
2. Rewarded Continue could remain on `CONTINUE LOADING` indefinitely.

Both were addressed in PR #5 and squash-merged as `8c5efba595099bf8ffbc14c58b3a63cdc0220b2b` after Core tests and Xcode 26.2 simulator build passed in Actions run `32456370914`.

A safe QA TestFlight build `0.2.0 (3)` was uploaded through the protected OneMoreFloor bridge in Actions run `32456558404`. Apple confirmed `Upload succeeded`, `Uploaded NavoTap` and `EXPORT SUCCEEDED`; App Store Connect/TestFlight processing/availability on the user side remains the next gate. Build 3 is compiled with `NAVOTAP_TEST_ADS`, so Rewarded/Interstitial QA uses Google's official sample ad units rather than the production units. Normal release builds still default to the production AdMob IDs.

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

## StoreKit live IDs

- Remove Ads: `com.kamilunavo.onemoretap.removeads`
- Fire: `om.kamilunavo.onemoretap.theme.fire` — **intentional live legacy typo; do not “correct” it**
- Galaxy: `com.kamilunavo.onemoretap.theme.galaxy`
- Retro: `com.kamilunavo.onemoretap.theme.retro`
- All Themes: `com.kamilunavo.onemoretap.theme.all`

App Store Connect API diagnosis on 2026-08-21 confirmed the Fire mismatch as the reason StoreKit omitted only Fire. The same diagnosis reported all five IAP records in `MISSING_METADATA`; this is a release blocker to clear before App Review.

## Rewarded-ad robustness

`AdService` now exposes explicit Rewarded states:

- `loading`
- `ready`
- `unavailable`

A failed/no-fill/consent-blocked request no longer leaves the UI in permanent loading. The UI can show `AD UNAVAILABLE · RETRY`, manual retry is supported, and failed rewarded loads automatically retry after 15 seconds.

`NAVOTAP_TEST_ADS` switches only Rewarded/Interstitial unit IDs to Google's official sample IDs for safe QA. Production is the default compilation path and continues to use:

- AdMob app ID: `ca-app-pub-8944085355624754~4792390111`
- Rewarded: `ca-app-pub-8944085355624754/7162618768`
- Interstitial: `ca-app-pub-8944085355624754/3694930864`

## Validation

- Core regression suite: 9/9.
- NavoTap rebrand Actions run `32409256186`: Core tests + Xcode 26.2 build — success.
- Production AdMob Actions run `32410958142`: Core tests + Xcode 26.2 build — success.
- Physical-QA fix Actions run `32456370914`: Core tests + Xcode 26.2 `Build NavoTap` — success.
- Build 2 TestFlight bridge run `32446107852`: Apple upload succeeded.
- Build 3 QA TestFlight bridge run `32456558404`: archive + Apple upload succeeded with `NAVOTAP_TEST_ADS` enabled.
- GoogleMobileAds 13.8.0 and GoogleUserMessagingPlatform 3.1.0 resolve in the iOS build.

## Account-side release state

- App Store Connect NavoTap record: complete.
- Five Non-Consumable IAPs: created; **all currently report `MISSING_METADATA` via App Store Connect API and must be completed before submission.**
- App Privacy: complete, user confirmed 2026-08-21.
- Production AdMob IDs: complete and merged to `main`.
- AdMob European regulations / UMP message: complete, user confirmed.
- Dedicated NavoTap privacy page and app-ads.txt: code merged to Kamilunavo website.

## Remaining release gates

1. Wait for TestFlight build `0.2.0 (3)` processing, install it on the physical iPhone and re-test Fire.
2. Verify Rewarded Continue with the safe Google test rewarded ad: success, dismissal/failure state, retry and one-use-per-run behavior.
3. Verify test Interstitial cadence on restart #4, #7 and #10.
4. Complete purchase/relaunch/restore QA for Remove Ads, Fire, Galaxy, Retro and All Themes.
5. Fresh-install UMP consent + Privacy Options QA.
6. Complete Classic lifecycle/regression QA on the physical device.
7. Resolve `MISSING_METADATA` for all five App Store Connect IAPs and attach/select them for the first app-version review submission.
8. Verify `/navotap/privacy` and `/app-ads.txt` are live/crawlable.
9. After QA is green, upload a **final production build without `NAVOTAP_TEST_ADS`** (next build number) and submit only after `docs/RELEASE_CHECKLIST.md` is fully satisfied.
