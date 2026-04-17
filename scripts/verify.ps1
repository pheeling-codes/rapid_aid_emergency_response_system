# ============================================================
# Rapid Aid - Environment Verification Script
# Compatible with: Windows 10/11 (PowerShell 5.1+)
# ============================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Rapid Aid - Environment Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$passed = 0
$failed = 0
$warnings = 0

function Test-Tool {
    param(
        [string]$Name,
        [string]$Command,
        [string]$VersionArg = "--version",
        [string]$ExpectedPattern,
        [bool]$Required = $true
    )
    
    $cmd = Get-Command $Command -ErrorAction SilentlyContinue
    if ($cmd) {
        $version = & $Command $VersionArg 2>&1 | Select-Object -First 1
        $versionStr = $version.ToString().Trim()
        
        if ($ExpectedPattern -and ($versionStr -notmatch $ExpectedPattern)) {
            Write-Host "  [WARN] $Name : $versionStr (expected pattern: $ExpectedPattern)" -ForegroundColor Yellow
            $script:warnings++
        } else {
            Write-Host "  [PASS] $Name : $versionStr" -ForegroundColor Green
            $script:passed++
        }
    } else {
        if ($Required) {
            Write-Host "  [FAIL] $Name : NOT FOUND" -ForegroundColor Red
            $script:failed++
        } else {
            Write-Host "  [SKIP] $Name : Not installed (optional)" -ForegroundColor DarkGray
        }
    }
}

# -------------------------------------------------------
# 1. CORE TOOLS
# -------------------------------------------------------
Write-Host "[1/4] Core Development Tools" -ForegroundColor Yellow
Write-Host ""

Test-Tool -Name "Flutter SDK" -Command "flutter" -ExpectedPattern "3\.\d+" -Required $true
Test-Tool -Name "Dart SDK" -Command "dart" -ExpectedPattern "3\.\d+" -Required $true
Test-Tool -Name "Python" -Command "python" -ExpectedPattern "3\.12" -Required $true
Test-Tool -Name "Pip" -Command "pip" -ExpectedPattern "pip \d+" -Required $true

# -------------------------------------------------------
# 2. DATABASE & CACHE
# -------------------------------------------------------
Write-Host ""
Write-Host "[2/4] Database & Cache Services" -ForegroundColor Yellow
Write-Host ""

Test-Tool -Name "PostgreSQL (psql)" -Command "psql" -ExpectedPattern "16\." -Required $true

# Test Redis - check multiple sources
$redisFound = $false
$redisCmd = Get-Command redis-cli -ErrorAction SilentlyContinue
if ($redisCmd) {
    try {
        $redisPing = redis-cli ping 2>&1
        if ($redisPing -eq "PONG") {
            Write-Host "  [PASS] Redis Server : Running (PONG)" -ForegroundColor Green
            $redisFound = $true
            $passed++
        } else {
            Write-Host "  [WARN] Redis CLI found but server not responding" -ForegroundColor Yellow
            $warnings++
        }
    } catch {
        Write-Host "  [WARN] Redis CLI found but ping failed" -ForegroundColor Yellow
        $warnings++
    }
}

if (-not $redisFound) {
    $dockerCmd = Get-Command docker -ErrorAction SilentlyContinue
    if ($dockerCmd) {
        $redisContainer = docker ps --filter "name=rapid-aid-redis" --format "{{.Status}}" 2>&1
        if ($redisContainer -match "Up") {
            Write-Host "  [PASS] Redis Server : Running via Docker (rapid-aid-redis)" -ForegroundColor Green
            $passed++
            $redisFound = $true
        }
    }
}

if (-not $redisFound) {
    # Check Memurai
    $memuraiSvc = Get-Service -Name "Memurai" -ErrorAction SilentlyContinue
    if ($memuraiSvc -and $memuraiSvc.Status -eq "Running") {
        Write-Host "  [PASS] Redis Server : Running via Memurai service" -ForegroundColor Green
        $passed++
        $redisFound = $true
    }
}

if (-not $redisFound) {
    Write-Host "  [FAIL] Redis Server : NOT FOUND (install Redis, Memurai, or Docker)" -ForegroundColor Red
    $failed++
}

# -------------------------------------------------------
# 3. PostGIS EXTENSION
# -------------------------------------------------------
Write-Host ""
Write-Host "[3/4] PostGIS Extension" -ForegroundColor Yellow
Write-Host ""

$psqlCmd = Get-Command psql -ErrorAction SilentlyContinue
if ($psqlCmd) {
    Write-Host "  Testing PostGIS availability..." -ForegroundColor DarkGray
    Write-Host "  To verify PostGIS, connect to your database and run:" -ForegroundColor White
    Write-Host '    psql -U postgres -c "CREATE EXTENSION IF NOT EXISTS postgis; SELECT PostGIS_version();"' -ForegroundColor Cyan
    Write-Host "  Expected output: 3.4.x" -ForegroundColor White
    $warnings++
} else {
    Write-Host "  [SKIP] Cannot test PostGIS - psql not found" -ForegroundColor DarkGray
}

# -------------------------------------------------------
# 4. VIRTUAL ENVIRONMENT
# -------------------------------------------------------
Write-Host ""
Write-Host "[4/4] Python Virtual Environment" -ForegroundColor Yellow
Write-Host ""

$projectRoot = Split-Path $PSScriptRoot -Parent
$venvPath = Join-Path $projectRoot "backend\.venv"
$venvPython = Join-Path $venvPath "Scripts\python.exe"

if (Test-Path $venvPython) {
    $venvVer = & $venvPython --version 2>&1
    Write-Host "  [PASS] Virtual Environment : $venvVer at $venvPath" -ForegroundColor Green
    $passed++
} else {
    Write-Host "  [FAIL] Virtual Environment : Not found at $venvPath" -ForegroundColor Red
    Write-Host "         Create with: python -m venv $venvPath" -ForegroundColor White
    $failed++
}

# -------------------------------------------------------
# SUMMARY
# -------------------------------------------------------
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Verification Results" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Passed:   $passed" -ForegroundColor Green
Write-Host "  Warnings: $warnings" -ForegroundColor Yellow
Write-Host "  Failed:   $failed" -ForegroundColor Red
Write-Host ""

if ($failed -eq 0) {
    Write-Host "  [SUCCESS] All required tools are installed!" -ForegroundColor Green
    Write-Host "  Environment is ready for Rapid Aid development." -ForegroundColor Green
} else {
    Write-Host "  [ACTION REQUIRED] $failed tool(s) need installation." -ForegroundColor Red
    Write-Host "  Run .\scripts\install.ps1 for setup instructions." -ForegroundColor White
}

Write-Host ""
Write-Host "  Rapid Aid Tech Stack:" -ForegroundColor DarkGray
Write-Host "    Flutter 3.x | Django 5 | PostgreSQL 16" -ForegroundColor DarkGray
Write-Host "    PostGIS 3.4 | Redis 7  | Python 3.12" -ForegroundColor DarkGray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
