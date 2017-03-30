//
//  HockeyHandler.swift
//  HockeyAppHooks
//
//  Created by Dave Weston on 3/17/17.
//
//

import Foundation
import SwiftyJSON
import LoggerAPI
import Dispatch

extension Message {
    var userInfo: String {
        if !userString.isEmpty {
            if let userID = Int(userString) {
                var userStr = "[[user:\(userID)]]"
                if !name.isEmpty {
                    userStr += " (\(name))"
                }

                return userStr
            }
        }

        if name.isEmpty && email.isEmpty {
            return "Yammer User"
        } else if email.isEmpty {
            return name
        } else if name.isEmpty {
            return email
        } else {
            return "\(name) (\(email))"
        }
    }
    var feedbackMessage: String {
        if text.isEmpty {
            return "\(userInfo) said:\nNothing of substance\n"
        } else {
            return "\(userInfo) said:\n\(text)\n"
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
    private let groupId: Int
    private let hookParser: WebhookParser

    public init(hockey: HockeyFacade, yammer: Yammer, groupId: Int) {
        self.hockey = hockey
        self.yammer = yammer
        self.groupId = groupId
        self.hookParser = WebhookParser()
    }

    public func process(json: JSON) {
        let info = hookParser.parse(json)
        switch info {
        case .feedback(let fi):
            Log.info("Received new feedback via webhook")
            handle(feedbackInfo: fi)
        case .failed(let type, _), .unparsed(let type, _):
            Log.warning("Unknown webhook type (\(type)) received")
        }
    }

    private func handle(feedbackInfo: FeedbackInfo) {
        let feedback = feedbackInfo.feedback
        if let message = feedback.messages.first {

            let feedbackMessage = message.feedbackMessage
            let version = message.versionInfo
            let more = feedbackInfo.moreInfo

            var pendingAttachmentID: Int? = nil

            let group = DispatchGroup()
            Log.debug("Checking for image attachments")
            if let screenshot = message.attachments.first(where: { $0.contentType.hasPrefix("image/") }) {

                group.enter()
                Log.info("Fetching attachment")
                hockey.fetchAttachment(appId: message.appId, feedbackId: feedbackInfo.feedback.id, attachmentId: screenshot.id, completion: { data, error in

                    if let error = error {
                        Log.error("Unable to fetch screenshot: \(error)")
                    } else if let data = data {
                        group.enter()
                        self.yammer.uploadScreenshot(data: data, groupId: self.groupId) { json, error in
                            if let id = json?["id"].int {
                                Log.debug("Received pending attachment id: \(id)")
                                pendingAttachmentID = id
                            }
                            else {
                                Log.error("Error uploading sreenshot: \(String(describing: error))")
                            }

                            group.leave()
                        }
                    }

                    group.leave()
                })
            }

            var appInfo = ""
            group.enter()
            Log.info("Fetching app version \(message.appId)/\(message.appVersionId)")
            hockey.appVersion(appId: message.appId, versionId: message.appVersionId) { appVersion in

                appInfo = {
                    if let appVersion = appVersion {
                        return "App: \(appVersion.title) \(appVersion.version)\n"
                    } else {
                        return "No app version info available\n"
                    }
                }()

                group.leave()
            }

            group.notify(queue: DispatchQueue.global()) {
                let messageText = "\(feedbackMessage)\n\(appInfo)\(version)\n\(more)"

                self.yammer.postMessage(MessagePostRequest(message: messageText, groupID: self.groupId, pendingAttachmentID: pendingAttachmentID))
            }
        }
    }
}
