#!/bin/bash
set -e

DEV_TEAM=${DEVELOPMENT_TEAM:-}
DIST=$(PWD)/dist
mkdir -p $DIST

mkdir -p $DIST/intermediates

echo "Cleanup"
xcodebuild -project ./BarcodeScannerFramework/BarcodeScannerFramework.xcodeproj -target "BarcodeScannerFramework" -configuration Release clean

echo "Building for Mac Catalyst"
xcodebuild archive -project ./BarcodeScannerFramework/BarcodeScannerFramework.xcodeproj \
                   -scheme "BarcodeScannerFramework" \
                   -configuration Release \
                   -destination "platform=macOS,variant=Mac Catalyst" \
                   -quiet \
                   SKIP_INSTALL=NO \
                   -archivePath $DIST/intermediates/BarcodeScannerFramework.maccatalyst.xcarchive

# echo "Building for x86_64 iphone simulator"
# xcodebuild archive -project ./BarcodeScannerFramework/BarcodeScannerFramework.xcodeproj \
#                    -scheme "BarcodeScannerFramework" \
#                    -configuration Release \
#                    -arch x86_64 \
#                    -sdk iphonesimulator \
#                    -quiet \
#                    DEVELOPMENT_TEAM=$DEV_TEAM \
#                    SKIP_INSTALL=NO \
#                    -archivePath $DIST/BarcodeScannerFramework.x86_64-iphonesimulator.xcarchive

# echo "Building for ARM64 iphone simulator"
# xcodebuild archive -project ./BarcodeScannerFramework/BarcodeScannerFramework.xcodeproj \
#                    -scheme "BarcodeScannerFramework" \
#                    -configuration Release \
#                    -arch arm64 \
#                    -sdk iphonesimulator \
#                    -quiet \
#                    DEVELOPMENT_TEAM=$DEV_TEAM \
#                    SKIP_INSTALL=NO \
#                    -archivePath $DIST/BarcodeScannerFramework.arm64-iphonesimulator.xcarchive

echo "Building for iphone simulators (multi-arch)"
xcodebuild archive -project ./BarcodeScannerFramework/BarcodeScannerFramework.xcodeproj \
                   -scheme "BarcodeScannerFramework" \
                   -configuration Release \
                   -sdk iphonesimulator \
                   -arch x86_64 \
                   -arch arm64 \
                   -quiet \
                   DEVELOPMENT_TEAM=$DEV_TEAM \
                   SKIP_INSTALL=NO \
                   -archivePath $DIST/intermediates/BarcodeScannerFramework.iphonesimulator.xcarchive

echo "Building for ARM64 device"
xcodebuild archive -project ./BarcodeScannerFramework/BarcodeScannerFramework.xcodeproj \
                   -scheme "BarcodeScannerFramework" \
                   -configuration Release \
                   -arch arm64 \
                   -sdk iphoneos \
                   -quiet \
                   DEVELOPMENT_TEAM=$DEV_TEAM \
                   SKIP_INSTALL=NO \
                   -archivePath $DIST/intermediates/BarcodeScannerFramework.iphoneos.xcarchive

#Create fat library for simulator
# rm -rf "$DIST/BarcodeScannerFramework.iphonesimulator.xcarchive"

# cp -R \
#     "$DIST/BarcodeScannerFramework.x86_64-iphonesimulator.xcarchive" \
#     "$DIST/BarcodeScannerFramework.iphonesimulator.xcarchive"

# rm "$DIST/BarcodeScannerFramework.iphonesimulator.xcarchive/Products/Library/Frameworks/BarcodeScannerFramework.framework/BarcodeScannerFramework"

# lipo -create \
#     "$DIST/BarcodeScannerFramework.x86_64-iphonesimulator.xcarchive/Products/Library/Frameworks/BarcodeScannerFramework.framework/BarcodeScannerFramework" \
#     "$DIST/BarcodeScannerFramework.arm64-iphonesimulator.xcarchive/Products/Library/Frameworks/BarcodeScannerFramework.framework/BarcodeScannerFramework" \
#     -output \
#     "$DIST/BarcodeScannerFramework.iphonesimulator.xcarchive/Products/Library/Frameworks/BarcodeScannerFramework.framework/BarcodeScannerFramework"

echo "Creating BarcodeScannerFramework.xcframework"
OUTPUT_DIR="$DIST/BarcodeScannerFramework.xcframework"
rm -rf $OUTPUT_DIR
xcodebuild -create-xcframework \
           -framework "$DIST/intermediates/BarcodeScannerFramework.maccatalyst.xcarchive/Products/Library/Frameworks/BarcodeScannerFramework.framework" \
           -framework "$DIST/intermediates/BarcodeScannerFramework.iphonesimulator.xcarchive/Products/Library/Frameworks/BarcodeScannerFramework.framework" \
           -debug-symbols "$DIST/intermediates/BarcodeScannerFramework.iphonesimulator.xcarchive/dSYMs/BarcodeScannerFramework.framework.dSYM" \
           -framework "$DIST/intermediates/BarcodeScannerFramework.iphoneos.xcarchive/Products/Library/Frameworks/BarcodeScannerFramework.framework" \
           -debug-symbols "$DIST/intermediates/BarcodeScannerFramework.iphoneos.xcarchive/dSYMs/BarcodeScannerFramework.framework.dSYM" \
           -output "$OUTPUT_DIR"

rm -rf "$DIST/intermediates"
#-debug-symbols "$DIST/intermediates/BarcodeScannerFramework.maccatalyst.xcarchive/dSYMs/BarcodeScannerFramework.framework.dSYM" \
           
# DSYM_OUTPUT_DIR="$DIST/BarcodeScannerFramework.framework.dSYM"
# cp -r "$DIST/BarcodeScannerFramework.iphoneos.xcarchive/dSYMs/BarcodeScannerFramework.framework.dSYM/" $DSYM_OUTPUT_DIR
# lipo -create \
#     "$DIST/BarcodeScannerFramework.iphonesimulator.xcarchive/dSYMs/BarcodeScannerFramework.framework.dSYM/Contents/Resources/DWARF/BarcodeScannerFramework" \
#     "$DIST/BarcodeScannerFramework.iphoneos.xcarchive/dSYMs/BarcodeScannerFramework.framework.dSYM/Contents/Resources/DWARF/BarcodeScannerFramework" \
#     -output "$DSYM_OUTPUT_DIR/Contents/Resources/DWARF/BarcodeScannerFramework"

# pushd $DIST
# zip -qr "BarcodeScannerFramework.framework.dSYM.zip" "BarcodeScannerFramework.framework.dSYM"
# zip -qr "BarcodeScannerFramework.macos.framework.dSYM.zip" "BarcodeScannerFramework.maccatalyst.xcarchive/dSYMs/BarcodeScannerFramework.framework.dSYM"
# rm -rf "BarcodeScannerFramework.framework.dSYM"
# popd

# rm -rf "$DIST/BarcodeScannerFramework.maccatalyst.xcarchive"
# rm -rf "$DIST/BarcodeScannerFramework.x86_64-iphonesimulator.xcarchive"
# rm -rf "$DIST/BarcodeScannerFramework.arm64-iphonesimulator.xcarchive"
# rm -rf "$DIST/BarcodeScannerFramework.iphonesimulator.xcarchive"
# rm -rf "$DIST/BarcodeScannerFramework.iphoneos.xcarchive"