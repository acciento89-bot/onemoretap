#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
QA_DIR=$(mktemp -d "${TMPDIR:-/tmp}/navotap-provider-isolation.XXXXXX")
trap 'rm -rf "$QA_DIR"' EXIT
xcrun swiftc -emit-module -emit-library -module-name StoreKit ci/provider-isolation/StoreKitStub.swift -o "$QA_DIR/libStoreKit.dylib" -emit-module-path "$QA_DIR/StoreKit.swiftmodule"
xcrun swiftc -DDEBUG -I "$QA_DIR" -L "$QA_DIR" -lStoreKit -parse-as-library OneMoreTap/Monetization/StoreService.swift ci/provider-isolation/Smoke.swift -o "$QA_DIR/smoke"
DYLD_LIBRARY_PATH="$QA_DIR" "$QA_DIR/smoke" --navoTapProviderDisabledQA
EXPECT_PROVIDER_CALLS=1 DYLD_LIBRARY_PATH="$QA_DIR" "$QA_DIR/smoke"
xcrun swiftc -I "$QA_DIR" -L "$QA_DIR" -lStoreKit -parse-as-library OneMoreTap/Monetization/StoreService.swift ci/provider-isolation/Smoke.swift -o "$QA_DIR/release-smoke"
EXPECT_PROVIDER_CALLS=1 DYLD_LIBRARY_PATH="$QA_DIR" "$QA_DIR/release-smoke" --navoTapProviderDisabledQA
