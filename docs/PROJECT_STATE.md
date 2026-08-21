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

**Physical-device QA: IN PROGRESS on TestFlight Build `0.2.0 (4)`.**

Build `0.2.0 (2)` reached TestFlight and passed the initial physical-iPhone smoke test. That pass found two release bugs: Fire remained on `LOADING`, and Rewarded Continue could remain on `CONTINUE LOADING`. Both were fixed in PR #5 and validated in Build 3.

Physical QA on Build `0.2.0 (3)` then confirmed:

- Home, Classic gameplay, score/combo HUD and Shop render/run correctly.
- Fire now resolves correctly to `$1.99` rather than remaining on `LOADING`.
- Google QA ads load and display correctly; the permanent `CONTINUE LOADING` symptom no longer reproduces during normal ad use.

A further physical-device regression was then found: after using the rewarded Continue, losing again in the **same run** could offer another Continue. Root cause: returning from the full-screen ad could cause SwiftUI `onAppear` to call the old run-start method again, resetting the controller's `hasUsedContinue` state.

PR #7 fixes this at two layers and was squash-merged to `main` as `b355122a4b6fa935e494939e00615eb782cfd827`:

1. `ClassicGameView` now uses `startIfNeeded()` on appearance and only `ONE MORE TAP` explicitly calls `startNewRun()`.
2. `ClassicGameEngine` itself tracks `hasUsedRevive` and rejects a second revive in the same run, so the one-continue rule no longer depends only on UI/controller state.
3. `ClassicScene.continueRun()` reports whether the core revive actually succeeded, preventing controller/core divergence.
4. Regression coverage now proves: miss → first revive succeeds → second miss → second revive fails → real reset → revive is available again.

The fix passed the Core suite and Xcode 26.2 iOS build in Actions run `32464711226`.

A safe QA TestFlight build `0.2.0 (4)` was then uploaded from the exact merged source commit `b355122a4b6fa935e494939e00615eb782cfd827` through the protected OneMoreFloor bridge in Actions run `32464932344`, compiled with `NAVOTAP_TEST_ADS`. Apple confirmed:

- `Uploaded package is processing.`
- `Upload succeeded.`
- `Uploaded NavoTap`
- `** EXPORT SUCCEEDED **`

Later duplicate bridge triggers failed only because Apple had already accepted build number 4; they do not indicate an app/signing regression. The temporary OneMoreFloor bridge PR #116 was closed without merge.

## Product rules locked for Classic

- Portrait iPhone-first game.
- One-finger input; no swipe/drag controls.
- Run starts and restarts immediately.
- One miss ends the run unless the player uses the **single** rewarded continue.
- A rewarded Continue may be used at most once per run; only an explicit new run resets this allowance.
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

`AdService` exposes explicit Rewarded states:

- `loading`
- `ready`
- `unavailable`

A failed/no-fill/consent-blocked request no longer leaves the UI in permanent loading. The UI can show `AD UNAVAILABLE · RETRY`, manual retry is supported, and failed rewarded loads automatically retry after 15 seconds.

`NAVOTAP_TEST_ADS` switches only Rewarded/Interstitial unit IDs to Google's official sample IDs for safe QA. Production is the default compilation path and continues to use:

- AdMob app ID: `ca-app-pub-8944085355624754~4792390111`
- Rewarded: `ca-app-pub-8944085355624754/7162618768`
- Interstitial: `ca-app-pub-8944085355624754/3694930864`

## Validation

- Core regression suite: **10/10** after the continue-once regression test was added.
- NavoTap rebrand Actions run `32409256186`: Core tests + Xcode 26.2 build — success.
- Production AdMob Actions run `32410958142`: Core tests + Xcode 26.2 build — success.
- Fire/Rewarded-loading fix Actions run `32456370914`: Core tests + Xcode 26.2 `Build NavoTap` — success.
- Continue-once fix Actions run `32464711226`: Core tests + Xcode 26.2 `Build NavoTap` — success.
- Build 2 TestFlight bridge run `32446107852`: Apple upload succeeded.
- Build 3 QA TestFlight bridge run `32456558404`: Apple upload succeeded with `NAVOTAP_TEST_ADS` enabled.
- Build 4 QA TestFlight bridge run `32464932344`: exact merged continue-once source archived and Apple upload succeeded with `NAVOTAP_TEST_ADS` enabled.
- GoogleMobileAds 13.8.0 and GoogleUserMessagingPlatform 3.1.0 resolve in the iOS build.

## Account-side release state

- App Store Connect NavoTap record: complete.
- Five Non-Consumable IAPs: created; **all currently report `MISSING_METADATA` via App Store Connect API and must be completed before submission.**
- App Privacy: complete, user confirmed 2026-08-21.
- Production AdMob IDs: complete and merged to `main`.
- AdMob European regulations / UMP message: complete, user confirmed.
- Dedicated NavoTap privacy page and app-ads.txt: code merged to Kamilunavo website.

## Remaining release gates

1. Wait for TestFlight Build `0.2.0 (4)` processing, install/update it on the physical iPhone and run the exact continue regression: **miss → rewarded Continue → miss again → no second Continue button**.
2. Confirm the next explicit `ONE MORE TAP` new run permits one rewarded Continue again.
3. Verify Rewarded dismissal/failure/no-fill state recovers to Retry rather than permanent Loading.
4. Verify test Interstitial cadence on restart #4, #7 and #10.
5. Complete purchase/relaunch/restore QA for Remove Ads, Fire, Galaxy, Retro and All Themes.
6. Fresh-install UMP consent + Privacy Options QA.
7. Complete Classic lifecycle/regression QA on the physical device.
8. Resolve `MISSING_METADATA` for all five App Store Connect IAPs and attach/select them for the first app-version review submission.
9. Verify `/navotap/privacy` and `/app-ads.txt` are live/crawlable.
10. After QA is green, upload a **final production build without `NAVOTAP_TEST_ADS`** using the next unused build number and submit only after `docs/RELEASE_CHECKLIST.md` is fully satisfied.
