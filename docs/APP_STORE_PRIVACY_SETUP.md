# NavoTap — App Store Privacy Setup

Last updated: 2026-08-20

This is the App Store Connect privacy baseline for the current NavoTap release configuration:

- Google Mobile Ads SDK + UMP
- Rewarded + Interstitial only
- no mediation partners
- no first-party analytics
- no account system
- no ATT request in the app
- no first-party server-side gameplay profile

Re-check this document if mediation, analytics, ATT, login/accounts, crash reporting or any other SDK is added.

## Privacy Policy URL

Use:

`https://kamilunavo.com/navotap/privacy`

## Data collected through Google Mobile Ads

Google's current iOS disclosure guidance says the Mobile Ads SDK may collect IP-derived general location, crash logs, performance data, device identifiers, advertising data and product interaction data.

Use these App Store Connect data types as the baseline:

### Location → Coarse Location

Purposes:
- Third-Party Advertising
- Analytics

### Identifiers → Device ID

Purposes:
- Third-Party Advertising
- Analytics

Linked to user/device identity: **Yes** as a conservative App Store disclosure baseline because Apple treats device-level identifiers as identity-linked unless de-identified before collection.

### Usage Data → Product Interaction

Purposes:
- Third-Party Advertising
- Analytics

Linked: **Yes** as a conservative baseline when associated with device/ad identifiers.

### Usage Data → Advertising Data

Purposes:
- Third-Party Advertising
- Analytics

Linked: **Yes** as a conservative baseline when associated with device/ad identifiers.

### Diagnostics → Crash Data

Purposes:
- App Functionality
- Analytics
- Third-Party Advertising

Linked: **No** baseline. Google's current disclosure describes the crash logs as non-user-related.

### Diagnostics → Performance Data

Purposes:
- App Functionality
- Analytics
- Third-Party Advertising

Linked: **Yes** baseline. Google's current disclosure describes performance data as user-associated and notes that it may also be used for ads.

## Tracking question

Current NavoTap code does **not** request App Tracking Transparency authorization and does not intentionally access IDFA through an ATT flow. No mediation or separate cross-app analytics/tracking SDK is configured.

Baseline for this release: **do not declare first-party tracking / Data Used to Track You unless the final App Store Connect/AdMob/Xcode privacy report shows tracking in the actual production configuration.**

This is intentionally a release-time verification gate rather than a blind assumption. Apple defines tracking as linking app data with third-party data for targeted advertising/measurement or sharing it with a data broker. If the production configuration changes to perform such tracking, update the privacy label and add the required ATT flow before shipping.

## First-party local data

Best score, coins, selected theme, sound/haptics preferences and entitlement-derived UI state are stored locally on the device. They are not transmitted to a Kamilunavo server by the current app code and therefore are not first-party App Store 'collected' data.

Apple payment details are entered and processed outside NavoTap through StoreKit/App Store infrastructure; NavoTap does not receive payment card/bank-account details.

## Final verification before submission

1. Generate/review the Xcode privacy report for the exact archive being uploaded.
2. Confirm Google Mobile Ads / UMP versions and their privacy manifests.
3. Confirm no mediation or analytics SDK was added.
4. Confirm NavoTap still contains no ATT request or `NSUserTrackingUsageDescription` unless tracking was intentionally introduced.
5. Confirm App Store Connect answers match the final archive and current Google disclosure guidance.
