$ErrorActionPreference = "Stop"

$RepoRaw = if ($env:DOCKEROP_RAW_URL) { $env:DOCKEROP_RAW_URL } else { "https://raw.githubusercontent.com/previraza/dockerop/main" }
$InstallDir = if ($env:DOCKEROP_INSTALL_DIR) { $env:DOCKEROP_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA "Programs\dockerop" }
$DockeropFile = Join-Path $InstallDir "dockerop"
$CmdFile = Join-Path $InstallDir "dockerop.cmd"

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

Invoke-WebRequest -Uri "$RepoRaw/dockerop" -OutFile $DockeropFile

@"
@echo off
python "%~dp0dockerop" %*
"@ | Set-Content -Path $CmdFile -Encoding ASCII

Write-Host "installed $CmdFile"
Write-Host "add to PATH if needed: $InstallDir"
