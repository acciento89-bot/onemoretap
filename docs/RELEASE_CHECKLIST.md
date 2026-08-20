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
- [x] Google development sample/test IDs used during development.
- [x] Current Google SKAdNetwork identifiers synced on 2026-08-20.
- [x] No ATT prompt requested by the app itself.
- [x] Core test baseline: 9/9.
- [x] Pre-rebrand Xcode 26.2 iOS Simulator build passed with GoogleMobileAds 13.8.0 and GoogleUserMessagingPlatform 3.1.0.
- [x] NavoTap rebrand Core tests passed in GitHub Actions run `32409256186`.
- [x] NavoTap rebrand Xcode 26.2 iOS Simulator build passed in GitHub Actions run `32409256186`.

## Production product identifiers — LOCKED TECHNICAL IDs

- `com.kamilunavo.onemoretap.removeads`
- `com.kamilunavo.onemoretap.theme.fire`
- `com.kamilunavo.onemoretap.theme.galaxy`
- `com.kamilunavo.onemoretap.theme.retro`
- `com.kamilunavo.onemoretap.theme.all`

## App Store Connect — ACCOUNT ACTION REQUIRED

- [x] Create/select **NavoTap** for bundle ID `com.kamilunavo.onemoretap`.
- [x] Create all five products above as Non-Consumable IAPs. User confirmed creation on 2026-08-20.
- [ ] Add German and English display names/descriptions.
- [ ] Set production prices and availability.
- [ ] Add App Review screenshots/notes for each IAP.
- [ ] Add all first non-consumable IAPs to the first app-version review submission.
- [ ] Complete App Privacy after the production ad configuration is final.

## AdMob — ACCOUNT ACTION REQUIRED

- [ ] Create production iOS app `NavoTap iOS` for bundle ID `com.kamilunavo.onemoretap`.
- [ ] Create `NavoTap iOS - Rewarded Continue`.
- [ ] Create `NavoTap iOS - Interstitial Restart`.
- [ ] Replace Google sample app ID and test unit IDs.
- [ ] Configure Privacy & Messaging / UMP for intended regions.
- [ ] Verify privacy-options flow on device.

## Device / TestFlight — REQUIRED

- [ ] Archive with production Apple signing.
- [ ] Upload a NavoTap release candidate to TestFlight.
- [ ] Fresh-install consent flow on a physical iPhone.
- [ ] Classic good/perfect/miss, difficulty, pause, background/foreground and rapid retry.
- [ ] Rewarded Continue success, dismissal, failure/no-fill and second-use prevention.
- [ ] Interstitial cadence #4, #7, #10 when available.
- [ ] Remove Ads purchase/relaunch persistence.
- [ ] Theme purchases, All Themes and selection persistence.
- [ ] Restore Purchases after reinstall/test-account reset.
- [ ] Confirm no Google sample IDs remain in release runtime configuration.

## Release blocker rule

Do not submit NavoTap to App Review while any required production IAP metadata is missing, any Google sample/test runtime identifier remains, or physical-device purchase/restore/rewarded-ad testing has not passed.
