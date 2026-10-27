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
            path: "Sources/EzsignEkycSDK",
            resources: [
                .process("../../Resources")
            ]
        ),
        .binaryTarget(
            name: "MegLiveV5Detect",
            path: "Frameworks/MegLiveV5Detect.framework"
        ),
        .binaryTarget(
            name: "MGFaceIDBaseKit",
            path: "Frameworks/MGFaceIDBaseKit.framework"
        )
    ]
)
