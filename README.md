A BarcodeScanner framework for iOS apps.

I'm using this wrapper framework so I could use the built-in scanning capabilities of iOS
within my [NativeScript BarcodeScanner plugin](https://www.npmjs.com/package/nativescript-barcodescanner).

### Note to self: building the framework
- Open terminal and then
cd BarcodeScannerFramework
# https://developer.apple.com/forums/thread/666335
rm -rf ./archives
# archive iPhone 64
xcodebuild archive -scheme BarcodeScannerFramework -arch arm64 -configuration Release SKIP_INSTALL=NO -sdk "iphoneos" BUILD_LIBRARY_FOR_DISTRIBUTION=YES -archivePath ./archives/ios.xcarchive 
# archive simulator arm64 M1
xcodebuild archive -scheme BarcodeScannerFramework -arch arm64 -configuration Release SKIP_INSTALL=NO -sdk iphonesimulator BUILD_LIBRARY_FOR_DISTRIBUTION=YES -archivePath ./archives/sim64.xcarchive
# archive simulator x86_64
xcodebuild archive -scheme BarcodeScannerFramework -arch x86_64 -configuration Release SKIP_INSTALL=NO -sdk iphonesimulator BUILD_LIBRARY_FOR_DISTRIBUTION=YES -archivePath ./archives/simx86.xcarchive
    
# create xcframework for iOS and iOS Simulator
xcodebuild -create-xcframework \
-framework "./archives/ios.xcarchive/Products/Library/Frameworks/BarcodeScannerFramework.framework" \
-framework "./archives/sim64.xcarchive/Products/Library/Frameworks/BarcodeScannerFramework.framework" \
-output "./archives/BarcodeScannerFramework.xcframework"

# add the x86 slice to the iOS simulator
lipo -create \
"./archives/BarcodeScannerFramework.xcframework/ios-arm64-simulator/BarcodeScannerFramework.framework/BarcodeScannerFramework" \ 
"./archives/simx86.xcarchive/Products/Library/Frameworks/BarcodeScannerFramework.framework/BarcodeScannerFramework"  \
-output "./archives/BarcodeScannerFramework.xcframework/ios-arm64-simulator/BarcodeScannerFramework.framework/BarcodeScannerFramework"

# check that the resulting Simulator has both slices (arm64 and x86_64)
lipo -detailed_info "./archives/BarcodeScannerFramework.xcframework/ios-arm64-simulator/BarcodeScannerFramework.framework/BarcodeScannerFramework"

# add the architecture to remove warnings
- open ./archives/BarcodeScannerFramework.xcframework/ios-arm64-simulator/BarcodeScannerFramework.framework/Info.plist and find SupportedArchitectures in ios-arm64-simulator library. Add <string>x86_64</string> after <string>arm64</string>.
- Do not add this ot the ios-arm64 library

Use resulting ./archives/BarcodeScannerFramework.xcframework as your framework.