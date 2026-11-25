# Run ClassTrack with Docker Desktop

The supplied failure is caused by **JWT_SECRET not being defined**. The earlier NoGoalSpecifiedException means Maven was run without a goal. Java 24 also emitted tooling warnings. The Docker build uses Java 21 and Maven 3.9.11, and Compose explicitly supplies the database configuration and JWT secret.

## Windows quick start

1. Open Docker Desktop and wait until the **Linux container engine** is running.
2. Open PowerShell in this Backend folder.
3. Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Start-Docker.ps1
```

The execution-policy setting applies only to this PowerShell process; it does not change your machine policy. The script creates `.env` with random secrets only if missing, validates required values, and runs Compose with build and health waiting. It preserves an existing `.env`. On this machine `.env` has already been generated. Do not share or commit it.

If Docker's plugin discovery cannot find Compose, the script uses Docker Desktop's bundled Compose executable when present. If the daemon cannot connect, start Docker Desktop and rerun the script. Initial builds require internet access and several minutes to download images and dependencies.

Health: http://localhost:8080/actuator/health

API base: http://127.0.0.1:8080/api/v1

No host Java, Maven or MySQL installation is required for this workflow.

## Services and data

- `backend`: multi-stage Maven/JDK 21 build, minimal Java 21 JRE runtime, non-root UID 10001, read-only root filesystem, writable temporary directory, health probe.
- `db`: MySQL 8.0.42, automatically creates `classtrack_db` and the dedicated `classtrack` database user. An authenticated SELECT health check gates backend startup.
- Flyway migrates the container database when the app starts.
- `classtrack_mysql-data` is a persistent named volume. Normal stop/restart retains data.
- Your existing Windows MySQL services and databases are unchanged. MySQL is not published on host port 3306, so it does not conflict with them.
- This is a **new database**. Existing host records are not automatically copied; register a new teacher after startup or perform a separate reviewed migration.

The default API is bound to localhost. For physical iPhone access, set `HOST_BIND=0.0.0.0` in `.env`, recreate the backend, and use the computer's LAN address in the iOS Debug configuration. Allow TCP 8080 only on the intended private network. If 8080 is occupied, set `BACKEND_PORT=8081` and adjust the iOS URL.

## Direct Compose commands

Run from Backend after creating `.env`:

```powershell
docker compose config --quiet
docker compose up --build -d --wait --wait-timeout 240
docker compose ps
docker compose logs --tail 100 backend db
docker compose stop
docker compose start
docker compose down
```

`down` removes containers/network but keeps the database volume. **Do not add `--volumes` unless you intentionally want to erase the container database.** Changing MYSQL credentials in `.env` does not change passwords already initialized in the volume; keep the original credentials or update database passwords deliberately.

If `docker compose` is unavailable but Docker Desktop is installed:

```powershell
& "$env:ProgramFiles\Docker\Docker\resources\cli-plugins\docker-compose.exe" ps
```

The startup script performs that fallback automatically. Repair Docker Desktop to restore normal CLI plugin discovery when convenient.

## Other systems

Copy `.env.example` to `.env` and set JWT_SECRET, DB_PASSWORD and MYSQL_ROOT_PASSWORD to independently generated random values (for example, run `openssl rand -base64 48` three times). Then use `docker compose up --build -d --wait`.

Compose rejects missing/empty secrets before starting. JWT_SECRET must contain at least 32 UTF-8 bytes. Shell environment variables take precedence over `.env`; clear stale variables if they override the expected values. Never publish `docker compose config` output with secret interpolation; use `config --quiet` for validation.

## Security and tests

The compose stack uses the Spring `prod` profile so database configuration is explicit and Swagger is disabled. This local setup serves HTTP; a public deployment needs HTTPS and appropriate secret management. The MySQL connection is unencrypted inside the local Compose network; do not reuse that JDBC configuration across untrusted networks. Secrets are runtime environment values, not Docker build arguments or baked into the image. `.dockerignore` allows only pom.xml and src into the build context, excluding `.env` and host build output.

Image packaging skips test execution because MySQL integration tests require a separate database. Continue to run the existing test suite using its isolated test-database instructions; the Docker build does not claim those tests ran.

## Verification in this session

- PowerShell script syntax and local configuration generation validated.
- Generated secret fields checked without displaying their values.
- Compose configuration validated successfully with bundled Compose 2.39.2 (`config --quiet`).
- Docker Desktop's Linux engine was not running. The request to start Desktop was declined, so image build, container startup and container health checks were **not executed**.