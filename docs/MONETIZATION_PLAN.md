# NavoTap — Monetization Pass

## Implemented

- StoreKit 2 non-consumable purchase shell.
- Remove Ads entitlement.
- Fire, Galaxy and Retro theme entitlements plus All Themes bundle support.
- Restore Purchases.
- Transaction update listener and current-entitlement refresh.
- One rewarded continue per Classic run.
- Conservative automatic interstitial cadence: restart #4, then every third restart.
- UMP consent refresh/form gate before ad requests.
- Privacy Options entry point when required.
- Theme selection persisted through `PlayerProfile`.
- Themes applied to home UI and SpriteKit Classic arena.

## Store product IDs — technical IDs retained

| Product | Type | ID |
| --- | --- | --- |
| Remove Ads | Non-consumable | `com.kamilunavo.onemoretap.removeads` |
| Fire Theme | Non-consumable | `com.kamilunavo.onemoretap.theme.fire` |
| Galaxy Theme | Non-consumable | `com.kamilunavo.onemoretap.theme.galaxy` |
| Retro Theme | Non-consumable | `com.kamilunavo.onemoretap.theme.retro` |
| All Themes | Non-consumable | `com.kamilunavo.onemoretap.theme.all` |

These IDs predate the NavoTap customer-facing name and are intentionally retained for StoreKit continuity.

## Development ad configuration

The repository intentionally uses Google's public test identifiers during development. Never ship these as production monetization IDs.

- Sample iOS AdMob app ID: `ca-app-pub-3940256099942544~1458002511`
- Test rewarded: `ca-app-pub-3940256099942544/1712485313`
- Test interstitial: `ca-app-pub-3940256099942544/4411468910`

## Release configuration still required

- Production AdMob app ID + ad units for NavoTap.
- AdMob Privacy & Messaging consent message.
- App Store Connect IAP creation and metadata under NavoTap.
- Final App Privacy disclosure review.
- Physical-device and TestFlight QA.
