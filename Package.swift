import PackageDescription

let package = Package(
	name: "HockeyAppHooks",
	targets: [],
	dependencies: [
		.Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 2)
    ]
)
