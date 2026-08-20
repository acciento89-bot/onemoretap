# NavoTap — App Store Connect & AdMob Setup

Last updated: 2026-08-20

This is the exact account-side configuration to mirror the implementation. **NavoTap is the locked customer-facing name.** The existing technical bundle/product identifiers remain unchanged for continuity and are not visible to customers.

## App identity

- App name: `NavoTap`
- Bundle ID: `com.kamilunavo.onemoretap`
- Category: Games
- Version prepared in project: `0.2.0`
- Build prepared in project: `2`

## In-App Purchases

Create all products as **Non-Consumable**.

### 1. Remove Ads
- Reference Name: `NavoTap - Remove Ads`
- Product ID: `com.kamilunavo.onemoretap.removeads`
- Intended DE price point: about `€2.99`
- DE Display Name: `Werbung entfernen`
- DE Description: `Entfernt automatische Werbeunterbrechungen dauerhaft. Freiwillige Rewarded Ads für einen Continue bleiben verfügbar.`
- EN Display Name: `Remove Ads`
- EN Description: `Permanently removes automatic ad interruptions. Optional rewarded ads for a continue remain available.`

### 2. Fire Theme
- Reference Name: `NavoTap - Fire Theme`
- Product ID: `com.kamilunavo.onemoretap.theme.fire`
- Intended DE price point: about `€1.99`
- DE/EN Display Name: `Fire Theme`

### 3. Galaxy Theme
- Reference Name: `NavoTap - Galaxy Theme`
- Product ID: `com.kamilunavo.onemoretap.theme.galaxy`
- Intended DE price point: about `€1.99`
- DE/EN Display Name: `Galaxy Theme`

### 4. Retro Theme
- Reference Name: `NavoTap - Retro Theme`
- Product ID: `com.kamilunavo.onemoretap.theme.retro`
- Intended DE price point: about `€1.99`
- DE/EN Display Name: `Retro Theme`

### 5. All Themes
- Reference Name: `NavoTap - All Themes`
- Product ID: `com.kamilunavo.onemoretap.theme.all`
- Intended DE price point: about `€3.99`
- DE Display Name: `Alle Themes`
- EN Display Name: `All Themes`

Theme descriptions: permanent cosmetic unlocks only; no scoring, hit-detection or difficulty advantage.

## IAP App Review note

`NavoTap is a one-tap arcade game. Theme purchases are permanent cosmetic unlocks and do not affect scoring, difficulty or hit detection. Remove Ads permanently disables automatic interstitial advertising. The optional rewarded ad used to continue a failed run remains available because the user explicitly chooses it in exchange for the continue reward. Restore Purchases is available from the in-app Shop.`

A review screenshot must show the in-app Shop with the relevant product visible.

## AdMob production objects

Create one iOS app in AdMob:
- Internal app name: `NavoTap iOS`
- Bundle ID: `com.kamilunavo.onemoretap`

Create exactly these initial ad units:
- Rewarded: `NavoTap iOS - Rewarded Continue`
- Interstitial: `NavoTap iOS - Interstitial Restart`

Then replace the sample/test values documented in `docs/PRODUCTION_CONFIG_VALUES.md`.

## UMP / Privacy & Messaging

Configure the production consent message in AdMob Privacy & Messaging before release. The app already refreshes consent status at launch, presents a required form before intentional ad requests, and exposes privacy options when UMP reports that an entry point is required.

Do not add an ATT prompt merely because ads are present. Re-evaluate ATT only if the final production configuration introduces tracking that requires authorization.

## First IAP submission

For the first app version containing these in-app purchases, include the IAPs with the app-version submission in App Store Connect and provide required review metadata/screenshots.
