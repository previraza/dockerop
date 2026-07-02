$ErrorActionPreference = "Stop"

$RepoRaw = if ($env:DOCKEROP_RAW_URL) { $env:DOCKEROP_RAW_URL } else { "https://raw.githubusercontent.com/previraza/dockerop/main" }
$InstallDir = if ($env:DOCKEROP_INSTALL_DIR) { $env:DOCKEROP_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA "Programs\dockerop" }
$DockeropFile = Join-Path $InstallDir "dockerop"
$CmdFile = Join-Path $InstallDir "dockerop.cmd"
$VersionUrl = "$RepoRaw/VERSION"

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

Invoke-WebRequest -Uri "$RepoRaw/dockerop" -OutFile $DockeropFile

@"
@echo off
python "%~dp0dockerop" %*
"@ | Set-Content -Path $CmdFile -Encoding ASCII

$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (-not $UserPath) {
  $UserPath = ""
}

$PathParts = $UserPath -split ";" | Where-Object { $_ }
if ($PathParts -notcontains $InstallDir) {
  $NewPath = if ($UserPath) { "$UserPath;$InstallDir" } else { $InstallDir }
  [Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
  $env:Path = "$env:Path;$InstallDir"
  $PathMessage = "path:    added to user PATH"
} else {
  $PathMessage = "path:    already available"
}

try {
  $Version = (Invoke-WebRequest -Uri $VersionUrl -UseBasicParsing).Content.Trim()
} catch {
  $Version = "unknown"
}

$Logo = @'

  _            _
 | |          | |
 __| | ___   ___| | _____ _ __ ___  _ __
 / _` |/ _ \ / __| |/ / _ \ '__/ _ \| '_ \
| (_| | (_) | (__|   <  __/ | | (_) | |_) |
 \__,_|\___/ \___|_|\_\___|_|  \___/| .__/
                                     | |
                                     |_|
'@
Write-Host $Logo
Write-Host "dockerop installed"
Write-Host "version: $Version"
Write-Host "binary:  $CmdFile"
Write-Host $PathMessage
Write-Host "next:    open a new terminal if dockerop is not found"
Write-Host "try:     dockerop --version"
