<#
.SYNOPSIS
    Installs VMware Workstation Pro from the Jonas8272 bucket. Sets up Scoop,
    git and the bucket first if they are missing.

.DESCRIPTION
    VMware Workstation installs drivers and virtual network adapters, so this
    script must be run from an elevated PowerShell (right-click PowerShell,
    then "Run as administrator"). A reboot is probably needed afterwards.
    If Scoop is not installed yet, it is installed in admin mode.

    The installer (about 267 MB) is downloaded from the vmwareworkstationarchive
    item on archive.org and checked against a pinned SHA-256 hash.

.EXAMPLE
    irm https://codefloe.com/Jonas8272/scoop-bucket/raw/branch/master/installations/install-vmware-workstation-pro.ps1 | iex
#>

$ErrorActionPreference = 'Stop'

$App        = 'vmware-workstation-pro'
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

# 0. Administrator rights (VMware installs drivers) ---------------------------
if (-not (Test-Admin)) {
    Write-Warning 'VMware Workstation installs drivers and network adapters, so this needs an elevated PowerShell. Right-click PowerShell, choose "Run as administrator", then run this script again.'
    return
}

# 1. Scoop -------------------------------------------------------------------
if (-not (Test-Command 'scoop')) {
    Write-Host 'Scoop not found. Installing Scoop...' -ForegroundColor Cyan
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-Expression "& {$(Invoke-RestMethod -Uri 'https://get.scoop.sh')} -RunAsAdmin"

    # Make scoop available in this session without reopening PowerShell
    $env:PATH = "$scoopRoot\shims;$env:PATH"

    if (-not (Test-Command 'scoop')) {
        throw 'Scoop was installed but is not on PATH. Open a new PowerShell window and run this script again.'
    }
} else {
    Write-Host 'Scoop is already installed.' -ForegroundColor Green
}

# 2. git (needed to add buckets) ---------------------------------------------
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
Write-Host "Installing $App (about 267 MB download)..." -ForegroundColor Cyan
scoop install "$BucketName/$App"
if ($LASTEXITCODE -ne 0) { throw "Failed to install $App." }

Write-Host ''
Write-Host "Done. $App is installed. Restart Windows if VMware asks for it." -ForegroundColor Green
