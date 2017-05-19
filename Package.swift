// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "json-swift",
    targets: [
        Target(name: "JSONLib", dependencies: []),
        Target(name: "ParserTestHarness", dependencies: ["JSONLib"]),
        Target(name: "ParserPerfTestHarness", dependencies: ["JSONLib"])
    ],
    dependencies: [
         .Package(url: "https://github.com/bignerdranch/Freddy.git", majorVersion: 3)
    ]
)
