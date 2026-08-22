# NavoTap — Google Play release handoff

## Android release candidate

- App name: NavoTap
- Package / application ID: `com.kamilunavo.onemoretap`
- Release candidate: `1.0.3 (4)`
- Target SDK: Android 16 / API 36
- Minimum SDK: API 26
- Category: Games / Arcade / Casual
- Base app price: Free
- Distribution: Android App Bundle (`.aab`)
- Release minification: disabled for 1.0.3 while the Play-only startup crash fix remains under real-device verification

## Locked gameplay parity

Android retains the accepted gameplay rules:

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

All five items are permanent/non-consumable one-time products. The Android client never hard-codes prices; it renders the localized price returned by Google Play.

| Product | Product ID | Current DE Play test price observed |
| --- | --- | ---: |
| Remove Ads | `com.kamilunavo.onemoretap.removeads` | €3.59 |
| Fire Theme | `om.kamilunavo.onemoretap.theme.fire` | €2.39 |
| Galaxy Theme | `com.kamilunavo.onemoretap.theme.galaxy` | €2.39 |
| Retro Theme | `com.kamilunavo.onemoretap.theme.retro` | €2.39 |
| All Themes | `com.kamilunavo.onemoretap.theme.all` | €4.79 |

The Fire Theme identifier intentionally retains the legacy missing leading `c` (`om...`). Do not correct or normalize it: the Android billing code and Play product use the established identifier.

## AdMob / UMP

Android production IDs are locked in `.github/workflows/android-release.yml` because AdMob app/ad-unit IDs are public runtime identifiers, not credentials:

- App ID: `ca-app-pub-8944085355624754~8281696102`
- Rewarded Continue: `ca-app-pub-8944085355624754/1572817522`
- Restart interstitial: `ca-app-pub-8944085355624754/1963699766`

Current SDKs:

- Google Mobile Ads SDK 25.4.0
- User Messaging Platform 4.0.0

Release behavior:

- UMP/AdMob start 1.5 seconds after the first app frame so Google SDK startup cannot block launch;
- ads are requested only when UMP `canRequestAds()` is true;
- Privacy Options are shown only when UMP reports they are required;
- UMP/AdMob failures are fail-soft and never block gameplay;
- release-visible consent diagnostic/error text is removed; diagnostics are debug-only;
- Google Mobile Ads auto-init provider is removed from the manifest and initialization is controlled by `AdManager`.

### External AdMob gate before production

The Play-distributed 1.0.2 test exposed `Publisher misconfiguration: no form(s) configured for the input app ID`. Before production promotion, AdMob Privacy & messaging must have an applicable consent message/form configured and published for the Android NavoTap app. Re-test a fresh install afterwards. This is an AdMob-console configuration gate, not an app-code crash.

## Persistent Play upload signing

A dedicated persistent NavoTap Google Play upload key is already in use. Upload certificate SHA-256:

`F1:BD:1B:E0:BD:C0:54:20:B4:37:16:04:DC:FB:7C:1E:DF:38:91:30:4A:5B:5A:CF:27:C0:F9:3A:12:91:97:F9`

Repository secrets used by `.github/workflows/android-release.yml`:

- `ANDROID_UPLOAD_KEYSTORE_BASE64`
- `ANDROID_UPLOAD_KEYSTORE_PASSWORD`
- `ANDROID_UPLOAD_KEY_ALIAS`
- `ANDROID_UPLOAD_KEY_PASSWORD`

The release workflow is now one-click/manual-dispatch: it runs release unit/startup tests, creates the signed production AAB, verifies its signature and emits `NavoTap-1.0.3-4-PlayStore.aab` plus SHA-256 checksum.

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

Repository verification:

- NavoTap privacy route exists and is being updated for iOS + Android / Google Play Billing.
- `public/app-ads.txt` contains `google.com, pub-8944085355624754, DIRECT, f08c47fec0942fa0`.
- generic Kamilunavo support route exists.

## Final Play release gates

Repository/code gates:

- [x] Play package identity fixed to `com.kamilunavo.onemoretap`.
- [x] Target API 36.
- [x] Five Billing products wired and prices loaded from Google Play on the Play-distributed test build.
- [x] Persistent upload key and signed-release pipeline proven with 1.0.2 (3).
- [x] Play-distributed 1.0.2 (3) cold-start crash no longer reproduces on the reported test device.
- [x] Release startup smoke exercises the delayed Google SDK startup path.
- [x] Release UI no longer exposes UMP diagnostics and uses explicit dark-theme content contrast.
- [x] Version display reads `BuildConfig.VERSION_NAME` / `VERSION_CODE`.
- [x] Android privacy policy source covers Google Play Billing and Android AdMob.
- [x] app-ads.txt publisher entry exists in the website repository.
- [ ] CI green for 1.0.3 (4).
- [ ] Signed `NavoTap-1.0.3-4-PlayStore.aab` produced from merged release candidate.

External console gates:

- [x] Google Play app exists and internal testing is usable.
- [x] Five one-time products return localized prices in the Play-distributed app.
- [ ] AdMob Privacy & messaging form/message configured and published for Android NavoTap; fresh-install UMP retest clean.
- [ ] Play Console Ads declaration completed accurately.
- [ ] Play Console Data safety completed against Google Mobile Ads / UMP / Billing.
- [ ] Target audience/content rating/app-content declarations completed.
- [ ] Final 1.0.3 (4) AAB uploaded to internal testing.
- [ ] Final device test: fresh launch, Classic, background/resume, rewarded Continue once/run, interstitial cadence, all five purchases/restore, theme persistence, Remove Ads behavior, force-stop/relaunch.
- [ ] Promote the same tested versionCode 4 to the required next track/production; do not rebuild after approval of this candidate.
