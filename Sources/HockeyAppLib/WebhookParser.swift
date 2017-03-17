import SwiftyJSON
import Foundation

struct PingInfo {
    var id: String
    var title: String
    var url: URL
}

public struct Attachment {
    var id: Int
    var contentType: String
    var fileName: String
}

public struct Message {
    var id: Int
    var subject: String
    var text: String
    var cleanText: String
    var oem: String
    var model: String
    var osVersion: String
    var appId: String
    var appVersionId: Int
    var name: String
    var email: String
    var attachments: [Attachment]
}

public struct Feedback {
    public enum Status {
        case unknown, open, waiting, closed
        init(_ statusInt: Int) {
            switch statusInt {
            case 0: self = .open
            default: self = .unknown
            }
        }
    }
    var name: String
    var email: String
    var id: Int
    var messages: [Message]
    var status: Status
}

public struct FeedbackInfo {
    var id: String
    var title: String
    var url: URL
    var feedback: Feedback
}

public enum WebhookInfo {
    case unparsed(String, JSON)
    case failed(String, JSON)
    case feedback(FeedbackInfo)
}

public class WebhookParser {
    public init() {}
    
    public func parse(_ json: JSON) -> WebhookInfo {
        let type = json["type"].stringValue
        switch type {
        case "feedback":
            if let fi = parseFeedbackInfo(json) {
                return .feedback(fi)
            }
        default:
            return .unparsed(type, json)
        }

        return .failed(type, json)
    }

    func parseAttachment(_ json: JSON) -> Attachment? {
        if let id = json["id"].int,
            let contentType = json["content_type"].string,
            let fileName = json["file_name"].string {

            return Attachment(id: id, contentType: contentType, fileName: fileName)
        }

        print("Invalid attachment JSON: \(String(describing: json))")
        return nil
    }

    func parseMessage(_ json: JSON) -> Message? {
        if let id = json["id"].int,
            let subject = json["subject"].string,
            let appId = json["app_id"].string,
            let appVersionId = json["app_version_id"].int {

            let text = json["text"].string ?? ""
            let cleanText = json["clean_text"].string ?? ""

            let oem = json["oem"].string ?? ""
            let model = json["model"].string ?? ""
            let osVersion = json["os_version"].string ?? ""

            let name = json["name"].string ?? ""
            let email = json["email"].string ?? ""

            var attachments = [Attachment]()
            for (_,attachmentJson):(String, JSON) in json["attachments"] {
                if let attachment = parseAttachment(attachmentJson) {
                    attachments.append(attachment)
                }
            }

            return Message(id: id, subject: subject, text: text, cleanText: cleanText, oem: oem, model: model, osVersion: osVersion, appId: appId, appVersionId: appVersionId, name: name, email: email, attachments: attachments)
        }

        print("Invalid message JSON: \(String(describing: json))")
        return nil
    }

    func parseFeedback(_ json: JSON) -> Feedback? {
        if let id = json["id"].int {

            let name = json["name"].string ?? ""
            let email = json["email"].string ?? ""
            let statusInt = json["status"].int ?? 0

            var messages = [Message]()
            for (_, messageJson):(String,JSON) in json["messages"] {
                if let message = parseMessage(messageJson) {
                    messages.append(message)
                }
            }

            let status = Feedback.Status(statusInt)

            return Feedback(name: name, email: email, id: id, messages: messages, status: status)
        }

        print("Invalid feedback JSON: \(String(describing: json))")
        return nil
    }

    func parseFeedbackInfo(_ json: JSON) -> FeedbackInfo? {
        if let id = json["public_identifier"].string,
            let title = json["title"].string,
            let urlString = json["url"].string,
            let url = URL(string: urlString) {
            
            if let feedback = parseFeedback(json["feedback"]) {
                return FeedbackInfo(id: id, title: title, url: url, feedback: feedback)
            }
        }

        print("Invalid feedback info JSON: \(String(describing: json))")
        return nil
    }
}
