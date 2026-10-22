// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MercurySDK",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "MercurySDK", targets: ["MercurySDK", "MercurySDKLinker"])
    ],
    targets: [
        .binaryTarget(
            name: "MercurySDK",
            path: "MercurySDK/MercurySDK.xcframework"
        ),
        .target(
            name: "MercurySDKLinker",
            dependencies: ["MercurySDK"],
            path: "Sources/MercurySDKLinker",
            linkerSettings: [
                .linkedFramework("StoreKit"),
                .linkedFramework("CoreTelephony"),
                .linkedFramework("AdSupport"),
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("AVFoundation")
            ]
        )
    ]
)
