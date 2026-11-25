# ClassTrack iPhone app

Open [ClassTrack.xcodeproj](ClassTrack.xcodeproj) in **Xcode 16+ on macOS**. Select the shared `ClassTrack` scheme and an iPhone running iOS 17 or later. The app targets iPhone only and supports portrait only. No package installation is needed: SwiftUI, Charts, Security, LocalAuthentication and Foundation are Apple SDK frameworks.

## API configuration

[Debug.xcconfig](Config/Debug.xcconfig) defaults to `http://127.0.0.1:8080/api/v1`. The `/$()/` syntax prevents xcconfig from treating `//` as a comment. For a backend on a Windows PC or another machine, set its LAN address/hostname:

```xcconfig
API_BASE_URL = http:/$()/192.168.1.20:8080/api/v1
```

The iPhone and server must be on the same network, with the server firewall allowing TCP 8080 on the private network. Localhost on an iPhone refers to the phone, not the computer. Localhost on a simulator refers to its Mac, not a Windows backend.

Debug Info.plist contains a local-network permission description, `NSAllowsLocalNetworking` and a narrowly scoped `localhost` HTTP exception. Depending on the iOS version, numeric LAN IPs may need HTTPS or a `.local` hostname for ATS. Prefer HTTPS or the server's Bonjour `.local` name; if a named development host requires an exception, add that exact hostname to **Info-Debug.plist only**. Never add a global `NSAllowsArbitraryLoads` exception. Validate on the target device.

[Release.xcconfig](Config/Release.xcconfig) requires a real HTTPS API domain; replace `api.example.com` before distribution. Release Info.plist contains no development ATS exceptions. The client rejects a non-HTTPS release URL.

For physical devices, select your development team in Signing & Capabilities and use your own unique bundle identifier. Automatic signing is enabled but no team is hardcoded.

## Architecture

`View → @MainActor ObservableObject ViewModel → service protocol → APIClient → Spring Boot`.

Each feature has Views, ViewModels and Models folders. Global wire models use Int64 identifiers, ISO `yyyy-MM-dd` calendar dates, and the backend enum strings. Server Instant timestamps are retained as ISO strings, including fractional seconds. API envelopes, HTTP errors, cancellation, timeouts, 401 expiry and empty 204 responses are handled centrally. All persistent classroom data comes from the backend. Only appearance and the biometric preference live in UserDefaults.

The shared authentication object controls the root route. Mutations post a `recordsChanged` notification, which reloads dashboard/roster/detail views. The roster supports debounced search, combined filters, pagination and retry. Attendance edits remain local until Save. Up to 500 changed marks are saved atomically. Existing marks cannot be cleared to Unmarked; they can be changed to Present, Absent or Late.

## Biometrics

Manual login stores a JWT in Keychain with device-only accessibility. Enabling biometrics first evaluates LocalAuthentication and replaces the item with `biometryCurrentSet` access control and `WhenPasscodeSetThisDeviceOnly`. No unprotected token copy remains in Keychain. On unlock, an authenticated LAContext retrieves the item and `/auth/me` validates the session. Backgrounding clears the in-memory token and locks the UI when biometrics are enabled. Expired tokens require manual login. Changed enrollment invalidates the protected item; use manual login and enable biometrics again. Cancellation does not bypass the lock. Biometric templates never leave the device.

## Tests

Use **Product → Test** or:

```sh
xcodebuild -project ClassTrack.xcodeproj -scheme ClassTrack \
  -destination 'platform=iOS Simulator,name=iPhone 16' test
```

Choose a simulator name actually installed on your Mac (`xcrun simctl list devices available`). Unit tests cover validation, Codable contracts, Int64 IDs, attendance calculations, combined filter queries, ViewModel loading/error recovery, unauthorized handling and 204 responses. UI tests verify the login/registration navigation and protected-tab boundary. The DEBUG-only `-ui-testing` argument skips restoring an existing session without changing production behavior.

Manual acceptance: register; add/edit/search/filter/archive students; mark a past date; change a previous mark; inspect charts/history; create/edit/delete each note category; enable biometrics; background/foreground; cancel authentication; simulate changed enrollment; expire the JWT; switch light/dark mode and large text sizes; disconnect the network and retry.

This project was generated on Windows. Xcode builds and XCTest/device execution are **not verified** here.

## Attendance history corrections

Open a student's attendance history and tap a status badge to choose a corrected status. Confirm the change to send PATCH /attendance/{id}; the student and date remain unchanged. Failed saves keep the previously saved status and show the server error. Successful saves notify the dashboard and student summary to refresh. Invalid login credentials display the server message without invoking the session-expiration flow.

Two additional XCTest cases cover history-edit success/failure and invalid-credential error handling. These tests require Xcode and have not been executed on Windows.
