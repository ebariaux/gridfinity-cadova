// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "gridfinity-cadova",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "Gridfinity", targets: ["Gridfinity"]),
        .executable(name: "generator", targets: ["generator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tomasf/Cadova.git", .upToNextMinor(from: "0.9.2")),
        .package(url: "https://github.com/tomasf/Helical.git", from: "1.0.4"),
    ],
    targets: [
        .target(
            name: "Gridfinity",
            dependencies: ["Cadova", "Helical"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .executableTarget(
            name: "generator",
            dependencies: ["Gridfinity"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ]
)
