// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Rudder-Facebook",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(
            name: "Rudder-Facebook",
            targets: ["Rudder-Facebook"]
        )
    ],
    dependencies: [
        .package(name: "Facebook", url: "https://github.com/facebook/facebook-ios-sdk", "17.0.2"..<"19.0.0"),
        .package(name: "Rudder", url: "https://github.com/rudderlabs/rudder-sdk-ios", "1.12.0"..<"2.0.0"),
    ],
    targets: [
        .target(
            name: "Rudder-Facebook",
            dependencies: [
                .product(name: "FacebookCore", package: "Facebook"),
                .product(name: "Rudder", package: "Rudder"),
            ],
            path: "Rudder-Facebook",
            sources: ["Classes/"],
            publicHeadersPath: "Classes/",
            cSettings: [
                .headerSearchPath("Classes/")
            ]
        )
    ]
)
