# Use gh CLI + MinGit portable (no installer needed)
$ErrorActionPreference = "Stop"

# --- gh CLI ---
$ghDir = "$env:TEMP\gh_cli_portable"
$ghExe = "$ghDir\bin\gh.exe"

if (-not (Test-Path $ghExe)) {
    Write-Host "=== Downloading GitHub CLI (portable) ===" -ForegroundColor Cyan
    $resp = Invoke-WebRequest -Uri "https://api.github.com/repos/cli/cli/releases/latest" -UseBasicParsing
    $json = $resp.Content | ConvertFrom-Json
    $tag = $json.tag_name; $ver = $tag.TrimStart('v')
    $zipUrl = "https://github.com/cli/cli/releases/download/$tag/gh_${ver}_windows_amd64.zip"
    $zipPath = "$env:TEMP\gh_cli.zip"
    Write-Host "Downloading $zipUrl ..."
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
    Write-Host "Extracting..."
    Expand-Archive -Path $zipPath -DestinationPath $ghDir -Force
    $inner = Get-ChildItem $ghDir -Directory | Select-Object -First 1
    if ($inner -and -not (Test-Path "$ghDir\bin")) {
        Get-ChildItem $inner.FullName | Move-Item -Destination $ghDir -Force
        Remove-Item $inner.FullName -Recurse -Force
    }
    Write-Host "=== GitHub CLI ready ===" -ForegroundColor Green
}

# --- MinGit (portable git) ---
$gitDir = "$env:TEMP\mingit_portable"
$gitExe = "$gitDir\cmd\git.exe"

if (-not (Test-Path $gitExe)) {
    Write-Host "=== Downloading MinGit (portable git) ===" -ForegroundColor Cyan
    $resp = Invoke-WebRequest -Uri "https://api.github.com/repos/git-for-windows/git/releases/latest" -UseBasicParsing
    $json = $resp.Content | ConvertFrom-Json
    # Find MinGit 64-bit zip asset
    $asset = $json.assets | Where-Object { $_.name -match "^MinGit-.*-64-bit\.zip$" } | Select-Object -First 1
    if (-not $asset) {
        # Fallback: find any MinGit zip
        $asset = $json.assets | Where-Object { $_.name -match "MinGit.*zip" } | Select-Object -First 1
    }
    $gitZipUrl = $asset.browser_download_url
    $gitZipPath = "$env:TEMP\mingit.zip"
    Write-Host "Downloading $gitZipUrl ..."
    Invoke-WebRequest -Uri $gitZipUrl -OutFile $gitZipPath -UseBasicParsing
    Write-Host "Extracting..."
    Expand-Archive -Path $gitZipPath -DestinationPath $gitDir -Force
    Write-Host "=== MinGit ready ===" -ForegroundColor Green
}

# Add both to PATH for this session
$env:PATH = "$ghDir\bin;$gitDir\cmd;$gitDir\bin;" + $env:PATH

& $ghExe --version
& $gitExe --version

# Ensure token has 'workflow' scope for pushing Actions files
Write-Host "=== Ensuring workflow scope ===" -ForegroundColor Cyan
& $ghExe auth refresh --scopes "repo,workflow" --hostname github.com

Write-Host ""
Write-Host "=== Running setup ===" -ForegroundColor Cyan
& "$PSScriptRoot\setup.ps1"
