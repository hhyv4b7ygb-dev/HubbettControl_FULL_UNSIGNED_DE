// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "HubbettControl",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(name: "HubbettControl", targets: ["HubbettControl"])
    ],
    targets: [
        .executableTarget(
            name: "HubbettControl",
            path: "HubbettControl"
        )
    ]
)
