//
//  HookHandlerTests.swift
//  HockeyAppHooks
//
//  Created by Dave Weston on 3/24/17.
//
//

import XCTest
@testable import HockeyAppLib

class HookHandlerTests: XCTestCase {
    var message: Message!

	static var allTests: [(String, (HookHandlerTests) -> () throws -> Void)] {
		return [
			("testYammerMentioning", testYammerMentioning),
			("testYammerMentioningNoName", testYammerMentioningNoName),
			("testNoYammerMentioning", testNoYammerMentioning),
			("testNoYammerMentioningNoEmail", testNoYammerMentioningNoEmail),
			("testNoYammerMentioningNoName", testNoYammerMentioningNoName),
			("testNoYammerNoNothing", testNoYammerNoNothing),
		]
	}

    public override func setUp() {
        let parser = WebhookParser()
        let parsedFeedback = parser.parse(SampleData.swiftyJsonSampleData)
        switch parsedFeedback {
        case .feedback(let feedbackInfo):
            if let msg = feedbackInfo.feedback.messages.first {
                message = msg
            }
        default:
            XCTFail("Unable to parse as feedback")
        }
    }

    func testYammerMentioning() {
        XCTAssertEqual(message.userInfo, "[[user:1518563278]] (Pnina)")
    }

    func testYammerMentioningNoName() {
        message.name = ""
        XCTAssertEqual(message.userInfo, "[[user:1518563278]]")
    }

    func testNoYammerMentioning() {
        message.userString = ""
        XCTAssertEqual(message.userInfo, "Pnina (pninae@microsoft.com)")
    }

    func testNoYammerMentioningNoEmail() {
        message.userString = ""
        message.email = ""
        XCTAssertEqual(message.userInfo, "Pnina")
    }

    func testNoYammerMentioningNoName() {
        message.userString = ""
        message.name = ""
        XCTAssertEqual(message.userInfo, "pninae@microsoft.com")
    }

    func testNoYammerNoNothing() {
        message.userString = ""
        message.name = ""
        message.email = ""
        XCTAssertEqual(message.userInfo, "Yammer User")
    }
}
