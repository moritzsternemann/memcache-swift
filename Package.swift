// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "memcache-swift",
    platforms: [ // for Foundation.Scanner
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "Memcache", targets: ["Memcache"]),
        .executable(name: "memcache-swift-example", targets: ["memcache-swift-example"])
    ],
    dependencies: [
         .package(url: "https://github.com/apple/swift-nio.git", from: "2.40.0")
    ],
    targets: [
        .target(
            name: "Memcache",
            dependencies: [
                .product(name: "NIO", package: "swift-nio")
            ]
        ),
        .testTarget(
            name: "MemcacheTests",
            dependencies: [
                .target(name: "Memcache")
            ]
        ),

        .executableTarget(
            name: "memcache-swift-example",
            dependencies: [
                .target(name: "Memcache")
            ]
        )
    ]
)
