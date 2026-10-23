#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
QA_DIR=$(mktemp -d "${TMPDIR:-/tmp}/navotap-ads-isolation.XXXXXX")
trap 'rm -rf "$QA_DIR"' EXIT
xcrun swiftc -emit-module -emit-library -module-name StoreKit ci/provider-isolation/StoreKitStub.swift -o "$QA_DIR/libStoreKit.dylib" -emit-module-path "$QA_DIR/StoreKit.swiftmodule"
for pair in 'GoogleMobileAds AdsStub' 'UserMessagingPlatform ConsentStub'; do
 read -r module file <<< "$pair"
 xcrun swiftc -I "$QA_DIR" -L "$QA_DIR" -lStoreKit -emit-module -emit-library -module-name "$module" "ci/provider-isolation/$file.swift" -o "$QA_DIR/lib$module.dylib" -emit-module-path "$QA_DIR/$module.swiftmodule"
done
SOURCE="${AD_SOURCE:-OneMoreTap/Monetization/AdService.swift}"
xcrun swiftc -DDEBUG -I "$QA_DIR" -L "$QA_DIR" -lStoreKit -lGoogleMobileAds -lUserMessagingPlatform -parse-as-library "$SOURCE" ci/provider-isolation/AdsSmoke.swift -o "$QA_DIR/smoke"
DYLD_LIBRARY_PATH="$QA_DIR" "$QA_DIR/smoke" --navoTapProviderDisabledQA
EXPECT_PROVIDER_CALLS=1 DYLD_LIBRARY_PATH="$QA_DIR" "$QA_DIR/smoke"
xcrun swiftc -I "$QA_DIR" -L "$QA_DIR" -lStoreKit -lGoogleMobileAds -lUserMessagingPlatform -parse-as-library "$SOURCE" ci/provider-isolation/AdsSmoke.swift -o "$QA_DIR/release-smoke"
EXPECT_PROVIDER_CALLS=1 DYLD_LIBRARY_PATH="$QA_DIR" "$QA_DIR/release-smoke" --navoTapProviderDisabledQA
