//
//  HockeyHandler.swift
//  HockeyAppHooks
//
//  Created by Dave Weston on 3/17/17.
//
//

import Foundation
import SwiftyJSON

extension Message {
    var feedbackInfo: String {
        if text.isEmpty {
            return "No feedback provided\n"
        } else {
            return "\(text)\n"
        }
    }
    var versionInfo: String {
        var info = ""
        if !oem.isEmpty {
            info += "OEM: \(oem)\n"
        }
        if !model.isEmpty {
            info += "Model: \(model)\n"
        }
        if !osVersion.isEmpty {
            info += "OS Version: \(osVersion)\n"
        }

        return info.isEmpty ? "No device info available\n" : info
    }
}

extension FeedbackInfo {
    var moreInfo: String {
        return "For more info, see: \(url)\n"
    }
}

public class HookHandler {
    private let hockey: HockeyFacade
    private let yammer: Yammer
    private let hookParser: WebhookParser

    public init(hockey: HockeyFacade, yammer: Yammer) {
        self.hockey = hockey
        self.yammer = yammer
        self.hookParser = WebhookParser()
    }

    public func process(json: JSON) {
        let info = hookParser.parse(json)
        switch info {
        case .feedback(let fi):
            handle(feedbackInfo: fi)
        case .failed(let type, _), .unparsed(let type, _):
            print("Unknown webhook type (\(type)) received")
        }
    }

    private func handle(feedbackInfo: FeedbackInfo) {
        let feedback = feedbackInfo.feedback
        if let message = feedback.messages.first {

            let feedback = message.feedbackInfo
            let version = message.versionInfo
            let more = feedbackInfo.moreInfo

            hockey.appVersion(appId: message.appId, versionId: message.appVersionId) { appVersion in

                let appInfo: String = {
                    if let appVersion = appVersion {
                        return "App: \(appVersion.title) \(appVersion.version)\n"
                    } else {
                        return "No app version info available\n"
                    }
                }()

                let messageText = "\(feedback)\n\(appInfo)\(version)\n\(more)"
                self.yammer.postMessage(MessagePostRequest(message: messageText, groupID: 9962571))
            }
        }
    }
}
