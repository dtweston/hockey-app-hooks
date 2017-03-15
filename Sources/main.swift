import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

// An example request handler.
// This 'handler' function can be referenced directly in the configuration below.
func handler(data: [String:Any]) throws -> RequestHandler {
	return {
		request, response in
		// Respond with a simple message.
		response.setHeader(.contentType, value: "text/html")
		response.appendBody(string: "<html><title>HockeyApp Hooks</title><body>HockeyApp Hooks</body></html>")
		// Ensure that response.completed() is called when your processing is done.
		response.completed()
	}
}

// Configuration data for two example servers.
// This example configuration shows how to launch one or more servers 
// using a configuration dictionary.

let port1 = 8080

let confData = [
	"servers": [
		[
			"name":"localhost",
			"port":port1,
			"routes":[
				["method":"get", "uri":"/", "handler":handler],
			],
			"filters":[
				[
				"type":"response",
				"priority":"high",
				"name":PerfectHTTPServer.HTTPFilter.contentCompression,
				]
			]
		]
	]
]

do {
	// Launch the server based on the configuration data.
	try HTTPServer.launch(configurationData: confData)
} catch {
	fatalError("\(error)")
}

