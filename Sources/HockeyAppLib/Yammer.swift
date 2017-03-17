import KituraNet
import KituraRequest
import SwiftyJSON
import Foundation
import LoggerAPI

public struct MessagePostRequest {
    var message: String
    var groupID: Int
    var pendingAttachmentID: Int?
}

extension HTTPStatusCode {
    var isSuccess: Bool {
        return self.rawValue >= 200 && self.rawValue <= 299
    }
}

public enum NetworkError: Swift.Error {
    case missingResponse
    case missingResponseBody
    case serverError(HTTPStatusCode)
}

public class Yammer
{

    let token: String

    public init(token: String) {
        self.token = token
    }

    func post(path: String, params: [String: Any], completion: ((JSON?, Swift.Error?) -> Void)?) {
        let bearer = "Bearer \(token)"
        KituraRequest.request(.post,
                              "https://www.yammer.com\(path)",
                              parameters: params,
                              encoding: JSONEncoding.default,
                              headers: ["Authorization": bearer, "Accept": "application/json"]).response {
            request, response, data, error in
                                guard error == nil else {
                                    completion?(nil, error)
                                    return
                                }

                                guard let response = response else {
                                    completion?(nil, NetworkError.missingResponse)
                                    return
                                }

                                guard response.httpStatusCode.isSuccess else {
                                    completion?(nil, NetworkError.serverError(response.httpStatusCode))
                                    return
                                }

                                guard let data = data else {
                                    completion?(nil, NetworkError.missingResponseBody)
                                    return
                                }

                                let json = JSON(data: data)
                                completion?(json, nil)
        }
    }

    public func postMessage(_ request: MessagePostRequest, completion: ((JSON?, Swift.Error?) -> Void)? = nil) {
        Log.info("Posting message to group \(request.groupID)")
        var params: [String: Any] = ["body": request.message, "group_id": request.groupID]
        if let pendingAttachmentId = request.pendingAttachmentID {
            params["pending_attachment1"] = pendingAttachmentId
        }
        post(path: "/api/v1/messages", params: params, completion: completion)
    }

    private func upload(encoding: MultipartEncoding, toPath path: String, completion: @escaping ((JSON?, Swift.Error?) -> Void)) {
        let bearer = "Bearer \(token)"
        KituraRequest.request(.post,
                              "https://www.yammer.com\(path)",
            encoding: encoding,
            headers: ["Authorization": bearer, "Accept": "application/json"]).response {
                request, response, data, error in
                if let data = data {
                    let json = JSON(data: data)
                    completion(json, error)
                } else {
                    completion(nil, error)
                }
        }
    }

    public func uploadScreenshot(data: Data, groupId: Int, completion: @escaping ((JSON?, Swift.Error?) -> Void)) {
        var bodyParts = [BodyPart]()
        bodyParts.append(BodyPart(key: "attachment", data: data, mimeType: .image(.jpeg), fileName: "screenshot.jpg"))
        bodyParts.append(BodyPart(key: "group_id", value: "\(groupId)")!)
        let encoding = MultipartEncoding(bodyParts)

        Log.info("Uploading attachment to group \(groupId)")
        upload(encoding: encoding, toPath: "/api/v1/pending_attachments", completion: completion)
    }
}
