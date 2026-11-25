# Testing and verification

## Verified on 2026-11-25

Environment: Windows 11, Oracle JDK 21.0.5, Maven 3.9.11, MySQL 8.0.42, Spring Boot 4.0.10.

| Check | Result |
|---|---|
| Java production compilation (58 source files) | Passed |
| `mvn verify` and executable Spring Boot jar packaging | Passed |
| JUnit/Mockito/MockMvc tests | 6 passed, 0 failures, 0 errors, 0 skipped |
| Flyway migrations V1–V4 against a new isolated MySQL schema | Passed |
| Hibernate schema validation against MySQL | Passed |
| Authenticated `/v3/api-docs` runtime generation | Passed with Springdoc 3.0.0 |
| Official Maven Wrapper `mvnw.cmd -version` | Maven 3.9.11 / Java 21 verified |
| Packaged jar on local port 18080 | Started successfully |
| Actual HTTP health, registration, student creation, attendance save, dashboard calculation | Passed; health UP and expected 100% attendance |
| Editor diagnostics | No errors reported after cleanup |
| Swift source memberships in Xcode project | All source files referenced |
| Info.plist, shared scheme XML, asset catalog JSON syntax | Passed |
| Xcode compile / XCTest / iPhone simulator / device biometrics | Not run: macOS and Apple SDKs unavailable |
| Docker/Testcontainers execution path | Supplied, not executed; local isolated MySQL path was used |

The temporary HTTP verification server was stopped after testing. The development database was not used for tests. Test data remains in the isolated `classtrack_test_*` schema; its generated name is recorded locally in Backend/target/test-schema.txt. The test suite contains no database drops. Remove that schema manually when no longer needed.

The initial test attempt hit the machine's native-memory limit. Limiting the Maven and test JVM heap to 256 MB and processor count to two resolved it. The final Java compiler reported no warnings. Mockito/Spring's testing infrastructure emitted a JDK dynamic-agent warning during test startup; this did not affect test results.

## Backend coverage

[ApiIntegrationTest](../Backend/src/test/java/com/classtrack/ApiIntegrationTest.java) has two broad integration scenarios with individual assertions for:

- Registration, login, wrong credentials, account lookup, input validation.
- Protected routes, missing/expired JWT, authenticated OpenAPI and public health.
- Student create/get/update/archive, duplicate roll ID, combined search/filter, pagination constraints.
- Cross-teacher get/edit/delete of students and notes, and attendance mutation denial.
- Attendance upsert retaining one record ID, status editing, batch updates and atomic rollback after a later invalid row.
- Before-enrollment rejection, history/summary and rounded percentage.
- Unmarked exclusion from the attendance denominator and dashboard totals.
- Note create/list/update/delete, and history/notes preserved after student archive.

[ServiceUnitTest](../Backend/src/test/java/com/classtrack/ServiceUnitTest.java) has four focused tests for attendance math, JWT signature/secret handling, duplicate batch rejection before writes, and ownership lookup isolation.

## Run against Docker

Start Docker and run `./mvnw test` (Windows: `.\mvnw.cmd test`). With no TEST_DB_URL, Testcontainers starts MySQL 8.0.42 on an isolated random host port.

## Run against local MySQL

Create a fresh test schema first, for example:

```sql
CREATE DATABASE classtrack_test_manual CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
```

PowerShell from Backend:

```powershell
$env:JAVA_HOME = 'C:\Program Files\Java\jdk-21'
$env:TEST_DB_URL = 'jdbc:mysql://127.0.0.1:3306/classtrack_test_manual'
$env:TEST_DB_USERNAME = 'root'
$env:TEST_DB_PASSWORD = 'root123'
$env:MAVEN_OPTS = '-Xmx256m -XX:ActiveProcessorCount=2'
.\mvnw.cmd verify '-DargLine=-Xmx256m -XX:ActiveProcessorCount=2'
```

Tests only accept local-override URLs whose database name begins `classtrack_test_`. They set a dedicated test JWT secret and never require your application secret. Reports are under Backend/target/surefire-reports.

## iOS tests and acceptance

The unit and UI test targets are included in the shared scheme. Run Product → Test on a Mac, or use the command in [Frontend README](../Frontend/README.md). Source tests cover validation, matching JSON fields/enums, 64-bit identifiers, calculation rules, combined search/filter query construction, ViewModel error recovery, network error handling, empty deletes, and authentication navigation.

Still required on Apple hardware/tooling: compile all three targets, execute XCTest, exercise Face ID/Touch ID success/cancel/unavailable/changed enrollment, check dark mode and large Dynamic Type, validate LAN/ATS configuration, and complete a device-to-backend workflow. Static file validation is not a substitute for these checks.