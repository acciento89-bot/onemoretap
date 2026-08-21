# NavoTap — Release Checklist

Last updated: 2026-08-21

This file is the release handoff for NavoTap. Code-side items are tracked separately from account-side items requiring App Store Connect, AdMob, signing credentials, or a physical device.

## Identity — LOCKED

- [x] Customer-facing app name: `NavoTap`.
- [x] Home branding changed to `NAVOTAP`.
- [x] iOS display name changed to `NavoTap`.
- [x] Xcode target/product and shared scheme changed to `NavoTap`.
- [x] Local StoreKit test configuration renamed to `NavoTap.storekit`.
- [x] Legacy working name `One More Tap` retired from customer-facing branding.
- [x] Existing technical bundle/product IDs intentionally retained for continuity.

## Code and CI — DONE

- [x] Classic gameplay locked and covered by regression tests.
- [x] Rewarded continue limited to one use per run at both controller/UI and core-engine layers.
- [x] Continue preserves score/coins, resets combo, and cannot double-commit a run.
- [x] Returning from a full-screen rewarded ad can no longer reset the same run's Continue allowance.
- [x] Core regression test proves first revive succeeds, second revive in same run fails, and a real reset enables one revive for the next run.
- [x] Conservative interstitial cadence: restart #4, then every third restart when loaded.
- [x] Remove Ads disables automatic interstitials only.
- [x] StoreKit 2 purchase, entitlement, transaction-update and restore paths implemented.
- [x] Fire, Galaxy, Retro and All Themes are cosmetic only.
- [x] UMP consent resolved before intentional ad requests.
- [x] Privacy-options entry point exposed when UMP requires it.
- [x] Current Google SKAdNetwork identifiers synced on 2026-08-20.
- [x] No ATT prompt requested by the app itself.
- [x] Core regression suite: **10/10**.
- [x] Production AdMob IDs validated in Actions run `32410958142`.
- [x] Physical-iPhone Fire IAP mismatch diagnosed through App Store Connect API.
- [x] Fire runtime ID aligned to the existing live App Store Connect ID.
- [x] Rewarded Continue no longer has an unrecoverable permanent-loading state; loading/ready/unavailable + retry implemented.
- [x] Fire/Rewarded-loading fixes passed Core tests + Xcode 26.2 build in Actions run `32456370914` and merged as `8c5efba595099bf8ffbc14c58b3a63cdc0220b2b`.
- [x] Continue-once fix PR #7 passed Core tests + Xcode 26.2 build in Actions run `32464711226` and was squash-merged as `b355122a4b6fa935e494939e00615eb782cfd827`.
- [x] `NAVOTAP_TEST_ADS` compile flag available for safe TestFlight ad QA while production remains the default path.

## Production product identifiers — LOCKED TECHNICAL IDs

- Remove Ads: `com.kamilunavo.onemoretap.removeads`
- Fire: `om.kamilunavo.onemoretap.theme.fire` — **live legacy ID created without the leading `c`; do not change**
- Galaxy: `com.kamilunavo.onemoretap.theme.galaxy`
- Retro: `com.kamilunavo.onemoretap.theme.retro`
- All Themes: `com.kamilunavo.onemoretap.theme.all`

## App Store Connect

- [x] **NavoTap** exists for bundle ID `com.kamilunavo.onemoretap`.
- [x] All five Non-Consumable IAP records exist in App Store Connect.
- [x] App Privacy completed in App Store Connect. User confirmed on 2026-08-21.
- [ ] **Resolve `MISSING_METADATA` on all five IAPs.** App Store Connect API confirmed this state on 2026-08-21.
- [ ] Add/select the completed first Non-Consumable IAPs in the first app-version review submission.

## AdMob

- [x] Production iOS app created; app ID: `ca-app-pub-8944085355624754~4792390111`.
- [x] Production Rewarded Continue unit created: `ca-app-pub-8944085355624754/7162618768`.
- [x] Production Interstitial Restart unit created: `ca-app-pub-8944085355624754/3694930864`.
- [x] Production IDs inserted into `main` and validated in Actions run `32410958142`.
- [x] Dedicated privacy policy prepared at `https://kamilunavo.com/navotap/privacy`.
- [x] `app-ads.txt` prepared for `https://kamilunavo.com/app-ads.txt` with publisher ID `pub-8944085355624754`.
- [x] AdMob European regulations / UMP message created and published.
- [x] Safe QA ad path added using Google's official Rewarded/Interstitial sample IDs only when compiled with `NAVOTAP_TEST_ADS`.
- [x] Build 3 physical-device QA confirmed Google test ads load/display correctly and Fire resolves to its live price.
- [ ] Verify the live privacy-policy URL and app-ads.txt after the Kamilunavo website deploy.
- [ ] Verify Privacy Options flow on a physical device.
- [ ] Verify AdMob app/app-ads.txt status after the App Store listing is live and crawlable.

## Device / TestFlight — REQUIRED

- [x] NavoTap `0.2.0 (2)` uploaded through the protected OneMoreFloor bridge; run `32446107852`.
- [x] Build 2 processed, installed and launched on a physical iPhone.
- [x] Initial physical smoke test passed: Home, Classic, score/combo HUD and Shop render/run.
- [x] Physical QA found Fire stuck on `LOADING`; root cause was exact App Store Connect product-ID mismatch.
- [x] Physical QA found Rewarded Continue could stay on `CONTINUE LOADING`; recoverable state/retry behavior added.
- [x] QA TestFlight build `0.2.0 (3)` uploaded through OneMoreFloor run `32456558404`.
- [x] Build 3 processed/installed; Fire resolves to `$1.99` and Google QA ads function on the physical iPhone.
- [x] Build 3 physical QA found a second rewarded Continue could be offered after losing again in the same revived run.
- [x] Root cause fixed: app reappearance no longer starts/resets an existing run, and the core engine now rejects a second revive in the same run.
- [x] QA TestFlight build `0.2.0 (4)` uploaded from exact merged source `b355122a4b6fa935e494939e00615eb782cfd827` through OneMoreFloor run `32464932344` with `NAVOTAP_TEST_ADS`.
- [x] Apple confirmed Build 4: `Uploaded package is processing.` / `Upload succeeded.` / `Uploaded NavoTap` / `EXPORT SUCCEEDED`.
- [x] Temporary Build 4 OneMoreFloor bridge PR #116 closed without merge. Later duplicate-trigger attempts were rejected only because build number 4 had already been accepted.
- [ ] Wait for Build 4 to finish App Store Connect/TestFlight processing and install/update it.
- [ ] **Continue-once physical regression:** miss → rewarded Continue → miss again → no second Continue button.
- [ ] Start a genuine new run with `ONE MORE TAP` and confirm one Continue is available again in that new run.
- [ ] Rewarded dismissal/failure/no-fill UI must recover to Retry rather than permanent Loading.
- [ ] Test Interstitial cadence #4, #7 and #10.
- [ ] Fresh-install consent flow + Privacy Options on a physical iPhone.
- [ ] Classic good/perfect/miss, difficulty, reversals, pause, background/foreground and rapid retry.
- [ ] Fire purchase/select/relaunch persistence.
- [ ] Remove Ads purchase/relaunch persistence.
- [ ] Galaxy/Retro/All Themes purchase and selection persistence.
- [ ] Restore Purchases after reinstall/test-account reset.
- [ ] After QA is green, upload a new **production build without `NAVOTAP_TEST_ADS`** using the next unused build number and confirm no Google sample runtime IDs are active in that final build.

## Release blocker rule

Do not submit NavoTap to App Review until all five IAPs no longer report `MISSING_METADATA`, the first IAPs are attached/selected for the app-version submission, the dedicated privacy URL is live, and physical-device purchase/restore/consent/rewarded/interstitial testing is green. The final submission build must be a production build without `NAVOTAP_TEST_ADS`.
