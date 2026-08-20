# One More Tap — App Privacy Notes

Last updated: 2026-08-20

These notes prepare the App Store Connect privacy questionnaire. They are not a substitute for checking the final production SDK configuration at submission time.

## First-party app behavior

One More Tap stores gameplay/settings data locally with UserDefaults:

- best score
- coin balance
- selected cosmetic theme
- sound setting
- haptics setting

The app code does not implement an account system, server-side profile, contacts access, precise-location access, camera/microphone access, health data, or first-party analytics in the current release candidate.

## Advertising SDK behavior

The app integrates Google Mobile Ads and Google User Messaging Platform. The final App Store privacy answers must account for data the production Google Mobile Ads configuration may collect or process. Google's disclosure guidance should be checked again immediately before submission because SDK behavior and disclosures can change.

Potential Google Mobile Ads disclosure categories depend on configuration and can include identifiers, product interaction/advertising data, diagnostics and coarse/general location inferred from signals such as IP address.

## Consent and tracking

- UMP consent information is refreshed at launch.
- Required consent UI is presented before intentional ad requests.
- Privacy Options is exposed when UMP reports that it is required.
- The app itself does not request ATT authorization in the current release candidate.
- Do not add `NSUserTrackingUsageDescription` unless the final production advertising configuration actually requires an ATT prompt.

## Submission check

Before answering App Store Connect App Privacy:

1. Replace all development/sample AdMob identifiers with production identifiers.
2. Finalize the AdMob Privacy & Messaging configuration.
3. Confirm whether any mediation partners were added; if so, include their data practices as well.
4. Re-read Google's current Apple App Privacy disclosure guidance for the exact Mobile Ads SDK version being submitted.
5. Answer App Store Connect based on the actual final configuration, not solely on this document.
