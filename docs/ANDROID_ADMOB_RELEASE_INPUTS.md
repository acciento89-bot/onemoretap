# NavoTap Android AdMob release inputs

The three Android AdMob identifiers are supplied as manual `workflow_dispatch` inputs to `.github/workflows/android-release.yml` and are deliberately not stored in Git history or repository secrets.

Current Android production identifiers supplied by the publisher:

- AdMob App ID: `ca-app-pub-8944085355624754~8281696102`
- Rewarded Continue ad unit: `ca-app-pub-8944085355624754/1572817522`
- Restart Interstitial ad unit: `ca-app-pub-8944085355624754/1963699766`

All belong to publisher `pub-8944085355624754`, matching the existing `app-ads.txt` declaration.

The release workflow still requires only the persistent Play signing secrets:

- `ANDROID_UPLOAD_KEYSTORE_BASE64`
- `ANDROID_UPLOAD_KEYSTORE_PASSWORD`
- `ANDROID_UPLOAD_KEY_ALIAS`
- `ANDROID_UPLOAD_KEY_PASSWORD`

Never commit private upload-key material or signing passwords.
