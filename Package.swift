// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "EzsignEkycSDK",
    defaultLocalization: "en",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "EzsignEkycSDK", targets: ["EzsignEkycSDK"]),
    ],
    targets: [
        .target(
            name: "EzsignEkycSDK",
            dependencies: [
                "MegLiveV5Detect",
                "MGFaceIDBaseKit"
            ],
            path: ".",
            exclude: ["Example", "Frameworks", "README.md", "LICENSE", "EzsignEkycSDK.podspec"],
            sources: ["Sources/EzsignEkycSDK"],
            resources: [
                .process("Resources/identity.png"),
                .process("Resources/pre_active_liveness.png"),
                .process("Resources/InterVariable.ttf"),
                .process("Resources/EkycAssets.xcassets"),
                .copy("Resources/MegLiveV5Detect.bundle")
            ],
            // System libraries required by MegLiveV5Detect (Megvii FaceID SDK integration guide 2.2.4).
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("CoreMotion"),
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("WebKit"),
                .linkedFramework("MediaPlayer"),
                .linkedFramework("ReplayKit"),
                .linkedLibrary("c++")
            ]
        ),
        .binaryTarget(
            name: "MegLiveV5Detect",
            path: "Frameworks/MegLiveV5Detect.xcframework"
        ),
        .binaryTarget(
            name: "MGFaceIDBaseKit",
            path: "Frameworks/MGFaceIDBaseKit.xcframework"
        )
    ]
)
