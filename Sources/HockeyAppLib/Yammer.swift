import KituraRequest
import SwiftyJSON

public struct MessagePostRequest {
    var message: String
    var groupID: Int
}

public class Yammer
{
    let token: String

    public init(token: String) {
        self.token = token
    }

    func post(path: String, params: [String: Any], completion: ((JSON?, Error?) -> Void)?) {
        let bearer = "Bearer \(token)"
        KituraRequest.request(.post,
                              "https://www.yammer.com\(path)",
                              parameters: params,
                              encoding: JSONEncoding.default,
                              headers: ["Authorization": bearer, "Accept": "application/json"]).response {
            request, response, data, error in
            if let data = data {
                let json = JSON(data: data)
                completion?(json, error)
            } else {
                completion?(nil, error)
            }
        }
    }

    public func postMessage(_ request: MessagePostRequest, completion: ((JSON?, Error?) -> Void)? = nil) {
        post(path: "/api/v1/messages", params: ["body": request.message, "group_id": request.groupID], completion: completion)
    }
}
