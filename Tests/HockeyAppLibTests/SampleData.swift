//
//  SampleData.swift
//  HockeyAppHooks
//
//  Created by Dave Weston on 3/24/17.
//
//

import Foundation
import SwiftyJSON

struct SampleData {
    static let feedbackJson: [String: Any] = [
        "public_identifier": "c084fd5be5f3c21e41ec25eefe88f838",
        "type": "feedback",
        "feedback": [
            "name": NSNull(),
            "email": "pninae@microsoft.com",
            "id": 769309,
            "created_at": "2017-03-24T17:01:39Z",
            "messages": [
                [
                    "subject": "#rageshake Message header is empty ... This hap...",
                    "text": "#rageshake\n\nMessage header is empty ... \nThis happened in the Bart when the Internet is slow ",
                    "oem": "Apple",
                    "model": "iPhone8,1",
                    "os_version": "9.3.1",
                    "created_at": "2017-03-24T17:01:38Z",
                    "id": 1400847,
                    "token": "1b9e9f7d23e24cceb075edd55abc9d18",
                    "via": 1,
                    "user_string": "1518563278",
                    "internal": NSNull(),
                    "app_id": "c084fd5be5f3c21e41ec25eefe88f838",
                    "app_version_id": 2176,
                    "clean_text": "#rageshake\n\nMessage header is empty ... \nThis happened in the Bart when the Internet is slow",
                    "name": "Pnina",
                    "email": "pninae@microsoft.com",
                    "gravatar_hash": "4a4679bdd5d1b957db603e62fdaf34a8",
                    "attachments": [
                        [
                            "id": 307224,
                            "feedback_message_id": 1400847,
                            "created_at": "2017-03-24T17:01:38Z",
                            "updated_at": "2017-03-24T17:01:44Z",
                            "content_type": "image/jpeg",
                            "file_name": "Image_0.jpg"
                        ],
                        [
                            "id": 307225,
                            "feedback_message_id": 1400847,
                            "created_at": "2017-03-24T17:01:39Z",
                            "updated_at": "2017-03-24T17:01:44Z",
                            "content_type": "text/plain",
                            "file_name": "treatments.txt"
                        ],
                        [
                            "id": 307226,
                            "feedback_message_id": 1400847,
                            "created_at": "2017-03-24T17:01:39Z",
                            "updated_at": "2017-03-24T17:01:44Z",
                            "content_type": "text/plain",
                            "file_name": "breadcrumbs.txt"
                        ],
                        [
                            "id": 307227,
                            "feedback_message_id": 1400847,
                            "created_at": "2017-03-24T17:01:39Z",
                            "updated_at": "2017-03-24T17:01:44Z",
                            "content_type": "text/plain",
                            "file_name": "entityGraph.txt"
                        ]
                    ]
                ]
            ],
            "status": 0
        ],
        "sent_at": "2017-03-24T17:39:48+00:00",
        "title": "New Feedback for Yammer Beta",
        "text": "New Feedback for Yammer Beta - <https://rink.hockeyapp.net/manage/apps/125177/feedback/769309|View on HockeyApp>",
        "url": "https://rink.hockeyapp.net/manage/apps/125177/feedback/769309"
    ]

    static var swiftyJsonSampleData: JSON = {
        let data = try! JSONSerialization.data(withJSONObject: feedbackJson, options: [])
        return JSON(data: data)
    }()
}
