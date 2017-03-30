import XCTest
import SwiftyJSON
@testable import HockeyAppLib

class WebhookParserTests: XCTestCase {
	static var allTests: [(String, (WebhookParserTests) -> () throws -> Void)] {
		return [
			("testParseFeedback", testParseFeedback)
		]
	}

    func testParseFeedback() {
	    let parser = WebhookParser()
        let parsedFeedback = parser.parse(SampleData.swiftyJsonSampleData)
        switch parsedFeedback {
        case .feedback(let feedbackInfo):
            if let msg = feedbackInfo.feedback.messages.first {
                XCTAssertEqual(msg.userString, "1518563278", "Unable to parse user string from first message")
            }
        default:
            XCTFail("Unable to parse as feedback")
        }
    }
}
