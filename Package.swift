// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "memcache-swift",
    products: [
        .library(name: "Memcache", targets: ["Memcache"]),
        .executable(name: "memcache-swift-example", targets: ["memcache-swift-example"])
    ],
    dependencies: [
         .package(url: "https://github.com/apple/swift-nio.git", from: "2.40.0"),
         .package(url: "https://github.com/swift-extras/swift-extras-base64.git", from: "0.7.0")
    ],
    targets: [
        .target(
            name: "Memcache",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "ExtrasBase64", package: "swift-extras-base64")
            ]
        ),
        .testTarget(
            name: "MemcacheTests",
            dependencies: [
                .target(name: "Memcache"),
                .product(name: "NIOTestUtils", package: "swift-nio")
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
