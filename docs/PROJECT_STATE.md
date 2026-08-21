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

App Store marketing version remains **1.0**.

Current replacement production build is **NavoTap 1.0 (6)**.

Production build **1.0 (5)** was technically accepted by Apple but is permanently rejected for release by our own QA because its compiled AppIcon is completely black. Icon audit run `32489661436` proved both Xcode-emitted AppIcon renditions were RGB 0/0/0 and 100% near-black.

The corrected AppIcon was implemented and verified in PR #14. PR CI run `32511271294` passed Core tests, the iOS Simulator build and the real unsigned Release-archive AppIcon gate. The fix was squash-merged as `d78e02e87d592004f3d36797d2eea925116899c6`.

Corrected icon evidence:

- source `AppIcon.png`: 1024x1024, RGB/no alpha, average luma 0.1433, `NEAR_BLACK=0.00%`, `COLORFUL=99.38%`;
- compiled `AppIcon60x60@2x.png`: 120x120, average luma 0.1419, `NEAR_BLACK=0.00%`, `COLORFUL=99.38%`;
- compiled `AppIcon76x76@2x~ipad.png`: 152x152, average luma 0.1423, `NEAR_BLACK=0.00%`, `COLORFUL=99.38%`.

A permanent source + compiled-archive visual AppIcon gate now prevents black/degenerate icons from reaching production again.

## Production build 6 Apple handoff — SUCCESS / PROCESSING

Protected OneMoreFloor bridge run **`32511649803`** used locked source `d78e02e87d592004f3d36797d2eea925116899c6` and verified before upload:

- bundle `com.kamilunavo.onemoretap`, version `1.0`, build `6`;
- corrected source and compiled Release AppIcons pass visual integrity gates;
- production Rewarded + Interstitial AdMob IDs are present;
- Google sample/test ad IDs are absent;
- Google framework ad-hoc signatures were stripped before Apple cloud signing.

Apple explicitly returned:

- `Uploaded package is processing.`
- `Upload succeeded.`
- `Uploaded NavoTap`
- `EXPORT SUCCEEDED`

Therefore **NavoTap 1.0 (6) is successfully delivered to App Store Connect and currently processing**. Do not claim `VALID` until processing is independently confirmed.

Temporary OneMoreFloor PR #126 was closed without merge after success. Apple also emitted non-blocking missing vendor dSYM warnings for GoogleMobileAds.framework and UserMessagingPlatform.framework; these did not block package acceptance.

## Product / physical QA — GREEN SO FAR

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
- Build 5 production bridge run `32488145687`: Apple upload success; later rejected by visual icon QA.
- Icon audit run `32489661436`: FAIL by design because build 5 compiled icons were fully black.
- Corrected AppIcon PR #14 CI run `32511271294`: Core + iOS Simulator + Release archive icon gate success.
- Build 6 production bridge run `32511649803`: production archive/icon/ad guards passed and Apple upload succeeded.

## App Store Connect — current authoritative state

Confirmed before the build 6 upload:

- all five Non-Consumable IAP records exist;
- all five have DE/EN localization, availability, price schedules and NavoTap review notes;
- all five have one App Review Screenshot and are `READY_TO_SUBMIT`;
- a draft Review Submission exists with exactly five IAP items, all `READY_FOR_REVIEW`;
- iOS App Store version **1.0** exists in `PREPARE_FOR_SUBMISSION`;
- version 1.0 was linked to rejected-for-release build 5.

Current build state:

- build 5 must not be submitted;
- corrected build **1.0 (6)** has been accepted by Apple and is processing;
- after build 6 becomes `VALID`/selectable, version 1.0 must be relinked from build 5 to build 6.

Attempting to add App Store version 1.0 to the existing review draft previously exposed remaining app-version metadata blockers:

- build export-compliance value `usesNonExemptEncryption`;
- App Store Review detail;
- copyright;
- primary category;
- content-rights declaration;
- app pricing;
- localized description, keywords and support URL;
- required age-rating declaration fields.

Do not submit the review draft yet.

## Remaining release gates — ORDERED

1. Confirm Apple processing for **1.0 (6)** completes and the build is `VALID`/selectable.
2. Relink App Store version 1.0 from rejected build 5 to corrected build 6.
3. Complete remaining App Store version metadata blockers.
4. Verify Rewarded unavailable/retry path on physical device.
5. Fresh-install UMP consent + Privacy Options physical QA.
6. Complete Classic lifecycle QA: difficulty/reversals, pause, background/foreground and rapid retry.
7. Final physical smoke test of production build 1.0 (6) without intentionally clicking live ads.
8. Verify `https://kamilunavo.com/navotap/privacy` and `https://kamilunavo.com/app-ads.txt` live/crawlable.
9. Add App Store version 1.0 to the existing review draft containing the five IAPs.
10. Verify version 1.0 + all five IAPs are in the draft and submit only when every release gate is green.
