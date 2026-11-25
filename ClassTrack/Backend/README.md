# ClassTrack backend

## Docker quick start (Windows)

Start Docker Desktop with Linux containers, then run from this folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Start-Docker.ps1
```

This creates local secrets if absent and starts the Java 21 backend plus a separate persistent MySQL database. See [Docker setup and troubleshooting](DOCKER.md). The host MySQL database is not migrated or modified.


## Requirements and configuration

Java 21, MySQL 8.0.16+ and internet access for initial Maven resolution. The official Maven Wrapper pins Maven 3.9.11; a system Maven installation is optional. Spring Boot 4.0.10 manages Spring Framework/Security/Data, Hibernate, Jackson, Flyway, Connector/J, JUnit and Mockito. Springdoc 3.0.0 is compatible with Spring Boot 4; JJWT 0.12.6 provides JWT signing and validation.

| Variable | Default / requirement |
|---|---|
| `DB_URL` | `jdbc:mysql://localhost:3306/classtrack_db?connectionTimeZone=UTC` locally |
| `DB_USERNAME` | `root` locally |
| `DB_PASSWORD` | `root123` locally |
| `JWT_SECRET` | Required, at least 32 UTF-8 bytes; generate a random value |
| `JWT_EXPIRATION_SECONDS` | `3600` |
| `PORT` | `8080` |
| `SPRING_PROFILES_ACTIVE` | Set `dev` for local API docs, `prod` for deployment |
| `API_DOCS_ENABLED` | `false` unless dev profile enables it |

The production profile requires all database variables explicitly and disables docs. Use a dedicated least-privilege database account and HTTPS ingress in production. Do not commit secrets. The application never sends database credentials to the iPhone.

## Run

Create `classtrack_db` in MySQL (see [root instructions](../README.md)), set `JWT_SECRET`, and run:

```powershell
.\mvnw.cmd spring-boot:run
```

```sh
./mvnw spring-boot:run
```

Health: `http://localhost:8080/actuator/health`.

Build executable jar: `./mvnw package -DskipTests`. Run: `java -jar target/classtrack-1.0.0.jar`. The same environment variables apply.

## API documentation

With the dev profile, Swagger UI is at `http://localhost:8080/swagger-ui/index.html` and OpenAPI JSON at `/v3/api-docs`. Both **require a Bearer token**, including the UI's asset and specification requests. Register/login using Postman, then use an HTTP-header browser extension scoped to this local origin to attach `Authorization: Bearer <token>` to all requests. Do not enable that rule for other sites. Alternatively fetch `/v3/api-docs` with the bearer header and import it into Postman. The supplied Postman collection works without Swagger.

Authentication is required everywhere except login, registration and `/actuator/health`. API docs are deliberately not publicly whitelisted.

## Tests

```sh
./mvnw test
```

With no `TEST_DB_URL`, integration tests start a disposable MySQL 8.0.42 container (Docker must be running). To use local MySQL instead, create a **new** `classtrack_test_<unique_suffix>` schema and set `TEST_DB_URL`, optionally `TEST_DB_USERNAME` and `TEST_DB_PASSWORD`. Tests reject URLs that do not use the dedicated test prefix. They do not drop or clear development data. Test accounts use random emails; repeated runs can share a test schema without collisions.

See [Testing](../Documentation/Testing.md) for PowerShell commands, memory limits and test coverage.

## Design notes

Controllers validate DTOs and delegate to transactional service interfaces/implementations. Services derive the teacher from Spring Security, never from request-body ownership fields. JPA repositories and specifications scope every operation to that teacher. DTOs avoid serializing password hashes and lazy entity relationships. MySQL uniqueness constraints provide a race-safe last line of defense; simultaneous conflicting writes return 409 and can be retried.

Login and registration are limited to 20 requests per source IP per minute. This limiter is bounded and process-local; use a shared gateway limit if deploying multiple instances. Forwarded headers are not trusted for rate-limit identity. Tokens are valid for one hour by default. Logout removes the local token; there is no server revocation list or refresh-token endpoint. Rotating `JWT_SECRET` invalidates all outstanding tokens.
