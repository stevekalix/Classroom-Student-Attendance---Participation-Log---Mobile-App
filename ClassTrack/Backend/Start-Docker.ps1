[CmdletBinding()]
param([switch]$ConfigureOnly)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Set-Location -LiteralPath $PSScriptRoot
function New-LocalSecret {
    $bytes = New-Object byte[] 48
    $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
    return [Convert]::ToBase64String($bytes)
}
$envFile = Join-Path $PSScriptRoot '.env'
if (-not (Test-Path -LiteralPath $envFile)) {
    $lines = @(
        'JWT_SECRET=' + (New-LocalSecret)
        'DB_PASSWORD=' + (New-LocalSecret)
        'MYSQL_ROOT_PASSWORD=' + (New-LocalSecret)
        'BACKEND_PORT=8080'
        'HOST_BIND=127.0.0.1'
        'JWT_EXPIRATION_SECONDS=3600'
    )
    [IO.File]::WriteAllLines($envFile, $lines, (New-Object Text.UTF8Encoding($false)))
    Write-Host 'Created .env with random local secrets. Existing MySQL data is not modified.'
}
foreach ($key in @('JWT_SECRET', 'DB_PASSWORD', 'MYSQL_ROOT_PASSWORD')) {
    $line = Get-Content -LiteralPath $envFile | Where-Object { $_ -match "^$key=.+$" } | Select-Object -First 1
    if (-not $line) { throw "Set $key in .env before starting." }
    if ($key -eq 'JWT_SECRET' -and [Text.Encoding]::UTF8.GetByteCount($line.Substring($key.Length + 1)) -lt 32) {
        throw 'JWT_SECRET must contain at least 32 UTF-8 bytes.'
    }
}
if ($ConfigureOnly) { Write-Host 'Local configuration is ready.'; return }
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Install Docker Desktop with Linux containers, then reopen PowerShell.' }
$script:composeExecutable = $null
$desktopCompose = Join-Path $env:ProgramFiles 'Docker/Docker/resources/cli-plugins/docker-compose.exe'
if (Test-Path -LiteralPath $desktopCompose) {
    $script:composeExecutable = $desktopCompose
    & $script:composeExecutable version
} else {
    & docker compose version
}
if ($LASTEXITCODE -ne 0) { throw 'Docker Compose v2 is unavailable. Repair/update Docker Desktop and reopen PowerShell.' }
function Invoke-Compose {
    if ($script:composeExecutable) { & $script:composeExecutable @args }
    else { & docker compose @args }
}
& docker info --format '{{.OSType}}'
if ($LASTEXITCODE -ne 0) { throw 'Start Docker Desktop, select Linux containers, and wait for the engine to be running.' }
Invoke-Compose config --quiet
if ($LASTEXITCODE -ne 0) { throw 'Compose configuration is invalid. Check .env and compose.yaml.' }
Invoke-Compose up --build --detach --wait --wait-timeout 240
if ($LASTEXITCODE -ne 0) { throw 'Container startup failed. Run: docker compose logs --tail 100 backend db' }
Invoke-Compose ps
Write-Host 'ClassTrack is running. Health: http://localhost:<BACKEND_PORT>/actuator/health (default port 8080).'
