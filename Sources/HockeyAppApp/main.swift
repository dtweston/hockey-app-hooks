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

guard let hockeyToken = configPlist?["HockeyToken"] as? String, !hockeyToken.isEmpty,
    let yammerToken = configPlist?["YammerToken"] as? String, !yammerToken.isEmpty,
    let yammerGroupId = configPlist?["YammerGroupId"] as? Int, yammerGroupId != 0 else {
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

let port = configPlist?["ListenPort"] as? Int ?? 8080
Log.info("Starting server on port \(port)")
Kitura.addHTTPServer(onPort:port, with: router)

Kitura.run()
