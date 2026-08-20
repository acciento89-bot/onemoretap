# One More Tap

A fast, one-finger arcade game for iPhone and iPad.

## Classic

**One rule:** tap when the rotating pointer is inside the glowing target.

- One tap controls the entire game.
- A normal hit continues the run.
- A PERFECT hit builds combo and scores more points.
- One miss ends the run.
- The target narrows and rotation accelerates as the level rises.
- Direction changes are introduced after the first onboarding levels.
- Best score, best level, runs, perfect hits and lifetime score persist locally.
- Haptics, first-run tutorial, pause/resume handling and portrait iPhone/iPad layout are included.

## Open in Xcode

Open `OneMoreTap.xcodeproj`, select the `OneMoreTap` scheme, then run on an iOS 17+ simulator or device.

Bundle identifier: `com.kamilunavo.onemoretap`

## Verification

```bash
swift test
```

GitHub Actions also performs an unsigned iOS Simulator build of the complete app.

## Scope

Classic is intentionally self-contained. Ads, rewarded continues, cosmetic packs, additional modes and Game Center are separate post-Classic passes so the core game remains small and reliable.
