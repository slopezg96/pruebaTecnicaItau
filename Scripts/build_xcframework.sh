#!/bin/bash
# Genera BookStoreNetworkingKit.xcframework (device + simulator) a partir del
# target de framework BookStoreNetworkingKit/BookStoreNetworkingKit.xcodeproj.
#
# Uso: ./Scripts/build_xcframework.sh
# Salida: build_xcframework/BookStoreNetworkingKit.xcframework

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/BookStoreNetworkingKit/BookStoreNetworkingKit.xcodeproj"
SCHEME="BookStoreNetworkingKit"
OUTPUT_DIR="$ROOT_DIR/build_xcframework"
ARCHIVES_DIR="$OUTPUT_DIR/archives"

rm -rf "$OUTPUT_DIR"
mkdir -p "$ARCHIVES_DIR"

if [ ! -d "$PROJECT_PATH" ]; then
  echo "No existe $PROJECT_PATH — generando con xcodegen..."
  (cd "$ROOT_DIR/BookStoreNetworkingKit" && xcodegen generate)
fi

echo "==> Archivando para iOS (device)"
xcodebuild archive \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVES_DIR/ios.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  CODE_SIGNING_ALLOWED=NO

echo "==> Archivando para iOS Simulator"
xcodebuild archive \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "$ARCHIVES_DIR/ios-simulator.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  CODE_SIGNING_ALLOWED=NO

echo "==> Creando XCFramework"
xcodebuild -create-xcframework \
  -framework "$ARCHIVES_DIR/ios.xcarchive/Products/Library/Frameworks/BookStoreNetworkingKit.framework" \
  -framework "$ARCHIVES_DIR/ios-simulator.xcarchive/Products/Library/Frameworks/BookStoreNetworkingKit.framework" \
  -output "$OUTPUT_DIR/BookStoreNetworkingKit.xcframework"

echo "==> Listo: $OUTPUT_DIR/BookStoreNetworkingKit.xcframework"
