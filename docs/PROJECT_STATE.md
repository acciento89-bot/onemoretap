# One More Tap — Project State

Last updated: 2026-08-20

## Current milestone

**Classic mode: COMPLETE and locked.**

**Monetization shell: IMPLEMENTED on `feat/monetization-shell`, pending iOS CI/device QA and production store/ad configuration.**

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

## Product identifiers

- `com.kamilunavo.onemoretap.removeads`
- `com.kamilunavo.onemoretap.theme.fire`
- `com.kamilunavo.onemoretap.theme.galaxy`
- `com.kamilunavo.onemoretap.theme.retro`
- `com.kamilunavo.onemoretap.theme.all`

## Ads / privacy implementation

- Google Mobile Ads SDK via Swift Package Manager.
- Google User Messaging Platform (UMP) via Swift Package Manager.
- Consent information is refreshed on app launch; required consent form is presented before ad requests.
- A Privacy Options entry point appears in the shop when UMP requires one.
- Development currently uses Google's official iOS sample AdMob app ID and test rewarded/interstitial unit IDs.
- Production AdMob app/unit IDs must replace the test IDs before release.
- App Store privacy disclosures must be reviewed once the production ad configuration is final.

## Visual direction

Dark premium arcade presentation with theme-driven energy colors, white high-contrast orb, glowing target arc, restrained ambient particles, compact HUD and no asset-heavy 3D pipeline.

## Technical state

- SwiftUI app shell.
- SpriteKit Classic scene.
- `OneMoreTapCore` pure Swift rules package.
- Core tests now include rewarded-continue state restoration in addition to hit quality, angular wrapping, game-over, reset, combo bonus and difficulty progression.
- Local persistence via UserDefaults.
- StoreKit 2 purchase/entitlement service.
- Google Mobile Ads rewarded + interstitial service with UMP consent gate.
- Shop UI, restore purchases, Remove Ads and cosmetic theme selection.
- Explicit Info.plist contains the development AdMob application ID and initial SKAdNetwork entries.
- Shared Xcode scheme and CI workflow are included.

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

## Validation completed locally

- `swift test --package-path OneMoreTapCore`: 9/9 Swift Testing tests pass.
- `swift-format lint --recursive OneMoreTap OneMoreTapCore`: clean.
- `swiftc -frontend -parse` for all app Swift source files: clean syntax parse.
- `plutil -lint OneMoreTap.xcodeproj/project.pbxproj`: project file syntax OK.
- `Info.plist` parses successfully.

## Remaining release gates

1. iOS Simulator build on GitHub Actions/Xcode with Swift Package resolution.
2. Create the five non-consumable products in App Store Connect and set pricing/localization/review metadata.
3. Create the production AdMob app, rewarded unit and interstitial unit; replace sample IDs.
4. Configure AdMob Privacy & Messaging consent message for EEA/UK/Switzerland and verify the privacy-options flow.
5. Sync the full current Google SKAdNetwork identifier list before App Store submission.
6. Update App Store privacy answers for the final Mobile Ads configuration.
7. Physical iPhone QA: purchase, restore, rewarded continue, ad dismissal/failure, Remove Ads, theme persistence, background/foreground and rapid retry.
8. TestFlight release candidate.
