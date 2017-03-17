import Foundation
import Kitura
import HockeyAppLib
import SwiftyJSON
import HeliumLogger
import LoggerAPI

let logger = HeliumLogger(.entry)
logger.format = "[(%date)] [(%type)] (%msg) [(%file):(%line) (%func)]"

Log.logger = logger

let configPath = "\(FileManager.default.currentDirectoryPath)/config.plist"
Log.info("Reading config from \(configPath)")

let configPlist = NSDictionary(contentsOfFile: configPath)

let router = Router()
router.all("/webhook", middleware: BodyParser())

guard let hockeyToken = configPlist?["HockeyToken"] as? String,
    let yammerToken = configPlist?["YammerToken"] as? String,
    let yammerGroupId = configPlist?["YammerGroupId"] as? Int else {
    Log.error("You must specify HockeyToken, YammerToken AND YammerGroupId parameters in config!")
    exit(-15)
}

let hockeyApi = HockeyApi(token: hockeyToken)
let yam = Yammer(token: yammerToken)
let hockeyFacade = HockeyFacade(api: hockeyApi)

let hookHandler = HookHandler(hockey: hockeyFacade, yammer: yam, groupId: yammerGroupId)

router.get("/") {
    request, response, next in
    response.send("HockeyApp Hooks server!")
    next()
}

router.post("/webhook") {
    request, response, next in
    
    guard let parsedBody = request.body else {
        next()
        return
    }

    switch parsedBody {
    case .json(let json):
        hookHandler.process(json: json)
    default: break
    }
    response.send("Thanks!")
    next()
}
//
//hockeyApi.fetchApps() { apps, error in
//    if let apps = apps {
//        for app in apps {
//            if app.title.contains("Yammer") {
//                hockeyApi.fetchAppVersions(appId: app.publicIdentifier) { versions, error in
//
//                    if let versions = versions {
//                        print("\(versions.count) versions found for \(app.title)")
//                    }
//                }
//            }
//        }
//
//        print("\(apps.count) apps found")
//    }
//}

let port = configPlist?["ListenPort"] as? Int ?? 8080
Log.info("Starting server on port \(port)")
Kitura.addHTTPServer(onPort:port, with: router)

Kitura.run()
