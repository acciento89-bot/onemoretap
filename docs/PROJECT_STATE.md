# One More Tap — Project State

Updated: 2026-08-20

## Branch

Active development branch: `classic-1.0`

## Product direction

A very small one-finger mobile game designed for fast sessions and fast shipping. No story, inventory, character system, large level pipeline, or complex 3D production.

## Classic

Classic gameplay is implemented:

- one-tap timing loop
- HIT / PERFECT / MISS grading
- score, combo, level and difficulty scaling
- target movement and direction changes
- game-over / immediate retry
- local best score and play statistics
- onboarding
- haptics
- pause/resume lifecycle handling
- iPhone/iPad portrait UI
- app icon
- unit-testable gameplay rules
- GitHub CI for Swift core tests and iOS Simulator build

## Monetization / cosmetic pass

Implemented in code:

- StoreKit 2 product loading
- purchase handling and transaction verification
- current entitlement refresh
- purchase restore
- revocation-aware ownership
- Remove Ads entitlement
- Complete Pack entitlement
- Inferno / Galaxy / Matrix paid themes
- Neon default theme
- persistent active theme selection
- in-game Packs storefront
- theme picker
- selected theme applied to Classic visuals
- ad configuration/policy hooks with ads safely disabled until production IDs are supplied
- export-compliance plist flag for no custom/non-exempt encryption

## Product IDs

See `docs/MONETIZATION.md`.

## Release blockers outside the repository

- App Store Connect app record / signing team must be configured.
- IAP products must be created in App Store Connect.
- Production AdMob IDs do not exist in the repository and ads are therefore not active.
- Google Mobile Ads SDK / consent flow must be connected before enabling ads.
- A physical-device/TestFlight pass is still required before App Store submission.

## Scope rule

Do not turn this into One More Floor. Keep Classic mechanically unchanged. New work should prioritize shipping, monetization, store metadata, QA, ads, and small cosmetic packs before adding extra game modes.
