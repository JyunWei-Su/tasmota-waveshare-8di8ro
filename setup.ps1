#!/usr/bin/env pwsh
# setup.ps1 – creates and pushes JyunWei-Su/tasmota-waveshare-8di8ro to GitHub
# Prerequisites: git + GitHub CLI (gh)  →  https://cli.github.com/
# Run from the folder that CONTAINS this script.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$REPO = "JyunWei-Su/tasmota-waveshare-8di8ro"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "`n=== tasmota-waveshare-8di8ro setup ===" -ForegroundColor Cyan

# 1. Ensure gh is available and authenticated
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI (gh) not found. Install from https://cli.github.com/ then run 'gh auth login'."
    exit 1
}
Write-Host "[ ] Checking gh auth..." -NoNewline
$authCheck = & gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host " not logged in. Running 'gh auth login'..."
    & gh auth login
    if ($LASTEXITCODE -ne 0) { throw "gh auth login failed" }
} else {
    Write-Host " OK" -ForegroundColor Green
}

# 2. Create the GitHub repo (public, with description)
Write-Host "[ ] Creating repo $REPO..." -NoNewline
$ErrorActionPreference = "Continue"
$existing = gh repo view $REPO 2>&1
$repoExists = ($LASTEXITCODE -eq 0)
$ErrorActionPreference = "Stop"
if ($repoExists) {
    Write-Host " already exists, skipping create." -ForegroundColor Yellow
} else {
    gh repo create $REPO `
        --public `
        --description "Custom Tasmota firmware for Waveshare ESP32-S3-ETH-8DI-8RO / POE – auto-built on new upstream releases" `
        --clone=false
    Write-Host " created" -ForegroundColor Green
}

# 3. Init local git repo and push
Push-Location $SCRIPT_DIR
if (-not (Test-Path ".git")) {
    git init -b main
}

# Ensure git identity is set (use GitHub account info)
$gitEmail = & gh api user --jq .email 2>$null
if (-not $gitEmail) { $gitEmail = "jeremy159258357@gmail.com" }
$gitName  = & gh api user --jq .login 2>$null
if (-not $gitName)  { $gitName  = "JyunWei-Su" }
git config user.email $gitEmail
git config user.name  $gitName

git add -A
$ErrorActionPreference = "Continue"
git commit -m "Initial: user_config_override.h + CI workflow for Waveshare 8DI-8RO" 2>&1 | Out-Null
$ErrorActionPreference = "Stop"

$ErrorActionPreference = "Continue"
$remote = git remote get-url origin 2>&1
if ($LASTEXITCODE -ne 0) {
    git remote add origin "https://github.com/$REPO.git"
}
$ErrorActionPreference = "Stop"

Write-Host "[ ] Pushing to GitHub..." -NoNewline
git push -u origin main --force
Write-Host " done" -ForegroundColor Green

Pop-Location

Write-Host "`nRepo live at: https://github.com/$REPO" -ForegroundColor Cyan
Write-Host "The Actions workflow will fire daily; you can also trigger it manually:"
Write-Host "  gh workflow run auto-build.yml --repo $REPO"
