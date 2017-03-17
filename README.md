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

