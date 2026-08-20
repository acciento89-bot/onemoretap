# One More Tap — Project State

Last updated: 2026-08-20

## Current milestone

**Classic mode: COMPLETE (implementation + core tests).**

Classic is the locked gameplay foundation: a rotating orb, a target arc, one-tap hit detection, perfect zone, combo, score, coins, progressive difficulty, late-run direction reversals, miss/game-over, instant retry, pause/resume, background auto-pause, local best score and settings persistence, sound, haptics, and polished visual feedback.

## Product rules locked for Classic

- Portrait iPhone-first game.
- One-finger input; no swipe/drag controls.
- No tutorial flow beyond the in-game one-line instruction.
- Run starts immediately and restarts immediately.
- One miss ends the run.
- Difficulty increases continuously rather than via authored levels.
- Perfect hits are rewarded but not required.
- No pay-to-win mechanic inside Classic.
- Monetization must not interrupt the first few runs or alter hit detection.

## Visual direction

Dark premium arcade presentation with cyan/purple energy, white high-contrast orb, glowing target arc, restrained ambient particles, compact HUD, and no asset-heavy 3D pipeline.

## Technical state

- SwiftUI app shell.
- SpriteKit Classic scene.
- `OneMoreTapCore` pure Swift rules package.
- Unit tests cover hit quality, angular wrapping, game-over, reset, combo bonus and difficulty progression.
- Local persistence via UserDefaults.
- Privacy manifest declares local UserDefaults access and no tracking/data collection.
- App icon and three original generated sound effects are included.
- Shared Xcode scheme and CI workflow are included.

## Regression gates

1. A tap inside the target arc always scores.
2. A tap inside the perfect arc always reports Perfect.
3. Angular hit detection works across 0°/360°.
4. A miss ends the run and further taps cannot score.
5. Target arc never shrinks below 22°.
6. Speed remains capped at 4.2 rad/s.
7. Best score and earned coins persist only once per completed run.
8. App moving inactive/background pauses a live run.
9. Sound/haptics can be disabled independently.
10. Retry starts a clean run without returning Home.

## Next milestone (not part of Classic)

Monetization shell: rewarded continue, conservative interstitial cadence, Remove Ads purchase, cosmetic theme packs, StoreKit configuration, then physical iPhone QA/TestFlight.
