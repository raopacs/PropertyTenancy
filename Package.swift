// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PropertyTenancy",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // The library product that contains the app's core logic and UI.
        .library(
            name: "PropertyTenancyKit",
            targets: ["PropertyTenancyKit"]),
    ],
    dependencies: [
        // Add external package dependencies here.
    ],
    targets: [
        // The main library target for the app's features.
        .target(
            name: "PropertyTenancyKit",
            dependencies: [],
            path: "PropertyTenancy",
            // Exclude the app's entry point and configuration files from the library.
            exclude: ["PropertyTenancyApp.swift", "Info.plist"],
            linkerSettings: [
                .linkedFramework("sqlite3")
            ]),
        .testTarget(
            name: "PropertyTenancyTests",
            dependencies: ["PropertyTenancyKit"],
            path: "PropertyTenancyTests"),
    ]
)