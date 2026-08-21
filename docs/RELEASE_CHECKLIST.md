# NavoTap — Release Checklist

Last updated: 2026-08-21

## Identity — LOCKED

- [x] Customer-facing app name: `NavoTap`.
- [x] iOS display name, target/product and scheme: `NavoTap`.
- [x] Legacy working name `One More Tap` retired from customer-facing branding.
- [x] Existing technical bundle/product IDs intentionally retained.

## Code and CI — DONE

- [x] Classic gameplay locked and regression-tested.
- [x] Rewarded Continue limited to one use per run at UI/controller and core-engine layers.
- [x] Continue preserves score/coins, resets combo and cannot double-commit a run.
- [x] Full-screen ad return cannot reset the same run's Continue allowance.
- [x] Interstitial cadence is a shared/tested rule: #4, #7, #10, #13, ...
- [x] Remove Ads disables automatic Interstitials only.
- [x] StoreKit 2 purchase, current-entitlement, transaction-update and restore paths implemented.
- [x] UMP consent resolves before intentional ad requests.
- [x] Privacy Options entry point implemented.
- [x] No ATT prompt requested by the app itself.
- [x] `NAVOTAP_TEST_ADS` available for safe TestFlight ad QA; production IDs remain default.
- [x] Core regression suite: **11/11**.
- [x] Interstitial cadence regression + Xcode build passed Actions run `32472174341`; PR #10 merged as `eeae711ada83611658406da71e5866eeaea8b8d2`.

## StoreKit live IDs — LOCKED

- Remove Ads: `com.kamilunavo.onemoretap.removeads`
- Fire: `om.kamilunavo.onemoretap.theme.fire` — **live legacy typo; do not change**
- Galaxy: `com.kamilunavo.onemoretap.theme.galaxy`
- Retro: `com.kamilunavo.onemoretap.theme.retro`
- All Themes: `com.kamilunavo.onemoretap.theme.all`

## App Store Connect

- [x] NavoTap exists for bundle ID `com.kamilunavo.onemoretap`.
- [x] All five Non-Consumable IAP records exist.
- [x] App Privacy completed; user confirmed 2026-08-21.
- [ ] **Resolve `MISSING_METADATA` on all five IAPs.** App Store Connect API confirmed this state on 2026-08-21.
- [ ] Add/select the completed first Non-Consumable IAPs in the first app-version review submission.

## AdMob / Consent

- [x] Production AdMob app ID configured.
- [x] Production Rewarded and Interstitial units configured.
- [x] AdMob European regulations / UMP message created and published.
- [x] Safe QA ads use Google's official sample units only when `NAVOTAP_TEST_ADS` is compiled.
- [x] Physical-device QA confirms Rewarded and Interstitial test ads load/display.
- [x] Physical-device QA confirms Interstitial cadence exactly #4/#7/#10.
- [x] Remove Ads suppresses automatic Interstitials while Rewarded Continue remains available/functioning.
- [ ] Verify Rewarded dismissal/failure/no-fill visibly recovers to Retry rather than permanent Loading.
- [ ] Fresh-install consent flow + Privacy Options physical-device QA.
- [ ] Verify live privacy-policy URL and `app-ads.txt`.
- [ ] Verify AdMob app/app-ads.txt status after the App Store listing is live/crawlable.

## TestFlight / physical iPhone QA

- [x] Build `0.2.0 (2)` uploaded and initial smoke-tested.
- [x] Fire loading and Rewarded permanent-loading issues found and fixed.
- [x] Build `0.2.0 (3)` verified Fire price and Google QA ads.
- [x] Second-Continue regression found and fixed.
- [x] Build `0.2.0 (4)` uploaded from the fixed source with `NAVOTAP_TEST_ADS`.
- [x] Continue-once regression PASS: first rewarded Continue works; second loss in same run offers no second Continue.
- [x] Genuine new run restores exactly one Continue allowance.
- [x] Interstitial cadence PASS: #1–3 none, #4 ad, #5–6 none, #7 ad, #8–9 none, #10 ad.
- [x] Fire purchase/unlock/select/render/relaunch persistence PASS.
- [x] Remove Ads purchase/relaunch persistence PASS.
- [x] Remove Ads suppression PASS while optional Rewarded Continue remains functional.
- [x] Galaxy purchase/unlock/select/persistence PASS.
- [x] Retro purchase/unlock/select/persistence PASS.
- [x] All Themes purchase/unlock/persistence PASS.
- [x] Restore Purchases physical-device QA PASS; entitlements restore correctly.
- [ ] Classic lifecycle/regression QA: difficulty/reversals, pause, background/foreground and rapid retry.

## Web / privacy

- [x] Dedicated NavoTap privacy policy prepared at `https://kamilunavo.com/navotap/privacy`.
- [x] Root `app-ads.txt` prepared at `https://kamilunavo.com/app-ads.txt`.
- [ ] Verify both URLs are live/crawlable in production.

## Final production release

- [ ] Clear all five IAP `MISSING_METADATA` states.
- [ ] Attach/select first IAPs for the app-version submission.
- [ ] Finish remaining Rewarded/UMP/lifecycle physical QA.
- [ ] Upload a new **production build without `NAVOTAP_TEST_ADS`** using the next unused build number.
- [ ] Confirm no Google sample runtime IDs are active in that final build.
- [ ] Submit to App Review only when every release gate above is green.
