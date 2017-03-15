hockey-app-hooks
================

A simple Perfect (server-side Swift) web site to respond to HockeyApp webhooks. HockeyApp is a mobile crash reporting system: https://rink.hockeyapp.net

This web site funnels information coming from HockeyApp into Yammer.

Install [`ngrok`](https://ngrok.com/) for development. Eventually this will be running on a server.

Setup
-----

1. Clone the repo
2. `swift build`
3. `./.build/debug/HockeyAppHooks` Default port is 8080
4. In another terminal... `ngrok 8080`.
5. Add the webhook to HockeyApp.
6. Test the webhook by sending a 'PING'.

TODO
----

- add configuration for Yammer posting (access token, group, cc's)
- support the other hooks
- keep track of crash groups, instead of always creating a new thread starter
