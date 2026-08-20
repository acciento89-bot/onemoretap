# One More Tap — Production Configuration Replacement Map

Last updated: 2026-08-20

Do not ship the development identifiers listed below. This file records exactly where production values must be inserted after the AdMob account objects exist.

## AdMob app ID

File: `OneMoreTap/Resources/Info.plist`

Development value:

`ca-app-pub-3940256099942544~1458002511`

Replace with:

`<PRODUCTION_ADMOB_APP_ID_FOR_ONE_MORE_TAP_IOS>`

## Rewarded Continue ad unit

File: `OneMoreTap/Monetization/AdService.swift`

Development value:

`ca-app-pub-3940256099942544/1712485313`

Replace with the production unit ID for:

`OMT iOS - Rewarded Continue`

## Interstitial Restart ad unit

File: `OneMoreTap/Monetization/AdService.swift`

Development value:

`ca-app-pub-3940256099942544/4411468910`

Replace with the production unit ID for:

`OMT iOS - Interstitial Restart`

## Verification before archive

Search the repository for `ca-app-pub-3940256099942544`. A production release candidate must contain none of the Google sample app/ad IDs in runtime configuration.
