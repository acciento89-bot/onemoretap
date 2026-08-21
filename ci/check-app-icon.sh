#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:?image path required}"
LABEL="${2:-icon}"

test -s "$IMAGE" || {
  echo "::error title=AppIcon::$LABEL is missing or empty: $IMAGE"
  exit 1
}

INFO="$(sips -g pixelWidth -g pixelHeight -g hasAlpha -g format "$IMAGE")"
printf '%s\n' "$INFO"
W="$(printf '%s\n' "$INFO" | awk -F': ' '/pixelWidth/{print $2}')"
H="$(printf '%s\n' "$INFO" | awk -F': ' '/pixelHeight/{print $2}')"

test -n "$W" && test -n "$H"
test "$W" -gt 0 && test "$H" -gt 0

if [ "$LABEL" = "source" ]; then
  test "$W" = "1024" || { echo "::error title=AppIcon::source icon width must be 1024; got $W"; exit 1; }
  test "$H" = "1024" || { echo "::error title=AppIcon::source icon height must be 1024; got $H"; exit 1; }
  if printf '%s\n' "$INFO" | grep -q 'hasAlpha: yes'; then
    echo "::error title=AppIcon::source AppIcon must not have an alpha channel"
    exit 1
  fi
fi

swift - "$IMAGE" "$LABEL" <<'SWIFT'
import Foundation
import ImageIO
import CoreGraphics

let path = CommandLine.arguments[1]
let label = CommandLine.arguments[2]
let url = URL(fileURLWithPath: path) as CFURL

guard let src = CGImageSourceCreateWithURL(url, nil),
      let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
    fputs("cannot decode \(path)\n", stderr)
    exit(3)
}

let w = img.width
let h = img.height
let bytesPerRow = w * 4
var pixels = [UInt8](repeating: 0, count: h * bytesPerRow)
let colorSpace = CGColorSpaceCreateDeviceRGB()

guard let context = CGContext(
    data: &pixels,
    width: w,
    height: h,
    bitsPerComponent: 8,
    bytesPerRow: bytesPerRow,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    fputs("cannot create pixel context\n", stderr)
    exit(4)
}

context.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))

let step = max(1, min(w, h) / 256)
var sampleCount = 0
var nearBlack = 0
var colorful = 0
var sumLuma = 0.0
var maxLuma = 0.0
var colors = Set<Int>()

for y in stride(from: 0, to: h, by: step) {
    for x in stride(from: 0, to: w, by: step) {
        let i = y * bytesPerRow + x * 4
        let r = Double(pixels[i]) / 255.0
        let g = Double(pixels[i + 1]) / 255.0
        let b = Double(pixels[i + 2]) / 255.0
        let luma = 0.2126 * r + 0.7152 * g + 0.0722 * b

        sampleCount += 1
        sumLuma += luma
        maxLuma = max(maxLuma, luma)
        if luma < 0.03 { nearBlack += 1 }
        if max(r, g, b) - min(r, g, b) > 0.08 { colorful += 1 }

        let qr = Int(r * 15.0)
        let qg = Int(g * 15.0)
        let qb = Int(b * 15.0)
        colors.insert((qr << 8) | (qg << 4) | qb)
    }
}

let denominator = Double(max(sampleCount, 1))
let averageLuma = sumLuma / denominator
let nearBlackPercent = 100.0 * Double(nearBlack) / denominator
let colorfulPercent = 100.0 * Double(colorful) / denominator

print(String(
    format: "ICON_GATE %@ SIZE=%dx%d AVG_LUMA=%.4f MAX_LUMA=%.4f NEAR_BLACK=%.2f%% COLORFUL=%.2f%% COLORS=%d",
    label, w, h, averageLuma, maxLuma, nearBlackPercent, colorfulPercent, colors.count
))

let visuallyBroken = nearBlackPercent > 90.0 ||
    (averageLuma < 0.04 && maxLuma < 0.20) ||
    colors.count < 3

if visuallyBroken {
    print("::error title=AppIcon::\(label) is visually black/degenerate")
    exit(10)
}
SWIFT
