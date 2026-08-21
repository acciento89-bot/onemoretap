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

## Current release identity / BLOCKER

App Store marketing version remains **1.0**.

Production build **1.0 (5)** was uploaded successfully and processed by Apple as `VALID`, but is now **rejected for release by our own QA** because the compiled AppIcon is completely black.

OneMoreFloor release-blocker audit run `32489661436` rebuilt the exact source used for build 5 and inspected the real Release archive. Xcode emitted `AppIcon60x60@2x.png` and `AppIcon76x76@2x~ipad.png`; both measured RGB 0/0/0, average luminance 0, 100% near-black and one quantized color. This proves the black icon is in the binary, not merely an App Store Connect display issue.

The source build number has been bumped to **NavoTap 1.0 (6)** for the replacement. Build 5 must never be submitted for review.

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
- Build 5 production bridge run `32488145687`: Apple upload success, production ads present, Google test IDs absent; build later rejected by visual icon QA.
- Icon audit run `32489661436`: **FAIL by design** because both compiled AppIcon renditions are fully black.

## App Store Connect — current authoritative state

Protected App Store Connect diagnostics through OneMoreFloor confirmed:

- all five Non-Consumable IAP records exist,
- all five have DE/EN localization, availability, price schedules and NavoTap review notes,
- all five have one App Review Screenshot and are `READY_TO_SUBMIT`,
- a draft Review Submission exists with exactly five IAP items, all `READY_FOR_REVIEW`,
- iOS App Store version **1.0** exists in `PREPARE_FOR_SUBMISSION`,
- production build 5 is `VALID`,
- version 1.0 is currently linked to exact build 5 through the ASC build relationship; this must be replaced by build 6 after the icon fix.

Attempting to add App Store version 1.0 to the existing review draft exposed remaining app-version metadata blockers from Apple:

- build export-compliance value `usesNonExemptEncryption`,
- App Store Review detail,
- copyright,
- primary category,
- content-rights declaration,
- app pricing,
- localized description, keywords and support URL,
- required age-rating declaration fields.

Do not submit the review draft yet.

## Remaining release gates — ORDERED

1. Replace broken AppIcon with corrected NavoTap artwork.
2. Keep replacement source identity at **1.0 (6)**.
3. Add permanent source + compiled-archive AppIcon visual-integrity gate to CI/TestFlight flow.
4. Core tests + Xcode CI green.
5. Build an unsigned Release archive and prove compiled AppIcon is visually non-black before any Apple upload.
6. Upload production **NavoTap 1.0 (6)** without `NAVOTAP_TEST_ADS` through the protected OneMoreFloor bridge; verify production ad IDs/no sample IDs and icon gate again before upload.
7. Confirm Apple build 6 is `VALID`; relink App Store version 1.0 from build 5 to build 6.
8. Complete remaining App Store version metadata blockers.
9. Verify Rewarded unavailable/retry path, fresh-install UMP + Privacy Options and remaining Classic lifecycle QA.
10. Verify `https://kamilunavo.com/navotap/privacy` and `https://kamilunavo.com/app-ads.txt` live/crawlable.
11. Add version 1.0 to existing review draft with the five IAPs and submit only when every gate is green.
