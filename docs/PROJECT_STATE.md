# One More Tap — Project State

Last updated: 2026-08-20

## Current milestone

**Classic mode: COMPLETE and locked.**

**Monetization/release code: COMPLETE on `feat/monetization-shell`.**

The code-side release gates have passed, including 9/9 core tests and a full iOS Simulator build on GitHub Actions with Xcode 26.2, GoogleMobileAds 13.8.0 and GoogleUserMessagingPlatform 3.1.0. Remaining blockers are account/device operations that require App Store Connect, AdMob, production signing or a physical iPhone/TestFlight.

Classic remains the gameplay foundation: rotating orb, target arc, one-tap hit detection, perfect zone, combo, score, coins, progressive difficulty, late-run direction reversals, miss/game-over, instant retry, pause/resume, background handling, local best score/settings persistence, sound, haptics and polished visual feedback.

## Product rules locked for Classic

- Portrait iPhone-first game.
- One-finger input; no swipe/drag controls.
- No tutorial flow beyond the in-game one-line instruction.
- Run starts immediately and restarts immediately.
- One miss ends the run unless the player explicitly chooses the single rewarded continue.
- Difficulty increases continuously rather than via authored levels.
- Perfect hits are rewarded but not required.
- No pay-to-win purchases.
- Theme purchases are cosmetic only and never alter hit detection, scoring or difficulty.

## Monetization rules

- One optional rewarded-video continue per run.
- A rewarded continue preserves score/coins, resets combo, and reopens the same run.
- A run is persisted only once, after it actually ends; continue cannot duplicate coins or best-score commits.
- Automatic interstitials are only considered when the user actively chooses another run.
- First automatic interstitial is on restart #4, then every third restart (#7, #10, ...), provided an ad is loaded.
- `Remove Ads` disables automatic interstitials only. Rewarded continue remains optional and available.
- StoreKit 2 handles purchases, current entitlements, transaction updates and restore purchases.
- Free Neon theme plus Fire, Galaxy and Retro cosmetic packs; an All Themes bundle is supported.
- Selected theme persists locally and recolors the shell and Classic arena without changing gameplay geometry.

## Product identifiers — LOCKED

- `com.kamilunavo.onemoretap.removeads`
- `com.kamilunavo.onemoretap.theme.fire`
- `com.kamilunavo.onemoretap.theme.galaxy`
- `com.kamilunavo.onemoretap.theme.retro`
- `com.kamilunavo.onemoretap.theme.all`

## Ads / privacy implementation

- Google Mobile Ads SDK via Swift Package Manager.
- Google User Messaging Platform (UMP) via Swift Package Manager.
- Consent information is refreshed on app launch; required consent form is presented before intentional ad requests.
- A Privacy Options entry point appears in the shop when UMP requires one.
- Development uses Google's official iOS sample AdMob app ID and official rewarded/interstitial test IDs.
- The current Google SKAdNetwork identifier list was synced into `Info.plist` on 2026-08-20.
- The app does not request ATT authorization itself. Add an ATT prompt only if a future production configuration actually introduces tracking that requires it.
- Production AdMob app/unit IDs must replace every sample/test ID before release.
- App Store privacy disclosures must be completed against the final production Mobile Ads configuration.

## StoreKit testing

- `OneMoreTap/Resources/OneMoreTap.storekit` contains all five non-consumable products for local StoreKit testing.
- The shared Debug launch scheme enables that StoreKit configuration.
- Local test prices are not production prices and are never uploaded as App Store pricing.
- Purchase, cancellation, restore and entitlement flows can therefore be exercised locally before App Store Connect products exist.

## Visual direction

Dark premium arcade presentation with theme-driven energy colors, white high-contrast orb, glowing target arc, restrained ambient particles, compact HUD and no asset-heavy 3D pipeline.

## Technical state

- SwiftUI app shell.
- SpriteKit Classic scene.
- `OneMoreTapCore` pure Swift rules package.
- Core tests include rewarded-continue state restoration plus hit quality, angular wrapping, game-over, reset, combo bonus and difficulty progression.
- Local persistence via UserDefaults.
- StoreKit 2 purchase/entitlement service.
- Google Mobile Ads rewarded + interstitial service with UMP consent gate.
- Shop UI, restore purchases, Remove Ads and cosmetic theme selection.
- Explicit `Info.plist` contains the development AdMob app ID and current Google SKAdNetwork identifiers.
- Shared Xcode scheme and CI workflow are included.
- CI uses Xcode 26.2 for the current Google Ads SDK requirements and `actions/checkout@v6`.

## Regression gates

1. A tap inside the target arc always scores.
2. A tap inside the perfect arc always reports Perfect.
3. Angular hit detection works across 0°/360°.
4. A miss ends the run and further gameplay taps cannot score until a valid rewarded continue reopens it.
5. Rewarded continue can be used at most once per run.
6. Continue preserves score/coins, resets combo and does not commit the run early.
7. Target arc never shrinks below 22°.
8. Speed remains capped at 4.2 rad/s.
9. Best score and earned coins persist only once per completed run.
10. App moving inactive/background pauses a live run; a pending game-over is committed before leaving active state.
11. Sound/haptics can be disabled independently.
12. Remove Ads suppresses automatic interstitials but never changes Classic mechanics.
13. Paid themes remain cosmetic only.
14. No ad request is intentionally started until the UMP consent state permits ads.

## Validation completed

- Local: `swift test --package-path OneMoreTapCore` — 9/9 tests pass.
- Local: `swift-format lint --recursive OneMoreTap OneMoreTapCore` — clean.
- Local: Swift source syntax parse — clean.
- Local: Xcode project and `Info.plist` syntax checks — clean.
- GitHub Actions run `32406813188`: Core tests — success.
- GitHub Actions run `32406813188`: iOS Simulator build with Xcode 26.2 and resolved Google packages — success.
- The final branch head must remain green after release-documentation/CI-hygiene commits before merge.

## Remaining external release gates

These cannot be completed from the current GitHub-only release tooling and require the corresponding account/device:

1. App Store Connect: create the five locked non-consumable IAPs, production pricing/localization and App Review metadata.
2. AdMob: create the production iOS app plus rewarded and interstitial ad units; replace all sample/test IDs.
3. AdMob Privacy & Messaging: configure the production UMP message and verify privacy options.
4. App Store Connect: complete App Privacy answers for the final Mobile Ads configuration.
5. Apple signing: archive/upload a release candidate to TestFlight.
6. Physical iPhone QA: purchase, restore, rewarded continue, ad dismissal/failure, Remove Ads, theme persistence, background/foreground and rapid retry.
7. Submit only after `docs/RELEASE_CHECKLIST.md` is fully satisfied.
