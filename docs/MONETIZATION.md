# One More Tap — Monetization Setup

## Product strategy

Classic remains fully playable for free. Purchases are non-consumable cosmetics / convenience only.

### App Store Connect product IDs

| Product | Type | Product ID | Suggested launch price |
|---|---|---|---|
| Remove Ads | Non-Consumable | `com.kamilunavo.onemoretap.removeads` | €1.99 |
| Inferno Theme | Non-Consumable | `com.kamilunavo.onemoretap.theme.inferno` | €0.99 |
| Galaxy Theme | Non-Consumable | `com.kamilunavo.onemoretap.theme.galaxy` | €0.99 |
| Matrix Theme | Non-Consumable | `com.kamilunavo.onemoretap.theme.matrix` | €0.99 |
| Complete Pack | Non-Consumable | `com.kamilunavo.onemoretap.pack.complete` | €3.99 |

The app always renders the real localized App Store price returned by StoreKit. The prices above are only launch suggestions.

## Store behavior

- Neon is the free/default theme.
- Theme purchases unlock permanently through StoreKit 2 entitlements.
- Complete Pack unlocks all paid themes and removes regular ads.
- Remove Ads removes regular/interstitial ads; optional rewarded ads may still be offered for explicit player benefits.
- Restore Purchases calls `AppStore.sync()`.
- Refunded/revoked entitlements are not treated as owned.
- A paid theme automatically falls back to Neon if its entitlement is no longer valid.

## Ad preparation

Ad display is intentionally disabled until production ad unit IDs and the ad SDK are connected.

Expected Info.plist keys for the production adapter:

- `OMTRewardedAdUnitID`
- `OMTInterstitialAdUnitID`

`AdPolicy` currently defines:

- rewarded continue: only when ads are not removed and a rewarded unit is configured
- interstitial cadence: every 4 completed runs, only when ads are not removed and an interstitial unit is configured

Do not ship Google test ad unit IDs in a release build.

## Remaining external setup

1. Create the five non-consumable products in App Store Connect with the exact IDs above.
2. Add localized names/descriptions and prices.
3. Complete the paid-app / IAP agreements and banking/tax requirements if Apple requires them.
4. Create the AdMob app and production rewarded/interstitial units.
5. Integrate the current Google Mobile Ads SDK only after production IDs exist.
6. Complete consent/privacy configuration before enabling personalized advertising.
7. Sandbox-test purchase, restore, refund/revocation behavior, and ad-free entitlements.
