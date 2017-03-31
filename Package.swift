import PackageDescription

let package = Package(
	name: "HockeyAppHooks",
    targets: [
        Target(name: "HockeyAppLib"),
        Target(name: "HockeyAppApp", dependencies: ["HockeyAppLib"])
    ],
	dependencies: [
		.Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 6),
		.Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 6),
		.Package(url: "https://github.com/IBM-Swift/Kitura-Request.git", majorVersion: 0),
		.Package(url: "https://github.com/SwiftOnTheServer/SwiftDotEnv.git", majorVersion: 0)
    ]
)
