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

## Current milestone

**Classic mode: COMPLETE and locked.**

**Monetization/release code: COMPLETE and merged to `main`.**

**Physical-device QA: MOST MAJOR GAME/MONETIZATION GATES GREEN on TestFlight Build `0.2.0 (4)`.**

Build 2 exposed Fire StoreKit loading and permanent Rewarded loading issues. PR #5 fixed both. Build 3 confirmed Fire price resolution and Google QA ads, then exposed the second-Continue regression. PR #7 fixed the one-Continue-per-run rule at both UI/controller and core-engine layers. Build 4 verified that fix on a physical iPhone.

## Physical iPhone QA — GREEN

Confirmed on 2026-08-21:

- Home, Classic gameplay, score/combo HUD and Shop render and run correctly.
- Fire resolves to its live price and no longer remains on `LOADING`.
- Google QA Rewarded and Interstitial ads load/display correctly.
- Rewarded Continue works and may be used **only once per run**.
- After the rewarded Continue, a second loss in the same run does **not** offer another Continue.
- A genuine new run via `ONE MORE TAP` restores exactly one Continue allowance.
- Automatic Interstitial cadence is correct on physical iPhone: #1–3 none, #4 ad, #5–6 none, #7 ad, #8–9 none, #10 ad.
- Fire purchase succeeds, theme unlocks/selects, renders in Classic and persists after full relaunch.
- Remove Ads purchase succeeds and persists after relaunch.
- Remove Ads suppresses automatic Interstitials while the optional Rewarded Continue remains available and functional.
- Galaxy and Retro purchases/unlocks/selections work and persist.
- All Themes purchase/unlock behavior works and persists.
- Restore Purchases works and restores StoreKit entitlements.

## Classic product rules — LOCKED

- Portrait iPhone-first game.
- One-finger input; no swipe/drag controls.
- Run starts/restarts immediately.
- One miss ends the run unless the single optional rewarded Continue is used.
- Rewarded Continue can be used at most once per run; only a genuine new run resets the allowance.
- Continue preserves score/coins, resets combo and cannot double-commit a run.
- Difficulty increases continuously.
- Perfect hits are rewarded but not required.
- No pay-to-win purchases.
- Themes are cosmetic only.

## Monetization rules — LOCKED

- One optional rewarded-video Continue per run.
- Automatic Interstitial first appears at restart #4 and then every third restart (#7, #10, #13, ...), when loaded.
- Remove Ads disables automatic Interstitials only; Rewarded Continue remains optional.
- Neon is free; Fire, Galaxy, Retro and All Themes are supported.

## Rewarded robustness

`AdService` has explicit Rewarded states `loading`, `ready`, and `unavailable`. Failed/no-fill/consent-blocked loading no longer has an intentionally permanent loading state; the UI supports `AD UNAVAILABLE · RETRY`, manual retry and a 15-second automatic retry.

`NAVOTAP_TEST_ADS` switches only Rewarded/Interstitial unit IDs to Google's official sample IDs for safe QA. Production remains the default compilation path with:

- AdMob app ID: `ca-app-pub-8944085355624754~4792390111`
- Rewarded: `ca-app-pub-8944085355624754/7162618768`
- Interstitial: `ca-app-pub-8944085355624754/3694930864`

## Validation / CI

- Core regression suite: **11/11** after adding the interstitial cadence regression.
- Production AdMob run `32410958142`: Core + Xcode build success.
- Fire/Rewarded-loading fix run `32456370914`: Core + Xcode build success.
- Continue-once fix run `32464711226`: Core + Xcode build success.
- Interstitial cadence regression run `32472174341`: Core + Xcode build success; PR #10 merged as `eeae711ada83611658406da71e5866eeaea8b8d2`.
- Build 2 TestFlight bridge run `32446107852`: Apple upload success.
- Build 3 QA bridge run `32456558404`: Apple upload success with `NAVOTAP_TEST_ADS`.
- Build 4 QA bridge run `32464932344`: Apple upload success with `NAVOTAP_TEST_ADS`.

## Account-side release state

- App Store Connect NavoTap record: complete.
- Five Non-Consumable IAP records: created.
- **App Store Connect API still reports `MISSING_METADATA` for all five IAP records; resolve before App Review.**
- App Privacy: complete; user confirmed 2026-08-21.
- Production AdMob IDs: complete.
- AdMob European regulations / UMP message: complete and published.
- Dedicated NavoTap privacy page and root `app-ads.txt`: merged to Kamilunavo website.

## Remaining release gates

1. Verify the Rewarded unavailable/dismiss/failure path visibly recovers to Retry rather than permanent Loading.
2. Fresh-install UMP consent + Privacy Options physical-device QA.
3. Complete remaining Classic lifecycle/regression QA: difficulty/reversals, pause, background/foreground and rapid retry.
4. Resolve `MISSING_METADATA` for all five App Store Connect IAPs and attach/select the first IAPs for the first app-version review submission.
5. Verify `https://kamilunavo.com/navotap/privacy` and `https://kamilunavo.com/app-ads.txt` are live/crawlable.
6. Upload the next **final production build without `NAVOTAP_TEST_ADS`** using a new build number.
7. Submit to App Review only when the release checklist is fully green.
