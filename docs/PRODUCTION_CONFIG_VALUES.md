# NavoTap — Production AdMob Configuration

Last updated: 2026-08-20

NavoTap keeps the existing technical source paths and bundle/product IDs for continuity. Production AdMob identifiers were supplied by the publisher and inserted on `feat/production-admob`.

## Production AdMob app ID

File: `OneMoreTap/Resources/Info.plist`

`ca-app-pub-8944085355624754~4792390111`

## Production Rewarded Continue ad unit

File: `OneMoreTap/Monetization/AdService.swift`

`ca-app-pub-8944085355624754/7162618768`

Purpose: optional rewarded Continue after a failed Classic run.

## Production Interstitial Restart ad unit

File: `OneMoreTap/Monetization/AdService.swift`

`ca-app-pub-8944085355624754/3694930864`

Purpose: conservative restart cadence (#4, then #7/#10/...).

## Privacy / consent URL

Dedicated NavoTap privacy policy:

`https://kamilunavo.com/navotap/privacy`

German alias:

`https://kamilunavo.com/navotap/datenschutz`

The Kamilunavo website also publishes the AdMob seller declaration at:

`https://kamilunavo.com/app-ads.txt`

Expected Google seller line:

`google.com, pub-8944085355624754, DIRECT, f08c47fec0942fa0`

## Verification before archive

A production release candidate must contain none of Google's sample runtime identifiers (`ca-app-pub-3940256099942544...`). Development testing against live production ad units must use Google's supported test-device/test-mode mechanisms rather than intentionally generating production ad traffic.
