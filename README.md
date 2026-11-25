# ClassTrack

An iPhone classroom attendance and participation app. SwiftUI connects to a separate Java 21 / Spring Boot 4 backend, with MySQL persistence. There are no seeded classroom records or fake runtime APIs.

## Projects

- [Frontend](Frontend/README.md): iOS 17+, SwiftUI, MVVM, URLSession, Keychain, LocalAuthentication and Swift Charts. Open [ClassTrack.xcodeproj](Frontend/ClassTrack.xcodeproj) on a Mac with Xcode 16 or later.
- [Backend](Backend/README.md): Spring Boot 4.0.10, Spring Security, JPA/Hibernate, Flyway, BCrypt, signed JWT, Actuator and OpenAPI.
- [Architecture](Documentation/Architecture.md), [database design](Documentation/DatabaseDesign.md), [API reference](Documentation/API-Documentation.md), [testing](Documentation/Testing.md), [troubleshooting](Documentation/Troubleshooting.md).
- Import [Postman collection](Documentation/ClassTrack.postman_collection.json) to exercise the API.

## Start the backend

Install Java 21 and MySQL 8.0.16+ (tested with 8.0.42). Create the local database:

```sql
CREATE DATABASE IF NOT EXISTS classtrack_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
```

Local defaults are `localhost:3306`, database `classtrack_db`, user `root`, password `root123`. Change them with `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`. These credentials are for local development only.

PowerShell:

```powershell
cd ClassTrack/Backend
$env:JAVA_HOME = 'C:\Program Files\Java\jdk-21'
$bytes = New-Object byte[] 48
$rng = [Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($bytes)
$rng.Dispose()
$env:JWT_SECRET = [Convert]::ToBase64String($bytes)
$env:SPRING_PROFILES_ACTIVE = 'dev'
.\mvnw.cmd spring-boot:run
```

macOS/Linux:

```sh
cd ClassTrack/Backend
export JAVA_HOME=$(/usr/libexec/java_home -v 21) # macOS
export JWT_SECRET="$(openssl rand -base64 48)"
export SPRING_PROFILES_ACTIVE=dev
chmod +x mvnw
./mvnw spring-boot:run
```

Verify `http://localhost:8080/actuator/health`. The API base is `http://127.0.0.1:8080/api/v1`. Flyway creates all tables. No teacher account exists until registration.

## Start the iPhone app

1. Open the Xcode project on a Mac and select the **ClassTrack** scheme and an iPhone simulator.
2. Set `API_BASE_URL` in [Debug.xcconfig](Frontend/Config/Debug.xcconfig). The default works when the backend is on the same Mac. If the backend runs on this Windows PC, use its LAN address or local hostname, even for a simulator on a different Mac.
3. For a physical iPhone, choose your signing team, use the backend machine's LAN address, and permit local network access. See the [frontend README](Frontend/README.md) for ATS details.
4. Build and run. Register, add students, mark attendance, add notes and verify the dashboard.
5. Enable biometric unlock in Settings after signing in. In Simulator, use **Features → Face ID → Enrolled** and **Matching Face**. Use the equivalent Touch ID controls where available.

## Implemented behavior

Four tabs provide dashboard analytics, paginated/searchable roster, dated attendance entry, and settings. Students can be created, edited and archived. Attendance is an upsert per student/date; bulk saves are atomic. Notes support all four categories with edit/delete. Dashboard totals refresh after mutations. Unmarked students never count as absent. Attendance percentage is `(present + late) / marked × 100`, with zero for no marks.

All records are scoped to the signed-in teacher. Soft deletion retains attendance and notes; choose inactive students in roster filters to view archived records. A roll ID remains reserved after archival. There is no reactivation endpoint.

## Verification and limitations

The backend was compiled and integration-tested against a newly created isolated MySQL schema on Windows. See [Testing](Documentation/Testing.md) for the exact verification record. Xcode and Apple SDKs are unavailable on Windows: iOS compilation, simulator/UI execution, device signing, ATS behavior and biometric hardware flows must be verified on a Mac/iPhone. Source and target memberships are supplied for app, unit tests and UI tests.

Release configuration requires your HTTPS API hostname; the example domain must be replaced. A release does not enable local-network ATS exceptions. Production deployment is not included. Use the `prod` Spring profile to require explicit database configuration and disable API documentation.
