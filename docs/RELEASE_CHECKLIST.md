# One More Tap — Release Checklist

Last updated: 2026-08-20

This file is the release handoff for One More Tap. Code-side items are tracked separately from account-side items that require App Store Connect, AdMob, signing credentials, or a physical device.

## Code and CI — DONE

- [x] Classic gameplay locked and covered by regression tests.
- [x] Rewarded continue is limited to one use per run.
- [x] Continue preserves score/coins, resets combo, and cannot double-commit a run.
- [x] Conservative interstitial cadence implemented: restart #4, then every third restart when an ad is loaded.
- [x] Remove Ads disables automatic interstitials only; rewarded continue remains optional.
- [x] StoreKit 2 purchase, current-entitlement, transaction-update, and restore paths implemented.
- [x] Fire, Galaxy, Retro, and All Themes purchases are cosmetic only.
- [x] UMP consent is resolved before intentional ad requests.
- [x] Privacy-options entry point is exposed when UMP requires it.
- [x] Google development sample app/ad IDs are used during development.
- [x] Current Google SKAdNetwork identifiers synced into Info.plist on 2026-08-20.
- [x] No ATT prompt is requested by the app itself; do not add one unless a future production configuration actually requires tracking authorization.
- [x] Local StoreKit configuration contains all five non-consumables and is enabled for Debug launches.
- [x] Core test suite passes 9/9.
- [x] Xcode 26.2 iOS Simulator build resolves GoogleMobileAds 13.8.0 and GoogleUserMessagingPlatform 3.1.0 and builds successfully.
- [x] CI uses actions/checkout@v6 to avoid the deprecated Node 20 action runtime.

## Production product identifiers — LOCKED

Do not rename or recreate these IDs after production setup:

- `com.kamilunavo.onemoretap.removeads`
- `com.kamilunavo.onemoretap.theme.fire`
- `com.kamilunavo.onemoretap.theme.galaxy`
- `com.kamilunavo.onemoretap.theme.retro`
- `com.kamilunavo.onemoretap.theme.all`

The prices in `OneMoreTap/Resources/OneMoreTap.storekit` are local test values only. Production pricing is controlled in App Store Connect.

## App Store Connect — ACCOUNT ACTION REQUIRED

- [ ] Create/select the One More Tap app for bundle ID `com.kamilunavo.onemoretap`.
- [ ] Create all five products above as **Non-Consumable** in-app purchases.
- [ ] Add German and English display names/descriptions.
- [ ] Set production prices and availability.
- [ ] Add App Review screenshots/notes for each IAP.
- [ ] Attach the first IAPs to the app version when submitting the first version that contains them.
- [ ] Complete App Privacy answers after the production ad configuration is final.

## AdMob — ACCOUNT ACTION REQUIRED

- [ ] Create the production iOS app in AdMob for bundle ID `com.kamilunavo.onemoretap`.
- [ ] Create one production Rewarded ad unit for Continue.
- [ ] Create one production Interstitial ad unit for conservative restart ads.
- [ ] Replace the Google sample app ID in `OneMoreTap/Resources/Info.plist`.
- [ ] Replace the two Google test unit IDs in `OneMoreTap/Monetization/AdService.swift`.
- [ ] Configure Privacy & Messaging / UMP for the intended regions, including EEA/UK/Switzerland where applicable.
- [ ] Verify the privacy-options flow on a device after production consent configuration exists.
- [ ] If mediation is added later, add every mediation partner's required SKAdNetwork IDs as well.

## Device / TestFlight — SIGNING + DEVICE REQUIRED

- [ ] Archive with the production Apple Developer team/signing configuration.
- [ ] Upload a release candidate to TestFlight.
- [ ] On a physical iPhone: fresh install and first-launch consent flow.
- [ ] Classic: good/perfect/miss, difficulty ramp, pause, background/foreground, rapid retry.
- [ ] Rewarded Continue: success, dismissal, no-fill/failure, and second-use prevention.
- [ ] Interstitial cadence: no early interruption; restart #4 then #7/#10 when available.
- [ ] Remove Ads: purchase, relaunch persistence, and automatic-ad suppression.
- [ ] Themes: each individual purchase, All Themes, selection persistence, and cosmetic-only behavior.
- [ ] Restore Purchases after reinstall/test account reset.
- [ ] Confirm all production ads are live/tested safely and no Google sample IDs remain in a release build.
- [ ] Confirm App Store privacy answers match the final SDK/ad behavior.

## Release blocker rule

Do not submit to App Review while any Google sample/test ad identifier remains in the production build, any production IAP is missing in App Store Connect, or physical-device purchase/restore/rewarded-ad testing has not passed.
