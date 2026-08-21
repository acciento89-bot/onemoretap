# NavoTap — Release Checklist

Last updated: 2026-08-21

## ACTIVE RELEASE BLOCKER

- [x] User reported black AppIcon in App Store Connect/TestFlight production build `1.0 (5)`.
- [x] OneMoreFloor icon audit run `32489661436` reproduced the problem in an unsigned Release archive: compiled `AppIcon60x60@2x.png` and `AppIcon76x76@2x~ipad.png` were 100% near-black / RGB 0,0,0.
- [x] Build `1.0 (5)` is therefore **not releaseable** even though Apple processed it as VALID.
- [ ] Replace the broken source AppIcon with the corrected NavoTap artwork.
- [ ] Verify corrected source icon is 1024x1024 RGB/no alpha and visually non-black.
- [ ] Verify the compiled Release-archive AppIcon renditions are visually non-black.
- [ ] Ship replacement production build **1.0 (6)** only after the icon gate passes.

## Identity — LOCKED

- [x] Customer-facing app name: `NavoTap`.
- [x] iOS display name, target/product and scheme: `NavoTap`.
- [x] Legacy working name `One More Tap` retired from customer-facing branding.
- [x] Existing technical bundle/product IDs intentionally retained.
- [x] App Store marketing version: **1.0**.
- [ ] Replacement release build target after icon fix: **1.0 (6)**.

## Code and CI

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
- [ ] Add permanent AppIcon visual-integrity gate to CI and TestFlight upload flow.

## StoreKit live IDs — LOCKED

- Remove Ads: `com.kamilunavo.onemoretap.removeads`
- Fire: `om.kamilunavo.onemoretap.theme.fire` — **live legacy typo; do not change**
- Galaxy: `com.kamilunavo.onemoretap.theme.galaxy`
- Retro: `com.kamilunavo.onemoretap.theme.retro`
- All Themes: `com.kamilunavo.onemoretap.theme.all`

## App Store Connect

- [x] NavoTap exists for bundle ID `com.kamilunavo.onemoretap`.
- [x] App Store version **1.0** exists in `PREPARE_FOR_SUBMISSION`.
- [x] All five Non-Consumable IAP records exist and are `READY_TO_SUBMIT` with review screenshots.
- [x] App Privacy completed.
- [x] Draft review submission exists with exactly five IAP review items, all `READY_FOR_REVIEW`.
- [x] Production build `1.0 (5)` uploaded and Apple processing state is `VALID`.
- [x] Version 1.0 was linked to exact build 5 via App Store Connect build relationship.
- [ ] After replacement upload, relink version 1.0 from rejected-for-release build 5 to corrected **build 6**.
- [ ] Add App Store version 1.0 itself to the existing review draft only after all version metadata blockers are complete.

### App-version metadata blockers reported by Apple

- [ ] `usesNonExemptEncryption` for final build.
- [ ] App Store Review contact/detail.
- [ ] Copyright.
- [ ] Primary category.
- [ ] Content-rights declaration.
- [ ] App pricing.
- [ ] Description, keywords and support URL.
- [ ] Complete required age-rating declaration fields.

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
- [x] Fire/Galaxy/Retro/All Themes purchase/persistence PASS.
- [x] Remove Ads purchase/persistence + Interstitial suppression PASS; Rewarded remains functional.
- [x] Restore Purchases PASS.
- [ ] Classic lifecycle/regression QA: difficulty/reversals, pause, background/foreground and rapid retry.
- [ ] Final physical smoke test of corrected production build 1.0 (6), without intentionally clicking live ads.

## Web / privacy

- [x] Dedicated NavoTap privacy policy prepared at `https://kamilunavo.com/navotap/privacy`.
- [x] Root `app-ads.txt` prepared at `https://kamilunavo.com/app-ads.txt`.
- [ ] Verify both URLs are live/crawlable in production.

## Final production release

- [x] Build 5 upload technically succeeded but is **rejected for release due black compiled AppIcon**.
- [ ] Correct AppIcon and bump source identity to **NavoTap 1.0 (6)**.
- [ ] CI + Release archive AppIcon gate green.
- [ ] Upload production NavoTap 1.0 (6) without `NAVOTAP_TEST_ADS` through protected OneMoreFloor bridge.
- [ ] Confirm Apple accepts build 6 and no Google sample runtime IDs are active.
- [ ] Assign processed build 6 to App Store version 1.0.
- [ ] Complete remaining version metadata + QA.
- [ ] Submit to App Review only when every gate above is green.
