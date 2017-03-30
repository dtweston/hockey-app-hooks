import KituraRequest
import SwiftyJSON
import Dispatch
import Foundation
import LoggerAPI

public struct HockeyApp {
    public enum ReleaseType {
        case unknown(Int), beta, store, alpha, enterprise
        init(_ type: Int) {
            switch type {
            case 0: self = .beta
            case 1: self = .store
            case 2: self = .alpha
            case 3: self = .enterprise
            default: self = .unknown(type)
            }
        }
    }
    public enum DownloadStatus {
        case unknown(Int), available, unavailable
        init(_ status: Int) {
            switch status {
            case 1: self = .unavailable
            case 2: self = .available
            default: self = .unknown(status)
            }
        }
    }
    public enum Platform {
        case unknown(String), iOS, android, macOS, windowsPhone, custom
        init(_ platform: String) {
            switch platform {
            case "iOS": self = .iOS
            case "Android": self = .android
            case "Mac OS": self = .macOS
            case "Windows Phone": self = .windowsPhone
            case "Custom": self = .custom
            default: self = .unknown(platform)
            }
        }
    }
    public var title: String
    public var bundleIdentifier: String
    public var publicIdentifier: String
    public var deviceFamily: String
    public var minimumOsVersion: String
    public var releaseType: ReleaseType
    public var status: DownloadStatus
    public var platform: Platform
}

public struct AppVersion {
    public var id: Int
    public var version: String
    public var mandatory: Bool
    public var status: HockeyApp.DownloadStatus
    public var shortVersion: String
    public var title: String
}

public class HockeyParser {
    func parseApp(_ json: JSON) -> HockeyApp? {
        if let title = json["title"].string,
            let bundleId = json["bundle_identifier"].string,
            let publicId = json["public_identifier"].string,
            let releaseType = json["release_type"].int,
            let platform = json["platform"].string {

            let deviceFamily = json["device_family"].string ?? ""
            let minimumOsVersion = json["minimum_os_version"].string ?? ""
            let status = json["status"].int ?? 0

            return HockeyApp(title: title, bundleIdentifier: bundleId, publicIdentifier: publicId, deviceFamily: deviceFamily, minimumOsVersion: minimumOsVersion, releaseType: HockeyApp.ReleaseType(releaseType), status: HockeyApp.DownloadStatus(status), platform: HockeyApp.Platform(platform))
        }

        Log.error("Unable to parse app json: \(String(describing: json))")
        return nil
    }

    func parseAppVersion(_ json: JSON) -> AppVersion? {
        if let version = json["version"].string,
            let id = json["id"].int,
            let mandatory = json["mandatory"].bool,
            let shortVersion = json["shortversion"].string,
            let title = json["title"].string {

            let status = json["status"].int ?? 0

            return AppVersion(id: id, version: version, mandatory: mandatory, status: HockeyApp.DownloadStatus(status), shortVersion: shortVersion, title: title)
        }

        Log.error("Unable to parse app version json: \(String(describing: json))")
        return nil
    }
}

public class HockeyApi {
    let token: String
    let parser = HockeyParser()
    let asyncQueue = DispatchQueue(label: "com.yammer.hockey.api")

    public init(token: String) {
        self.token = token
    }

    func get(path: String, completion: ((JSON?, Error?) -> Void)? = nil) {
        let token = self.token
        asyncQueue.async {
            let url = "https://rink.hockeyapp.net\(path)"
            Log.debug("GET \(url)")
            KituraRequest.request(.get, url, headers: ["X-HockeyAppToken": token, "Accept": "application/json"]).response {
                request, response, data, error in
                if let error = error {
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
    }

    func getRaw(path: String, completion: ((Data?, Error?) -> Void)? = nil) {
        let token = self.token
        asyncQueue.async {
            let url = "https://rink.hockeyapp.net\(path)"
            Log.debug("GET \(url)")
            KituraRequest.request(.get, url, headers: ["X-HockeyAppToken": token]).response {
                request, response, data, error in

                completion?(data, error)
            }
        }
    }

    public func fetchApps(completion: (([HockeyApp]?, Error?) -> Void)? = nil) {
        Log.info("Fetching all registered apps")
        get(path: "/api/2/apps") { json, error in
            if let json = json {
                var apps = [HockeyApp]()
                for (_, appJson):(String, JSON) in json["apps"] {
                    if let app = self.parser.parseApp(appJson) {
                        apps.append(app)
                    }
                }

                completion?(apps, error)
                return
            }

            completion?(nil, error)
        }
    }

    public func fetchAppVersions(appId: String, completion: (([AppVersion]?, Error?) -> Void)? = nil) {
        Log.info("Fetching app versions for \(appId)")
        get(path: "/api/2/apps/\(appId)/app_versions") { json, error in
            if let json = json {
                var versions = [AppVersion]()
                for (_, versionJson):(String, JSON) in json["app_versions"] {
                    if let version = self.parser.parseAppVersion(versionJson) {
                        versions.append(version)
                    }
                }

                completion?(versions, error)
                return
            }

            completion?(nil, error)
        }
    }

    public func fetchAppVersion(appId: String, versionId: Int, completion: (([AppVersion]?, Error?) -> Void)? = nil) {
        Log.info("Fetching app version \(appId)/\(versionId)")
        get(path: "/api/2/apps/\(appId)/app_versions/\(versionId)") { json, error in
            if let json = json {
                var versions = [AppVersion]()
                for (_, versionJson):(String, JSON) in json {
                    if let version = self.parser.parseAppVersion(versionJson) {
                        versions.append(version)
                    }
                }

                completion?(versions, error)
                return
            }

            completion?(nil, error)
        }
    }

    public func fetchAttachment(appId: String, feedbackId: Int, attachmentId: Int, completion: @escaping (Data?, Error?) -> Void) {
        Log.info("Fetching feedback attachment: \(appId)/\(feedbackId)/\(attachmentId)")
        let path = "/api/2/apps/\(appId)/feedback/\(feedbackId)/feedback_attachments/\(attachmentId)"
        getRaw(path: path, completion: completion)
    }
}

public class HockeyFacade {
    private var versionStore = [String: [Int: AppVersion]]()
    private var readWriteQueue = DispatchQueue(label: "com.yammer.hockey.facade", attributes: .concurrent)
    private var completionQueue = DispatchQueue(label: "com.yammer.hockey.facade.complete")
    private let api: HockeyApi

    public init(api: HockeyApi) {
        self.api = api
    }

    public func fetchAttachment(appId: String, feedbackId: Int, attachmentId: Int, completion: @escaping (Data?, Error?) -> Void) {

        api.fetchAttachment(appId: appId, feedbackId: feedbackId, attachmentId: attachmentId, completion: completion)
    }

    public func appVersion(appId: String, versionId: Int, completion: @escaping (AppVersion?) -> Void) {
        readWriteQueue.async {
            if let version = self.versionStore[appId]?[versionId] {
                Log.debug("Found \(appId)/\(versionId) in cache")
                self.completionQueue.async {
                    completion(version)
                }
                return
            }

            self.api.fetchAppVersions(appId: appId) { versions, error in
                guard let versions = versions else {
                    Log.error("Unable to fetch app versions: \(String(describing: error))")
                    self.completionQueue.async {
                        completion(nil)
                    }
                    return
                }

                self.readWriteQueue.async(flags: .barrier) {
                    Log.info("Adding \(versions.count) app versions to cache")
                    var appStore = self.versionStore[appId] ?? [Int: AppVersion]()
                    for version in versions {
                        appStore[version.id] = version
                    }

                    self.versionStore[appId] = appStore
                    self.completionQueue.async {
                        completion(self.versionStore[appId]?[versionId])
                    }
                }
            }
        }

    }
}
