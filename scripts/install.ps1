# ============================================================
# Rapid Aid - Environment Installation Script
# Compatible with: Windows 10/11 (PowerShell 5.1+)
# ============================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Rapid Aid - Environment Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# -------------------------------------------------------
# 1. FLUTTER (Already installed)
# -------------------------------------------------------
Write-Host "[1/5] Flutter SDK (stable channel)..." -ForegroundColor Yellow

$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutterCmd) {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "  [OK] Flutter already installed: $flutterVersion" -ForegroundColor Green
    Write-Host "  Upgrading to latest stable..." -ForegroundColor DarkGray
    flutter upgrade 2>&1 | Select-Object -Last 3
    flutter config --enable-web 2>&1 | Out-Null
    flutter config --enable-android 2>&1 | Out-Null
    Write-Host "  [DONE] Flutter is up-to-date on stable channel." -ForegroundColor Green
} else {
    Write-Host "  [ACTION REQUIRED] Flutter not found!" -ForegroundColor Red
    Write-Host "  Download from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor White
    Write-Host "  Extract to C:\flutter and add C:\flutter\bin to PATH." -ForegroundColor White
}

# -------------------------------------------------------
# 2. PYTHON 3.12
# -------------------------------------------------------
Write-Host ""
Write-Host "[2/5] Python 3.12..." -ForegroundColor Yellow

$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
$pyCmd = Get-Command py -ErrorAction SilentlyContinue

if ($pythonCmd) {
    $pyVer = python --version 2>&1
    Write-Host "  [OK] Python found: $pyVer" -ForegroundColor Green
} elseif ($pyCmd) {
    $pyVer = py --version 2>&1
    Write-Host "  [OK] Python found via py launcher: $pyVer" -ForegroundColor Green
} else {
    Write-Host "  [INSTALLING] Downloading Python 3.12.8 installer..." -ForegroundColor Magenta
    
    $pythonUrl = "https://www.python.org/ftp/python/3.12.8/python-3.12.8-amd64.exe"
    $installerPath = "$env:TEMP\python-3.12.8-amd64.exe"
    
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $pythonUrl -OutFile $installerPath -UseBasicParsing
        Write-Host "  Downloaded to: $installerPath" -ForegroundColor DarkGray
        
        Write-Host "  Running installer (silent, with PATH)..." -ForegroundColor DarkGray
        Start-Process -FilePath $installerPath -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1", "Include_pip=1", "Include_test=0" -Wait -NoNewWindow
        
        Write-Host "  [DONE] Python 3.12.8 installed." -ForegroundColor Green
        Write-Host "  [!] You may need to RESTART your terminal for PATH changes." -ForegroundColor Yellow
    } catch {
        Write-Host "  [ERROR] Failed to download Python installer." -ForegroundColor Red
        Write-Host "  Manual download: https://www.python.org/downloads/release/python-3128/" -ForegroundColor White
    }
}

# -------------------------------------------------------
# 3. POSTGRESQL 16 + PostGIS 3.4
# -------------------------------------------------------
Write-Host ""
Write-Host "[3/5] PostgreSQL 16 + PostGIS 3.4..." -ForegroundColor Yellow

$psqlCmd = Get-Command psql -ErrorAction SilentlyContinue
if ($psqlCmd) {
    $pgVer = psql --version 2>&1
    Write-Host "  [OK] PostgreSQL found: $pgVer" -ForegroundColor Green
} else {
    Write-Host "  [ACTION REQUIRED] PostgreSQL 16 not found." -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  === MANUAL INSTALLATION STEPS ===" -ForegroundColor White
    Write-Host "  1. Download EDB Installer:" -ForegroundColor White
    Write-Host "     https://www.enterprisedb.com/downloads/postgres-postgresql-downloads" -ForegroundColor Cyan
    Write-Host "     Select: PostgreSQL 16 -> Windows x86-64" -ForegroundColor White
    Write-Host ""
    Write-Host "  2. Run the installer with these settings:" -ForegroundColor White
    Write-Host "     - Install directory: C:\Program Files\PostgreSQL\16" -ForegroundColor White
    Write-Host "     - Data directory: C:\Program Files\PostgreSQL\16\data" -ForegroundColor White
    Write-Host "     - Password: Set a superuser password (remember it!)" -ForegroundColor White
    Write-Host "     - Port: 5432 (default)" -ForegroundColor White
    Write-Host "     - Locale: Default" -ForegroundColor White
    Write-Host ""
    Write-Host "  3. When prompted, launch Stack Builder and install:" -ForegroundColor White
    Write-Host "     - Spatial Extensions > PostGIS 3.4 Bundle for PostgreSQL 16" -ForegroundColor Yellow
    Write-Host "     - Check 'Create spatial database' during PostGIS setup" -ForegroundColor White
    Write-Host ""
    Write-Host "  4. Add to PATH:" -ForegroundColor White
    Write-Host '     $env:Path += ";C:\Program Files\PostgreSQL\16\bin"' -ForegroundColor Cyan
    Write-Host ""
}

# -------------------------------------------------------
# 4. REDIS 7 (via Docker or Memurai)
# -------------------------------------------------------
Write-Host ""
Write-Host "[4/5] Redis 7..." -ForegroundColor Yellow

$redisCmd = Get-Command redis-server -ErrorAction SilentlyContinue
$dockerCmd = Get-Command docker -ErrorAction SilentlyContinue

if ($redisCmd) {
    $redisVer = redis-server --version 2>&1
    Write-Host "  [OK] Redis found: $redisVer" -ForegroundColor Green
} elseif ($dockerCmd) {
    Write-Host "  [DOCKER] Docker detected. Setting up Redis 7 container..." -ForegroundColor Magenta
    
    # Check if container already exists
    $existing = docker ps -a --filter "name=rapid-aid-redis" --format "{{.Names}}" 2>&1
    if ($existing -eq "rapid-aid-redis") {
        Write-Host "  Starting existing rapid-aid-redis container..." -ForegroundColor DarkGray
        docker start rapid-aid-redis 2>&1 | Out-Null
    } else {
        Write-Host "  Creating Redis 7 container..." -ForegroundColor DarkGray
        docker run -d --name rapid-aid-redis -p 6379:6379 redis:7-alpine 2>&1
    }
    Write-Host "  [DONE] Redis 7 running on localhost:6379" -ForegroundColor Green
} else {
    Write-Host "  [ACTION REQUIRED] Redis and Docker not found." -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  Choose ONE of these options:" -ForegroundColor White
    Write-Host ""
    Write-Host "  Option A - Memurai (Native Windows Redis):" -ForegroundColor Yellow
    Write-Host "    1. Download from: https://www.memurai.com/get-memurai" -ForegroundColor White
    Write-Host "    2. Install with defaults" -ForegroundColor White
    Write-Host "    3. It runs as a Windows service automatically" -ForegroundColor White
    Write-Host ""
    Write-Host "  Option B - Docker Desktop:" -ForegroundColor Yellow
    Write-Host "    1. Install Docker Desktop: https://www.docker.com/products/docker-desktop/" -ForegroundColor White
    Write-Host "    2. Then run: docker run -d --name rapid-aid-redis -p 6379:6379 redis:7-alpine" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Option C - WSL2 + Redis:" -ForegroundColor Yellow
    Write-Host "    1. Enable WSL2: wsl --install" -ForegroundColor White
    Write-Host "    2. Inside WSL: sudo apt update && sudo apt install redis-server" -ForegroundColor Cyan
    Write-Host ""
}

# -------------------------------------------------------
# 5. CREATE PYTHON VIRTUAL ENVIRONMENT
# -------------------------------------------------------
Write-Host ""
Write-Host "[5/5] Creating Python virtual environment..." -ForegroundColor Yellow

$pythonExe = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonExe) {
    $pythonExe = Get-Command py -ErrorAction SilentlyContinue
}

if ($pythonExe) {
    $venvPath = Join-Path (Split-Path $PSScriptRoot -Parent) "backend\.venv"
    if (Test-Path $venvPath) {
        Write-Host "  [OK] Virtual environment already exists at $venvPath" -ForegroundColor Green
    } else {
        Write-Host "  Creating venv at: $venvPath" -ForegroundColor DarkGray
        & $pythonExe.Source -m venv $venvPath
        Write-Host "  [DONE] Virtual environment created." -ForegroundColor Green
    }
    Write-Host "  Activate with: .\backend\.venv\Scripts\Activate.ps1" -ForegroundColor Cyan
} else {
    Write-Host "  [SKIP] Python not available - install Python first, then re-run." -ForegroundColor DarkGray
}

# -------------------------------------------------------
# SUMMARY
# -------------------------------------------------------
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Installation Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Next step: Run .\scripts\verify.ps1" -ForegroundColor Green
Write-Host "  to confirm all tools are at the correct versions." -ForegroundColor Green
Write-Host ""
Write-Host "  IMPORTANT: Restart your terminal if Python was just installed!" -ForegroundColor Yellow
Write-Host ""
