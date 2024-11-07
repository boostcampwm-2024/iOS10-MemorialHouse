import PackageDescription

let package = Package(
    name: "MemorialHouse",
    products: [
        .library(name: "MHDomain", targets: ["MHDomain"]),
        .library(name: "MHCore", targets: ["MHCore"]),
        .library(name: "MHData", targets: ["MHData"]),
        .library(name: "MHFoundation", targets: ["MHFoundation"]),
        .library(name: "MHPresentation", targets: ["MHPresentation"]),
        .library(name: "MHApplication", targets: ["MHApplication"]),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLintPlugins", from: "0.57.0"),
    ],
    targets: [
        .target(
            name: "MHDomain",
            dependencies: [
                .product(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .target(
            name: "MHCore",
            dependencies: [
                .product(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .target(
            name: "MHData",
            dependencies: [
                .product(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .target(
            name: "MHFoundation",
            dependencies: [
                .product(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .target(
            name: "MHPresentation",
            dependencies: [
                .product(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .target(
            name: "MHApplication",
            dependencies: [
                .product(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins") // 플러그인 활성화
            ]
        ),
    ],
    swiftLanguageVersions: [.v6]
)

