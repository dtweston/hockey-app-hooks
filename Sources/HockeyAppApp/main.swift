import Foundation
import Kitura
import HockeyAppLib
import SwiftyJSON
import HeliumLogger
import LoggerAPI
import DotEnv

let logger = HeliumLogger(.entry)
logger.format = "[(%date)] [(%type)] (%msg) [(%file):(%line) (%func)]"

Log.logger = logger

let env = DotEnv(withFile: ".env")

let router = Router()
router.all("/webhook", middleware: BodyParser())

guard let hockeyToken = env["HOCKEYAPP_TOKEN"], !hockeyToken.isEmpty,
    let yammerToken = env["YAMMER_TOKEN"], !yammerToken.isEmpty,
    let yammerGroupId = env.getAsInt("YAMMER_GROUP_ID"), yammerGroupId != 0 else {
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

let port = env.getAsInt("APP_PORT") ?? 8080
Log.info("Starting server on port \(port)")
Kitura.addHTTPServer(onPort:port, with: router)

Kitura.run()
