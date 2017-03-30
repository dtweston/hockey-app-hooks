import XCTest
@testable import HockeyAppLibTests

XCTMain([
	testCase(HookHandlerTests.allTests),
	testCase(WebhookParserTests.allTests)
])

