# One More Tap — App Store Connect & AdMob Setup

Last updated: 2026-08-20

This is the exact account-side configuration to mirror the implementation. Do not change product IDs without changing the app code and local StoreKit configuration as well.

## App identity

- App name: `One More Tap`
- Bundle ID: `com.kamilunavo.onemoretap`
- Category: Games
- Version prepared in project: `0.2.0`
- Build prepared in project: `2`

## In-App Purchases

Create all products as **Non-Consumable**.

### 1. Remove Ads

- Reference Name: `One More Tap - Remove Ads`
- Product ID: `com.kamilunavo.onemoretap.removeads`
- Intended DE price point: about `€2.99`
- DE Display Name: `Werbung entfernen`
- DE Description: `Entfernt automatische Werbeunterbrechungen dauerhaft. Freiwillige Rewarded Ads für einen Continue bleiben verfügbar.`
- EN Display Name: `Remove Ads`
- EN Description: `Permanently removes automatic ad interruptions. Optional rewarded ads for a continue remain available.`

### 2. Fire Theme

- Reference Name: `One More Tap - Fire Theme`
- Product ID: `com.kamilunavo.onemoretap.theme.fire`
- Intended DE price point: about `€1.99`
- DE Display Name: `Fire Theme`
- DE Description: `Schaltet das kosmetische Fire-Theme dauerhaft frei.`
- EN Display Name: `Fire Theme`
- EN Description: `Permanently unlocks the cosmetic Fire theme.`

### 3. Galaxy Theme

- Reference Name: `One More Tap - Galaxy Theme`
- Product ID: `com.kamilunavo.onemoretap.theme.galaxy`
- Intended DE price point: about `€1.99`
- DE Display Name: `Galaxy Theme`
- DE Description: `Schaltet das kosmetische Galaxy-Theme dauerhaft frei.`
- EN Display Name: `Galaxy Theme`
- EN Description: `Permanently unlocks the cosmetic Galaxy theme.`

### 4. Retro Theme

- Reference Name: `One More Tap - Retro Theme`
- Product ID: `com.kamilunavo.onemoretap.theme.retro`
- Intended DE price point: about `€1.99`
- DE Display Name: `Retro Theme`
- DE Description: `Schaltet das kosmetische Retro-Theme dauerhaft frei.`
- EN Display Name: `Retro Theme`
- EN Description: `Permanently unlocks the cosmetic Retro theme.`

### 5. All Themes

- Reference Name: `One More Tap - All Themes`
- Product ID: `com.kamilunavo.onemoretap.theme.all`
- Intended DE price point: about `€3.99`
- DE Display Name: `Alle Themes`
- DE Description: `Schaltet Fire, Galaxy und Retro dauerhaft als kosmetische Themes frei.`
- EN Display Name: `All Themes`
- EN Description: `Permanently unlocks Fire, Galaxy and Retro cosmetic themes.`

## IAP App Review note

Use this note for the IAP review metadata:

`One More Tap is a one-tap arcade game. The theme purchases are permanent cosmetic unlocks and do not affect scoring, difficulty or hit detection. Remove Ads permanently disables automatic interstitial advertising. The optional rewarded ad used to continue a failed run remains available because the user explicitly chooses it in exchange for the continue reward. Restore Purchases is available from the in-app Shop.`

A review screenshot must show the in-app Shop with the relevant product visible. Use a current physical-device/TestFlight screenshot after production products load correctly.

## AdMob production objects

Create one iOS app in AdMob:

- Internal app name: `One More Tap iOS`
- Bundle ID: `com.kamilunavo.onemoretap`

Create exactly these initial ad units:

### Rewarded

- Ad format: Rewarded
- Internal name: `OMT iOS - Rewarded Continue`
- Purpose: the single optional Continue offered after a failed Classic run

### Interstitial

- Ad format: Interstitial
- Internal name: `OMT iOS - Interstitial Restart`
- Purpose: conservative restart cadence, first eligible restart #4 and then every third restart

After AdMob creates the production identifiers:

1. Replace the sample `GADApplicationIdentifier` in `OneMoreTap/Resources/Info.plist` with the production AdMob app ID.
2. Replace the rewarded test unit ID in `OneMoreTap/Monetization/AdService.swift` with `OMT iOS - Rewarded Continue`'s production unit ID.
3. Replace the interstitial test unit ID in `OneMoreTap/Monetization/AdService.swift` with `OMT iOS - Interstitial Restart`'s production unit ID.
4. Never use production ad units while intentionally generating test traffic. Use Google's official test configuration for development/testing.

## UMP / Privacy & Messaging

Configure the production consent message in AdMob Privacy & Messaging before release. The app already refreshes consent status at launch, presents a required form before intentional ad requests, and exposes privacy options when UMP reports that an entry point is required.

Do not add an ATT prompt merely because ads are present. Re-evaluate ATT only if the final production configuration introduces tracking that requires authorization.

## App Store privacy handoff

Before submission, answer App Privacy from the actual final SDK configuration rather than from assumptions. Google Mobile Ads may require disclosure of data categories depending on enabled features and configuration. Re-check the current Google disclosure guidance at release time.

## First IAP submission

For the first app version that contains these in-app purchases, make sure the IAPs are included with that app-version submission in App Store Connect and that every IAP has its required review metadata/screenshot.
