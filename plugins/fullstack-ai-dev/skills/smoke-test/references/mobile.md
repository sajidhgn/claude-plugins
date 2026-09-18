# Mobile smoke testing

## Tooling (in order of preference)
1. **Maestro** (`maestro test .devrun/smoke/<flow>.yaml`) on an iOS simulator or Android emulator — readable flows, good for repeatable smoke passes.
2. **Device tooling directly:** `xcrun simctl` (boot, install, launch, `openurl` for deep links, `io booted screenshot`) and `adb` (install, `am start`, `exec-out screencap -p`, `input text`).
3. A mobile automation MCP server, if the user has one connected.
4. **No simulator available:** run the Expo web target or widget/component tests, and list "not verified on device" as a gap in the report.

Logs: `adb logcat` (filter by app package) and `xcrun simctl spawn booted log stream --predicate 'process == "<App>"'`, or the Metro/Flutter console.

## Networking
The app must point at the running backend: Android emulator → `10.0.2.2:<port>`, iOS simulator → `localhost:<port>`, physical device → LAN IP or a tunnel.

## Per scenario
- Cold start to first meaningful screen; note crash or long splash.
- Sign in; core flow for the task; data visible after pull-to-refresh and after app restart.
- Background → foreground mid-flow (state preserved, no duplicate requests).
- Permissions: allow **and** deny paths (camera, photos, notifications, location).
- Offline / flaky network: disable network (`adb shell svc wifi disable` / `svc data disable`, or simulator network link conditioner) — the app shows a recoverable state, no crash.
- Keyboard doesn't cover inputs; content respects safe areas; Android hardware back behaves.
- RTL locale if supported.
- Deep links / push notification taps route to the right screen (if in scope).
