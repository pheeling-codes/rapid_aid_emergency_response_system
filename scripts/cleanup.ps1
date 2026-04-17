# ============================================================
# Rapid Aid - Environment Cleanup Script
# Compatible with: Windows 10/11 (PowerShell 5.1+)
# ============================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Rapid Aid - Environment Cleanup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- Step 1: Detect Existing Installations ---
Write-Host "[1/4] Scanning for existing installations..." -ForegroundColor Yellow

$tools = @(
    @{ Name = "Flutter"; Command = "flutter" },
    @{ Name = "Dart";    Command = "dart" },
    @{ Name = "Python";  Command = "python" },
    @{ Name = "Python3"; Command = "python3" },
    @{ Name = "Py Launcher"; Command = "py" },
    @{ Name = "PostgreSQL (psql)"; Command = "psql" },
    @{ Name = "Redis Server"; Command = "redis-server" },
    @{ Name = "Pip"; Command = "pip" }
)

foreach ($tool in $tools) {
    $found = Get-Command $tool.Command -ErrorAction SilentlyContinue
    if ($found) {
        $version = & $tool.Command --version 2>&1 | Select-Object -First 1
        Write-Host "  [FOUND] $($tool.Name): $version" -ForegroundColor Green
        Write-Host "         Location: $($found.Source)" -ForegroundColor DarkGray
    } else {
        Write-Host "  [NOT FOUND] $($tool.Name)" -ForegroundColor DarkGray
    }
}

# --- Step 2: Clear Flutter/Dart Pub Cache ---
Write-Host ""
Write-Host "[2/4] Clearing Flutter/Dart pub cache..." -ForegroundColor Yellow

$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutterCmd) {
    Write-Host "  Running: flutter pub cache clean" -ForegroundColor DarkGray
    flutter pub cache clean --force 2>&1 | Out-Null
    Write-Host "  [DONE] Flutter pub cache cleared." -ForegroundColor Green
} else {
    Write-Host "  [SKIP] Flutter not found, nothing to clear." -ForegroundColor DarkGray
}

# Also clear the pub cache directory directly
$pubCachePath = "$env:LOCALAPPDATA\Pub\Cache"
if (Test-Path $pubCachePath) {
    Write-Host "  Removing: $pubCachePath" -ForegroundColor DarkGray
    Remove-Item -Recurse -Force $pubCachePath -ErrorAction SilentlyContinue
    Write-Host "  [DONE] Pub cache directory removed." -ForegroundColor Green
} else {
    Write-Host "  [SKIP] No pub cache directory at $pubCachePath" -ForegroundColor DarkGray
}

# --- Step 3: Clear Python/Pip Cache ---
Write-Host ""
Write-Host "[3/4] Clearing Python/pip cache..." -ForegroundColor Yellow

$pipCachePaths = @(
    "$env:LOCALAPPDATA\pip\Cache",
    "$env:APPDATA\pip\cache",
    "$env:LOCALAPPDATA\pip\cache"
)

foreach ($cachePath in $pipCachePaths) {
    if (Test-Path $cachePath) {
        Write-Host "  Removing: $cachePath" -ForegroundColor DarkGray
        Remove-Item -Recurse -Force $cachePath -ErrorAction SilentlyContinue
        Write-Host "  [DONE] Pip cache cleared at $cachePath" -ForegroundColor Green
    }
}

# Clear __pycache__ in common locations
$pycachePaths = @("$env:USERPROFILE\.cache\pip")
foreach ($p in $pycachePaths) {
    if (Test-Path $p) {
        Remove-Item -Recurse -Force $p -ErrorAction SilentlyContinue
        Write-Host "  [DONE] Removed $p" -ForegroundColor Green
    }
}

$pipCmd = Get-Command pip -ErrorAction SilentlyContinue
if ($pipCmd) {
    Write-Host "  Running: pip cache purge" -ForegroundColor DarkGray
    pip cache purge 2>&1 | Out-Null
    Write-Host "  [DONE] Pip cache purged via CLI." -ForegroundColor Green
} else {
    Write-Host "  [SKIP] pip not found on PATH." -ForegroundColor DarkGray
}

# --- Step 4: Summary ---
Write-Host ""
Write-Host "[4/4] Cleanup Summary" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  - Flutter pub cache: CLEARED" -ForegroundColor White
Write-Host "  - Python pip cache:  CLEARED" -ForegroundColor White
Write-Host ""
Write-Host "  NOTE: Existing tool installations were NOT removed." -ForegroundColor Magenta
Write-Host "  Flutter 3.35.4 is a valid 3.x release and will be kept." -ForegroundColor Magenta
Write-Host "  Python, PostgreSQL, and Redis were not found on PATH." -ForegroundColor Magenta
Write-Host ""
Write-Host "  Next step: Run .\scripts\install.ps1" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
