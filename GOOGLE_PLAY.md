# NavoTap — Google Play release handoff

## Android identity

- App name: NavoTap
- Package / application ID: `com.kamilunavo.onemoretap`
- Version name: `1.0.0`
- Version code: `1`
- Target SDK: Android 16 / API 36
- Minimum SDK: API 26
- Category: Games / Arcade / Casual
- Base app price: Free
- Distribution: Android App Bundle (`.aab`)

## Locked gameplay parity

Android must retain the accepted iOS v1 rules:

- one-finger Classic mode;
- one miss ends a run unless the single optional rewarded Continue is used;
- Continue preserves score/coins, resets combo and is usable once per run;
- difficulty ramps continuously;
- target arc shrinks with score;
- direction reversals become eligible from score 12 and trigger at 30% after a successful hit;
- Perfect hits build combo and award bonus score/coins but are not required;
- automatic interstitial cadence starts on restart #4 and then every third restart (#7, #10, #13, ...);
- Remove Ads suppresses automatic interstitials only;
- Rewarded Continue remains optional after Remove Ads;
- themes are cosmetic only.

## Google Play Billing — one-time products

Create these as non-consumable/permanent one-time products. Every product needs an active one-time purchase option. The German launch prices are locked to the accepted iOS v1 price decisions.

| Product | Product ID | DE launch price |
| --- | --- | ---: |
| Remove Ads | `com.kamilunavo.onemoretap.removeads` | €2.99 |
| Fire Theme | `om.kamilunavo.onemoretap.theme.fire` | €1.99 |
| Galaxy Theme | `com.kamilunavo.onemoretap.theme.galaxy` | €1.99 |
| Retro Theme | `com.kamilunavo.onemoretap.theme.retro` | €1.99 |
| All Themes | `com.kamilunavo.onemoretap.theme.all` | €3.99 |

The Fire Theme identifier intentionally retains the legacy missing leading `c` (`om...`). Do not correct or normalize it: the Android billing code and release handoff deliberately use the established identifier.

Suggested one-time purchase option ID for all five products: `lifetime`.

## AdMob / UMP

Android AdMob identities are platform-specific and MUST NOT reuse the iOS ad unit IDs.

Before a production Android release, create an Android NavoTap app in AdMob and create:

- Android AdMob App ID
- Rewarded ad unit for the optional Continue
- Interstitial ad unit for restart cadence

Release build variables:

- `NAVOTAP_ADMOB_APP_ID`
- `NAVOTAP_REWARDED_AD_ID`
- `NAVOTAP_INTERSTITIAL_AD_ID`

These values must stay outside source control. The Release Gradle build hard-fails if any are absent.

Debug builds intentionally use Google's official Android sample AdMob IDs. Never upload a debug/test-ad bundle to production.

Current Android SDKs:

- Google Mobile Ads SDK 25.4.0
- User Messaging Platform 4.0.0

Consent flow:

- request consent information on every app launch;
- load/show a required consent form;
- request ads only when UMP `canRequestAds()` is true;
- expose Privacy Options only when UMP reports that an entry point is required.

## Persistent Play upload signing

A dedicated NavoTap RSA-4096 upload key has been created for Google Play. Keep the private backup outside source control and keep using this same upload certificate for later NavoTap versions.

Upload certificate SHA-256 fingerprint:

`F1:BD:1B:E0:BD:C0:54:20:B4:37:16:04:DC:FB:7C:1E:DF:38:91:30:4A:5B:5A:CF:27:C0:F9:3A:12:91:97:F9`

The workflow `.github/workflows/android-release.yml` creates the signed production AAB only when all seven release secrets are available:

- `ANDROID_UPLOAD_KEYSTORE_BASE64`
- `ANDROID_UPLOAD_KEYSTORE_PASSWORD`
- `ANDROID_UPLOAD_KEY_ALIAS`
- `ANDROID_UPLOAD_KEY_PASSWORD`
- `NAVOTAP_ADMOB_APP_ID`
- `NAVOTAP_REWARDED_AD_ID`
- `NAVOTAP_INTERSTITIAL_AD_ID`

The workflow rejects Google's sample/test ad IDs, runs unit tests, builds the minified release with the persistent upload key, verifies the JAR signature and emits `NavoTap-1.0.0-1-PlayStore.aab` plus SHA-256 checksum.

## German Play listing

### Short description
Schnelles Ein-Finger-Arcade-Spiel für Timing, Reflexe und neue Highscores.

### Full description
NavoTap ist ein schnelles Ein-Finger-Arcade-Spiel, bei dem Timing und Reaktion entscheiden.

Tippe genau dann, wenn die kreisende Kugel den markierten Zielbereich erreicht. Jeder Treffer zählt – und mit jedem erfolgreichen Tap steigt die Herausforderung.

• Einfach zu lernen, schwer zu meistern
• Schnelle Runden für zwischendurch
• Perfekte Treffer erhöhen Combo und Punktzahl
• Steigendes Tempo und wechselnde Drehrichtungen
• Highscore und Fortschritt werden lokal gespeichert
• Verschiedene kosmetische Themes
• Optionaler einmaliger Continue pro Runde über ein Rewarded Ad
• Werbefreie Option als einmaliger In-App-Kauf

NavoTap konzentriert sich auf eine einfache Regel: richtig tippen, so lange wie möglich durchhalten und den eigenen Highscore schlagen.

Die verfügbaren Themes verändern ausschließlich das Aussehen des Spiels und bieten keinen spielerischen Vorteil.

## English Play listing

### Short description
Fast one-tap arcade action for timing, reflexes and high scores.

### Full description
NavoTap is a fast one-tap arcade game where timing and reaction matter.

Tap exactly when the orbiting orb reaches the highlighted target area. Every hit counts, and every successful tap increases the challenge.

• Easy to learn, hard to master
• Fast rounds for quick play
• Perfect hits build your combo and score
• Increasing speed and changing directions
• High score and progress are stored locally
• Multiple cosmetic themes
• One optional rewarded Continue per run
• One-time option to remove automatic ads

NavoTap is built around one simple rule: time your tap, survive as long as possible, and beat your high score.

Available themes are cosmetic only and provide no gameplay advantage.

## URLs

- Privacy: `https://kamilunavo.com/navotap/privacy`
- Support: `https://kamilunavo.com/support`
- Website: `https://kamilunavo.com`
- app-ads.txt: `https://kamilunavo.com/app-ads.txt`

## Play Console declarations / release gates

- [ ] Create Play Console app `NavoTap` with package `com.kamilunavo.onemoretap`.
- [ ] Create all five one-time products with the locked prices above and activate their purchase options.
- [ ] Create Android NavoTap in AdMob and obtain the three Android production IDs.
- [x] Create persistent Play upload key and signed-release workflow.
- [ ] Add upload-key + AdMob values to GitHub repository secrets.
- [ ] Run `NavoTap Android Play Release` and obtain the signed production AAB.
- [ ] Complete Ads declaration.
- [ ] Complete Data safety against the final Google Mobile Ads / UMP / Billing dependency set.
- [ ] Complete target audience/content rating and app content declarations.
- [ ] Verify privacy/support/app-ads.txt URLs.
- [ ] Upload Release AAB to internal testing.
- [ ] On a Play-enabled emulator/device: fresh launch/UMP, Classic lifecycle, rewarded Continue once/run, rewarded unavailable/retry, interstitial #4/#7/#10, all five purchases, persistence and restore.
- [ ] Verify Remove Ads suppresses interstitials but not optional rewarded Continue.
- [ ] Complete any closed-testing requirement attached to the developer account.
- [ ] Promote to production only after every gate above is green.
