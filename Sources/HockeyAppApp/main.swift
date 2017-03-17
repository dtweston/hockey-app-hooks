import Foundation
import Kitura
import HockeyAppLib
import SwiftyJSON

let router = Router()
router.all("/webhook", middleware: BodyParser())

let hockeyApi = HockeyApi(token: "13b7599e2dcd4527b10bc28c34b77710")
let yam = Yammer(token: "0criRS9Nok23Chct53mg")
let parser = WebhookParser()

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
        let info = parser.parse(json)
        print("info: \(String(describing: info))")
    default: break
    }
    response.send("Thanks!")
    next()
}

hockeyApi.fetchApps() { apps, error in
    if let apps = apps {
        for app in apps {
            if app.title.contains("Yammer") {
                hockeyApi.fetchAppVersions(appId: app.publicIdentifier) { versions, error in

                    if let versions = versions {
                        print("\(versions.count) versions found for \(app.title)")
                    }
                }
            }
            print("App: \(String(describing: app))")
        }

        print("\(apps.count) apps found")
    }
}

//yam.postMessage(MessagePostRequest(message: "Hi from Kitura!", groupID: 9962571))

Kitura.addHTTPServer(onPort:8080, with: router)

Kitura.run()
