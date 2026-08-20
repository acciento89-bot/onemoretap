# NavoTap — Release Checklist

Last updated: 2026-08-20

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
- [x] Rewarded continue limited to one use per run.
- [x] Continue preserves score/coins, resets combo, and cannot double-commit a run.
- [x] Conservative interstitial cadence: restart #4, then every third restart when loaded.
- [x] Remove Ads disables automatic interstitials only.
- [x] StoreKit 2 purchase, entitlement, transaction-update and restore paths implemented.
- [x] Fire, Galaxy, Retro and All Themes are cosmetic only.
- [x] UMP consent resolved before intentional ad requests.
- [x] Privacy-options entry point exposed when UMP requires it.
- [x] Current Google SKAdNetwork identifiers synced on 2026-08-20.
- [x] No ATT prompt requested by the app itself.
- [x] Core test baseline: 9/9.
- [x] NavoTap rebrand Core tests passed in GitHub Actions.
- [x] NavoTap rebrand Xcode 26.2 iOS Simulator build passed in GitHub Actions.
- [x] App Store privacy setup matrix documented in `docs/APP_STORE_PRIVACY_SETUP.md`.
- [x] Guarded TestFlight workflow added at `.github/workflows/testflight.yml` for NavoTap 0.2.0 (2).
- [x] Release signing config added at `Config/Signing.xcconfig` using the same Apple team as the proven KeepMeter upload workflow.

## Production product identifiers — LOCKED TECHNICAL IDs

- `com.kamilunavo.onemoretap.removeads`
- `com.kamilunavo.onemoretap.theme.fire`
- `com.kamilunavo.onemoretap.theme.galaxy`
- `com.kamilunavo.onemoretap.theme.retro`
- `com.kamilunavo.onemoretap.theme.all`

## App Store Connect

- [x] **NavoTap** exists for bundle ID `com.kamilunavo.onemoretap`.
- [x] All five Non-Consumable IAPs are configured in App Store Connect. User confirmed complete on 2026-08-20.
- [x] App Privacy completed in App Store Connect. User confirmed on 2026-08-20.
- [ ] Add the first Non-Consumable IAPs to the first app-version review submission when the release version/build is selected.

## AdMob

- [x] Production iOS app created; app ID: `ca-app-pub-8944085355624754~4792390111`.
- [x] Production Rewarded Continue unit created: `ca-app-pub-8944085355624754/7162618768`.
- [x] Production Interstitial Restart unit created: `ca-app-pub-8944085355624754/3694930864`.
- [x] Production IDs inserted into `main` and validated in Actions run `32410958142`.
- [x] Dedicated privacy policy prepared at `https://kamilunavo.com/navotap/privacy`.
- [x] `app-ads.txt` prepared for `https://kamilunavo.com/app-ads.txt` with publisher ID `pub-8944085355624754`.
- [x] AdMob European regulations / UMP message created and published. User confirmed on 2026-08-20.
- [ ] Verify the live privacy-policy URL and app-ads.txt after the Kamilunavo website deploy.
- [ ] Verify Privacy Options flow on a physical device.
- [ ] Verify AdMob app/app-ads.txt status after the App Store listing is live and crawlable.

## Device / TestFlight — REQUIRED

- [x] Guarded GitHub TestFlight upload workflow prepared for NavoTap 0.2.0 (2).
- [ ] Confirm repository secrets `ASC_ISSUER_ID`, `ASC_KEY_ID`, and `ASC_PRIVATE_KEY_B64` exist for the NavoTap repository.
- [ ] Run the workflow manually from `main` with confirmation phrase `UPLOAD_NAVOTAP_0_2_0_BUILD_2`.
- [ ] Confirm archive/sign/upload succeeds and build appears in App Store Connect/TestFlight.
- [ ] Fresh-install consent flow on a physical iPhone.
- [ ] Classic good/perfect/miss, difficulty, pause, background/foreground and rapid retry.
- [ ] Rewarded Continue success, dismissal, failure/no-fill and second-use prevention.
- [ ] Interstitial cadence #4, #7, #10 when available.
- [ ] Remove Ads purchase/relaunch persistence.
- [ ] Theme purchases, All Themes and selection persistence.
- [ ] Restore Purchases after reinstall/test-account reset.
- [ ] Confirm no Google sample runtime IDs remain in the release configuration.

## Release blocker rule

Do not submit NavoTap to App Review before the first IAPs are attached to the app-version submission, the dedicated privacy URL is live, production ad IDs have passed device validation, and physical-device purchase/restore/rewarded-ad testing has passed.
