<#
.SYNOPSIS
    Installs Mica For Everyone from the Jonas8272 bucket. Sets up Scoop, git and
    the bucket first if they are missing.

.DESCRIPTION
    Mica For Everyone is installed from the Microsoft Store through winget, so
    winget must be available (it ships with current Windows 10 and 11 as App
    Installer). The app itself needs Windows 11. The Store updates it, not
    "scoop update".

.EXAMPLE
    irm https://codefloe.com/Jonas8272/scoop-bucket/raw/branch/master/installations/install-mica-for-everyone.ps1 | iex

.NOTES
    Run in a normal (non-admin) PowerShell window if Scoop is not installed yet.
#>

$ErrorActionPreference = 'Stop'

$App        = 'mica-for-everyone'
$BucketName = 'Jonas8272'
$BucketUrl  = 'https://codefloe.com/Jonas8272/scoop-bucket'

function Test-Command($name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$scoopRoot = if ($env:SCOOP) { $env:SCOOP } else { Join-Path $env:USERPROFILE 'scoop' }

# 0. winget (the app comes from the Microsoft Store) --------------------------
if (-not (Test-Command 'winget')) {
    throw 'winget was not found. Install "App Installer" from the Microsoft Store, then run this script again.'
}

if ([Environment]::OSVersion.Version.Build -lt 22000) {
    Write-Warning 'Mica For Everyone is made for Windows 11. It may not install or do anything on Windows 10.'
}

# 1. Scoop -------------------------------------------------------------------
if (-not (Test-Command 'scoop')) {
    Write-Host 'Scoop not found. Installing Scoop...' -ForegroundColor Cyan
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    if (Test-Admin) {
        Invoke-Expression "& {$(Invoke-RestMethod -Uri 'https://get.scoop.sh')} -RunAsAdmin"
    } else {
        Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
    }

    # Make scoop available in this session without reopening PowerShell
    $env:PATH = "$scoopRoot\shims;$env:PATH"

    if (-not (Test-Command 'scoop')) {
        throw 'Scoop was installed but is not on PATH. Open a new PowerShell window and run this script again.'
    }
} else {
    Write-Host 'Scoop is already installed.' -ForegroundColor Green
}

# 2. git (needed to add buckets) ----------------------------------------------
if (-not (Test-Command 'git')) {
    Write-Host 'git not found. Installing git through Scoop...' -ForegroundColor Cyan
    scoop install git
    if ($LASTEXITCODE -ne 0) { throw 'Failed to install git through Scoop.' }
    $env:PATH = "$scoopRoot\shims;$env:PATH"
} else {
    Write-Host 'git is already installed.' -ForegroundColor Green
}

# 3. Bucket ------------------------------------------------------------------
$existing = scoop bucket list | Where-Object {
    $_.Name -eq $BucketName -or $_.Source -like '*Jonas8272/scoop-bucket*'
} | Select-Object -First 1

if ($existing) {
    $BucketName = $existing.Name
    Write-Host "Bucket '$BucketName' is already added. Updating it..." -ForegroundColor Green
    scoop update
} else {
    Write-Host "Adding bucket '$BucketName'..." -ForegroundColor Cyan
    scoop bucket add $BucketName $BucketUrl
    if ($LASTEXITCODE -ne 0) { throw "Failed to add bucket '$BucketName'." }
}

# 4. The app -----------------------------------------------------------------
Write-Host ''
Write-Host "Installing $App..." -ForegroundColor Cyan
scoop install "$BucketName/$App"
if ($LASTEXITCODE -ne 0) { throw "Failed to install $App." }

Write-Host ''
Write-Host "Done. $App is installed." -ForegroundColor Green
