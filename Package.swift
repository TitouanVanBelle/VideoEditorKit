// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VideoEditorKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "VideoEditorKit",
            targets: ["VideoEditorKit"]),
    ],
    dependencies: [
        .package(name: "VideoPlayer", url: "https://github.com/gymbro/videoplayer", .branch("master")),
        .package(name: "VideoEditor", url: "https://github.com/gymbro/videoeditor", .branch("master")),
        .package(url: "https://github.com/PureLayout/PureLayout", .upToNextMajor(from: "3.1.6")),
        .package(url: "https://github.com/sergdort/CombineFeedback", .branch("master"))
    ],
    targets: [
        .target(
            name: "VideoEditorKit",
            dependencies: [
                "VideoPlayer",
                "VideoEditor",
                "PureLayout",
                .product(name: "CombineFeedback", package: "CombineFeedback"),
                .product(name: "CombineFeedbackUI", package: "CombineFeedback")
            ],
            resources: [.process("Resources")])
    ]
)
