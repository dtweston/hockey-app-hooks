import KituraRequest
import SwiftyJSON

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
            let deviceFamily = json["device_family"].string,
            let minimumOsVersion = json["minimum_os_version"].string,
            let releaseType = json["release_type"].int,
            let status = json["status"].int,
            let platform = json["platform"].string {

            return HockeyApp(title: title, bundleIdentifier: bundleId, publicIdentifier: publicId, deviceFamily: deviceFamily, minimumOsVersion: minimumOsVersion, releaseType: HockeyApp.ReleaseType(releaseType), status: HockeyApp.DownloadStatus(status), platform: HockeyApp.Platform(platform))
        }

        print("Unable to parse app json: \(String(describing: json))")
        return nil
    }

    func parseAppVersion(_ json: JSON) -> AppVersion? {
        if let version = json["version"].string,
            let id = json["id"].int,
            let mandatory = json["mandatory"].bool,
            let status = json["status"].int,
            let shortVersion = json["shortversion"].string,
            let title = json["title"].string {

            return AppVersion(id: id, version: version, mandatory: mandatory, status: HockeyApp.DownloadStatus(status), shortVersion: shortVersion, title: title)
        }

        print("Unable to parse app version json: \(String(describing: json))")
        return nil
    }
}

public class HockeyApi {
    let token: String
    let parser = HockeyParser()

    public init(token: String) {
        self.token = token
    }

    func get(path: String, completion: ((JSON?, Error?) -> Void)? = nil) {
        KituraRequest.request(.get, "https://rink.hockeyapp.net\(path)", headers: ["X-HockeyAppToken": token]).response {
            request, response, data, error in
            if let data = data {
                let json = JSON(data: data)
                completion?(json, error)
            } else {
                completion?(nil, error)
            }
        }
    }

    public func fetchApps(completion: (([HockeyApp]?, Error?) -> Void)? = nil) {
        get(path: "/api/2/apps") { json, error in
            if let json = json {
                var apps = [HockeyApp]()
                for (_, appJson):(String, JSON) in json["apps"] {
                    if let app = self.parser.parseApp(appJson) {
                        apps.append(app)
                    }
                }

                completion?(apps, error)
            }

            completion?(nil, error)
        }
    }

    public func fetchAppVersions(appId: String, completion: (([AppVersion]?, Error?) -> Void)? = nil) {
        get(path: "/api/2/apps/\(appId)/app_versions") { json, error in
            if let json = json {
                var versions = [AppVersion]()
                for (_, versionJson):(String, JSON) in json["app_versions"] {
                    if let version = self.parser.parseAppVersion(versionJson) {
                        versions.append(version)
                    }
                }

                completion?(versions, error)
            }

            completion?(nil, error)
        }
    }
}
