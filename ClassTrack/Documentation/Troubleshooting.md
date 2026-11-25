# Troubleshooting

- **JWT_SECRET unresolved / weak key:** set a random environment value of at least 32 UTF-8 bytes before starting. Do not paste it into source or logs.
- **Access denied / unknown database:** start MySQL, create `classtrack_db`, check DB_URL, DB_USERNAME and DB_PASSWORD. Local defaults are root/root123. Use a separate account for production.
- **Port 8080 already used:** set PORT and update the iOS API base URL together.
- **Java version mismatch:** set JAVA_HOME to JDK 21 and verify `mvnw -version`.
- **Maven memory error:** set `MAVEN_OPTS=-Xmx256m -XX:ActiveProcessorCount=2`; test with `-DargLine="-Xmx256m -XX:ActiveProcessorCount=2"`. The verification machine initially ran out of native memory with default JVM sizing.
- **Maven cannot access cache:** check writable home/cache configuration. Initial dependencies require network access to Maven Central.
- **Tests cannot find Docker:** start Docker, or configure a freshly created isolated MySQL `classtrack_test_*` database as described in Testing.md. Never point tests at `classtrack_db`.
- **401 on Swagger:** documentation is authenticated, including its assets. Attach a bearer header to every request or use Postman.
- **401 in app:** the token expired or the signing key changed. Sign in again. JWT defaults to one hour; biometrics cannot extend its lifetime.
- **iPhone cannot reach API:** localhost is the phone. Use the backend's reachable LAN host, allow local network permission, use the same network, and check Windows firewall. ATS may require HTTPS or a named `.local` host depending on OS version; exceptions belong only in Debug plist.
- **Biometrics unavailable:** configure a passcode and biometric enrollment; Simulator requires enrollment through Features. A changed biometric enrollment invalidates the Keychain item; use manual login, then re-enable biometrics.
- **Roll ID conflict after deletion:** archival keeps the record and reserves the roll ID. View inactive students using filters.
- **Unmarked count seems high:** attendance is stored per day. Changing the date does not carry forward yesterday's marks. A new empty date starts unmarked.
- **Xcode signing error:** select your development team and unique bundle ID, or run an iPhone simulator.
- **Xcode project on Windows:** Windows cannot compile SwiftUI or use iOS SDKs. Copy the whole Frontend directory to a Mac and run its shared scheme.
- **Release build exits with URL assertion:** configure a real HTTPS API URL in Release.xcconfig.
