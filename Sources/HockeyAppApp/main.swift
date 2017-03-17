import Foundation
import Kitura
import HockeyAppLib
import SwiftyJSON
import HeliumLogger
import LoggerAPI

let logger = HeliumLogger(.entry)
logger.format = "[(%date)] [(%type)] (%msg) [(%file):(%line) (%func)]"

Log.logger = logger

let router = Router()
router.all("/webhook", middleware: BodyParser())

let hockeyApi = HockeyApi(token: "13b7599e2dcd4527b10bc28c34b77710")
let yam = Yammer(token: "0criRS9Nok23Chct53mg")
let hockeyFacade = HockeyFacade(api: hockeyApi)

let hookHandler = HookHandler(hockey: hockeyFacade, yammer: yam)

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

let port = 8080
Log.info("Starting server on port \(port)")
Kitura.addHTTPServer(onPort:port, with: router)

Kitura.run()
