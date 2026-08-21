# NavoTap — Release Checklist

Last updated: 2026-08-21

## Identity — LOCKED

- [x] Customer-facing app name: `NavoTap`.
- [x] iOS display name, target/product and scheme: `NavoTap`.
- [x] Legacy working name `One More Tap` retired from customer-facing branding.
- [x] Existing technical bundle/product IDs intentionally retained.
- [x] App Store release identity aligned to **1.0 (5)**; PR #12 merged as `0fa531cfa6f7229017846bfefd640c2da0fea50f` after Actions run `32486728556` passed.

## Code and CI — DONE

- [x] Classic gameplay locked and regression-tested.
- [x] Rewarded Continue limited to one use per run at UI/controller and core-engine layers.
- [x] Continue preserves score/coins, resets combo and cannot double-commit a run.
- [x] Full-screen ad return cannot reset the same run's Continue allowance.
- [x] Interstitial cadence shared/tested: #4, #7, #10, #13, ...
- [x] Remove Ads disables automatic Interstitials only.
- [x] StoreKit 2 purchase, current-entitlement, transaction-update and restore paths implemented.
- [x] UMP consent resolves before intentional ad requests; Privacy Options entry point implemented.
- [x] No ATT prompt requested by the app itself.
- [x] `NAVOTAP_TEST_ADS` available for safe QA only; production IDs remain default.
- [x] Production Release guard rejects `NAVOTAP_TEST_ADS` and scans the final app bundle for Google sample/test ad IDs.
- [x] Core regression suite: **11/11**.

## StoreKit live IDs — LOCKED

- Remove Ads: `com.kamilunavo.onemoretap.removeads`
- Fire: `om.kamilunavo.onemoretap.theme.fire` — **live legacy typo; do not change**
- Galaxy: `com.kamilunavo.onemoretap.theme.galaxy`
- Retro: `com.kamilunavo.onemoretap.theme.retro`
- All Themes: `com.kamilunavo.onemoretap.theme.all`

## App Store Connect

- [x] NavoTap exists for bundle ID `com.kamilunavo.onemoretap`.
- [x] App Store version **1.0** exists and is `PREPARE_FOR_SUBMISSION`.
- [x] No build currently assigned to App Store version 1.0.
- [x] No Review Submission currently exists.
- [x] All five Non-Consumable IAP records exist.
- [x] App Privacy completed.
- [x] All five IAPs have DE/EN localizations, availability, price schedules and NavoTap review notes.
- [x] One App Review Screenshot uploaded to each of the five IAPs.
- [x] Protected ASC verification run `32485927561`: all five IAPs are **READY_TO_SUBMIT**, each has one review screenshot, `MISSING_METADATA=0`.
- [ ] **First-IAP UI step:** select all five IAPs → `Add for Review` → create new submission → choose iOS version **1.0**. Keep draft; do not submit the review yet.
- [ ] Verify draft Review Submission contains version 1.0 and all five IAPs.

## AdMob / Consent

- [x] Production AdMob app ID configured.
- [x] Production Rewarded and Interstitial units configured.
- [x] UMP European regulations message created and published.
- [x] Safe QA ads use Google's official sample units only with `NAVOTAP_TEST_ADS`.
- [x] Physical QA confirms Rewarded/Interstitial test ads load/display.
- [x] Interstitial cadence physical PASS at #4/#7/#10.
- [x] Remove Ads suppresses automatic Interstitials while Rewarded Continue remains available/functioning.
- [ ] Verify Rewarded dismissal/failure/no-fill visibly recovers to Retry rather than permanent Loading.
- [ ] Fresh-install UMP consent flow + Privacy Options physical QA.
- [ ] Verify live privacy-policy URL and `app-ads.txt`.
- [ ] Verify AdMob app/app-ads.txt status after App Store listing is live/crawlable.

## TestFlight / physical iPhone QA

- [x] `0.2.0 (2)` initial smoke QA.
- [x] `0.2.0 (3)` Fire/Rewarded fixes verified with safe test ads.
- [x] `0.2.0 (4)` Continue-once fix verified with safe test ads.
- [x] Continue-once PASS; genuine new run restores one Continue.
- [x] Interstitial cadence PASS #4/#7/#10.
- [x] Fire purchase/unlock/select/render/relaunch persistence PASS.
- [x] Remove Ads purchase/relaunch + suppression PASS; Rewarded remains functional.
- [x] Galaxy/Retro/All Themes purchase and persistence PASS.
- [x] Restore Purchases PASS.
- [ ] Classic lifecycle/regression QA: difficulty/reversals, pause, background/foreground and rapid retry.

## Web / privacy

- [x] Dedicated NavoTap privacy policy prepared at `https://kamilunavo.com/navotap/privacy`.
- [x] Root `app-ads.txt` prepared at `https://kamilunavo.com/app-ads.txt`.
- [ ] Verify both URLs are live/crawlable in production.

## Final production release

- [x] Binary source identity prepared as **NavoTap 1.0 (5)**.
- [x] Release guard verifies production identity and rejects test-ad configuration.
- [ ] Finish first-IAP draft submission association in App Store Connect UI.
- [ ] Finish Rewarded/UMP/lifecycle physical QA.
- [ ] Upload **production NavoTap 1.0 (5)** without `NAVOTAP_TEST_ADS` through protected OneMoreFloor bridge.
- [ ] Confirm Apple accepts the production upload and no Google sample runtime IDs are active.
- [ ] Assign processed build 1.0 (5) to App Store version 1.0.
- [ ] Submit to App Review only when every gate above is green.
