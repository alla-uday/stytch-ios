// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Stytch",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "Stytch",
            targets: ["Stytch"]),
    ],
    targets: [
        .target(
            name: "Stytch",
            path: "Stytch",
            publicHeadersPath: "."
        ),
    ]
)
