# NavoTap — Project State

Last updated: 2026-08-21

## Identity — LOCKED

**Customer-facing product name: NavoTap.** The former working name `One More Tap` is retired.

Technical identifiers intentionally remain stable:

- Bundle ID: `com.kamilunavo.onemoretap`
- Remove Ads: `com.kamilunavo.onemoretap.removeads`
- Fire: `om.kamilunavo.onemoretap.theme.fire` — **live legacy typo in App Store Connect; do not correct in code**
- Galaxy: `com.kamilunavo.onemoretap.theme.galaxy`
- Retro: `com.kamilunavo.onemoretap.theme.retro`
- All Themes: `com.kamilunavo.onemoretap.theme.all`
- Legacy source/project paths may still contain `OneMoreTap`.

## Current release identity

**App Store version: `1.0`.**

**Current source build identity on `main`: `1.0 (5)`.**

PR #12 aligned the binary with the real App Store Connect draft version and was squash-merged as `0fa531cfa6f7229017846bfefd640c2da0fea50f` after Actions run `32486728556` passed Core tests and the Xcode 26.2 iOS build.

The previous `0.2.0 (2)`, `(3)` and `(4)` builds are TestFlight QA history only and are not the App Store release version.

The production upload guard now verifies `1.0 (5)`, rejects `NAVOTAP_TEST_ADS` in Release build settings, and scans the final archived app bundle for Google's sample/test ad-ID prefix before upload.

## Product / physical QA — GREEN

Confirmed on a physical iPhone on 2026-08-21:

- Home, Classic, score/combo HUD and Shop render and run correctly.
- Fire resolves to its live price and no longer remains on `LOADING`.
- Google QA Rewarded and Interstitial ads load/display correctly.
- Rewarded Continue works and may be used **only once per run**.
- A genuine new run restores exactly one Continue allowance.
- Automatic Interstitial cadence is correct: #1–3 none, #4 ad, #5–6 none, #7 ad, #8–9 none, #10 ad.
- Fire purchase/unlock/select/render/relaunch persistence PASS.
- Remove Ads purchase/relaunch persistence PASS.
- Remove Ads suppresses automatic Interstitials while optional Rewarded Continue remains available/functioning.
- Galaxy and Retro purchase/unlock/select/persistence PASS.
- All Themes purchase/unlock/persistence PASS.
- Restore Purchases PASS.

## Classic / monetization rules — LOCKED

- Portrait iPhone-first, one-finger gameplay.
- One miss ends the run unless the single optional rewarded Continue is used.
- Continue preserves score/coins, resets combo and cannot double-commit a run.
- Difficulty increases continuously; Perfect hits are rewarded but not required.
- One automatic Interstitial on restart #4 and then every third restart (#7, #10, #13, ...), when loaded.
- Remove Ads disables automatic Interstitials only.
- No pay-to-win purchases; themes are cosmetic only.

## Rewarded robustness

`AdService` exposes `loading`, `ready`, and `unavailable`. Failed/no-fill/consent-blocked loading can show `AD UNAVAILABLE · RETRY`, supports manual retry and automatically retries after 15 seconds.

`NAVOTAP_TEST_ADS` switches only Rewarded/Interstitial IDs to Google's official sample units for safe QA. Production defaults remain:

- AdMob app ID: `ca-app-pub-8944085355624754~4792390111`
- Rewarded: `ca-app-pub-8944085355624754/7162618768`
- Interstitial: `ca-app-pub-8944085355624754/3694930864`

## Validation / CI

- Core regression suite: **11/11**.
- Interstitial cadence regression run `32472174341`: Core + Xcode success; PR #10 merged as `eeae711ada83611658406da71e5866eeaea8b8d2`.
- Build 2 TestFlight bridge run `32446107852`: Apple upload success.
- Build 3 QA bridge run `32456558404`: Apple upload success with `NAVOTAP_TEST_ADS`.
- Build 4 QA bridge run `32464932344`: Apple upload success with `NAVOTAP_TEST_ADS`.
- Release identity PR #12 run `32486728556`: Core + Xcode 26.2 success; merged as `0fa531cfa6f7229017846bfefd640c2da0fea50f`.

## App Store Connect — current authoritative state

Protected App Store Connect diagnostics through OneMoreFloor confirmed:

- all five Non-Consumable IAP records exist,
- all five have DE/EN localization, availability, price schedules and review notes,
- all five review notes now use the product name `NavoTap`,
- user uploaded one App Review Screenshot to each IAP,
- run `32485927561` confirmed all five IAPs have `REVIEW_SCREENSHOTS=1`, all are **`READY_TO_SUBMIT`**, and `MISSING_METADATA` count is **0**,
- iOS App Store version **1.0** exists in `PREPARE_FOR_SUBMISSION`,
- no build is assigned to version 1.0 yet,
- no Review Submission exists yet.

Because these are NavoTap's **first** Non-Consumable IAPs, Apple requires the first IAP submission to be created together with the app-version submission in App Store Connect. The first-submission association is a UI step, not the review-submission API flow.

## Remaining release gates

1. In App Store Connect, select all five `READY_TO_SUBMIT` IAPs → **Add for Review** → create a new submission for iOS version **1.0**. Keep the submission as a draft until final production QA is green.
2. Verify the draft contains version 1.0 and all five IAPs.
3. Verify Rewarded unavailable/dismiss/failure path visibly recovers to Retry rather than permanent Loading.
4. Fresh-install UMP consent + Privacy Options physical-device QA.
5. Complete remaining Classic lifecycle QA: difficulty/reversals, pause, background/foreground and rapid retry.
6. Verify `https://kamilunavo.com/navotap/privacy` and `https://kamilunavo.com/app-ads.txt` are live/crawlable.
7. Upload final production **NavoTap 1.0 (5)** without `NAVOTAP_TEST_ADS` through the protected OneMoreFloor TestFlight bridge.
8. Assign the processed production build to App Store version 1.0 and submit only after every release gate is green.
