# NavoTap — App Store Release Handoff

Last updated: 2026-08-21

## Current release

- Customer-facing name: **NavoTap**
- App Store version: **1.0**
- Release build: **1.0 (6)**
- Build 5 remains permanently rejected for release because of the black compiled AppIcon defect.
- Build 6 was physically verified on iPhone with the corrected non-black icon and normal launch behavior.
- Build 6 is selected for App Store version 1.0.

## App Store Connect — confirmed complete

- Build **1.0 (6)** assigned to App Store version **1.0**.
- Primary category and game subcategories completed.
- Content-rights declaration completed.
- Age-rating questionnaire completed.
- Localized subtitle/description/keywords completed.
- Support URL and marketing URL completed.
- Copyright completed.
- App Review contact/details and review notes completed.
- App pricing set to **Free**.
- Export Compliance for build 6 completed; missing-compliance warning cleared.
- App Privacy already completed.
- All five Non-Consumable IAP records already exist with DE/EN localization, price schedules, review notes and review screenshots.
- Existing draft review submission already contains exactly the five IAP review items.

## Remaining release gates

1. Verify Rewarded unavailable/retry behavior on a physical device.
2. Fresh-install UMP consent + Privacy Options physical QA.
3. Complete Classic lifecycle QA: difficulty/reversals, pause, background/foreground and rapid retry.
4. Final production-build smoke test on NavoTap 1.0 (6) without intentionally clicking live advertisements.
5. Verify `https://kamilunavo.com/navotap/privacy` is live and reachable.
6. Verify `https://kamilunavo.com/app-ads.txt` is live and reachable.
7. Add App Store version 1.0 itself to the existing review submission that already contains the five IAPs.
8. Confirm the draft contains version 1.0 plus all five IAPs.
9. Submit to App Review only after every remaining gate is green.

## Web verification note

A search-engine/web-index check on 2026-08-21 did not surface the dedicated NavoTap privacy path or root `app-ads.txt`, so these two web gates remain intentionally unconfirmed. The general Kamilunavo site, legal pages and support/contact information are publicly indexed.

## Do not regress

- Do not reselect build 5.
- Do not rename the technical bundle/product identifiers.
- Fire IAP remains the live legacy identifier `om.kamilunavo.onemoretap.theme.fire`.
- Do not submit the review draft until the remaining physical QA and web gates are green.
