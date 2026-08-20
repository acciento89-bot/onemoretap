# One More Tap — Project State

## Current milestone

**Classic 1.0 — implementation complete**

## Product rule

One More Tap stays a tiny one-finger arcade game. The player taps when a rotating pointer intersects a glowing target arc. One miss ends the run.

## Classic feature set

- Main menu with Classic launch, persistent best/run/perfect statistics and settings.
- First-run tutorial plus manually replayable tutorial.
- Smooth 60 Hz pointer presentation using `TimelineView`.
- Hit detection with wrap-safe angular math.
- Normal HIT and tighter PERFECT window.
- Combo scoring for consecutive PERFECT hits.
- Progressive target narrowing and speed increase.
- Direction changes after the introductory levels.
- Randomized next target with anti-double-tap spacing.
- Game-over flow with score, level, new-best state, retry and home.
- Local persistent stats.
- Optional haptic feedback.
- Automatic freeze/resume when the app changes scene phase.
- App icon and dark neon visual identity.
- iPhone and iPad portrait support.
- Accessibility label/action on the gameplay surface.
- Unit tests for Classic rules.
- CI for Swift core tests and unsigned iOS build.

## Visual target

Minimal premium arcade look: near-black background, cyan/white target glow, restrained purple ambient light, strong rounded typography, no character art and no unnecessary UI chrome.

## Explicitly deferred until after Classic

- Ad SDK and interstitial cadence.
- Rewarded-ad continue.
- Remove Ads IAP.
- Cosmetic/theme packs.
- Daily/SPEED/CHAOS/PERFECT modes.
- Game Center leaderboard/achievements.
- Audio pack beyond native haptic feedback.

These are expansion layers and must not destabilize the Classic core.

## Regression gates

1. A tap outside the target always ends the run.
2. A hit inside the target always advances exactly one level.
3. Angular hit detection works across the 0°/360° boundary.
4. PERFECT is stricter than HIT and awards more points.
5. Difficulty cannot shrink below a 22° target or exceed 430°/s.
6. A backgrounded run resumes without a pointer-angle jump.
7. Game-over stats are recorded exactly once per completed run.
8. The project builds without signing on an iOS Simulator target.

## Next milestone

Monetization shell: rewarded continue + sensible interstitial cadence + Remove Ads, followed by cosmetic packs. Do not start that pass until Classic has been played on-device and its feel is accepted.
