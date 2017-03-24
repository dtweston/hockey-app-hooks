hockey-app-hooks
================

A simple Kitura (server-side Swift) web site to respond to HockeyApp webhooks. HockeyApp is a mobile crash reporting system: https://rink.hockeyapp.net

This web site funnels information coming from HockeyApp into Yammer.

Install [`ngrok`](https://ngrok.com/) for development. Eventually this will be running on a server.

Setup
-----

1. Clone the repo
2. `swift build`
3. Edit the `config.plist` file (in the root of the repo) to add `HockeyToken` and `YammerToken`.
4. Run `./.build/debug/HockeyAppHooks`
5. The app looks for `config.plist` in the current directory.
4. In another terminal... `ngrok [ListenPort]`.
5. Add the webhook to HockeyApp.
6. Test the webhook by sending a 'PING'.

Debugging
---------

A nice feature of server-side Swift is that you can use Xcode as a development environment. It's a bit clunky 
since Xcode doesn't directly support the Swift package format, but in practice, it works fairly well:

1. Generate an Xcode project with `swift package generate-xcodeproj`.
2. Open the project: `open HockeyAppHooks.xcodeproj`

Within Xcode you can set breakpoints, use lldb commands and get syntax highlighting. Go wild!

The Xcode project is intentionally in the `.gitignore` file because the `Package.swift` configuration should
be the source of truth.

Todo
----

- [ ] include an @ mention for the reporting user on Yammer if we have that info
- [ ] extend the config file for more options (support additional groups, etc.)
- [ ] get it running permanently with a stable host name
- [ ] build a wrapper to relaunch the app if it crashes
- [ ] send logs somewhere (kibana?)
- [ ] dockerize the server (dockerization?)
