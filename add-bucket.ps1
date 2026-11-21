<#
.SYNOPSIS
    Installs Scoop (if missing), installs git through Scoop (if missing),
    and adds the Jonas8272 bucket.

.NOTES
    Run in a normal (non-admin) PowerShell window. Scoop's installer refuses to
    run elevated unless you pass extra flags.
#>

$ErrorActionPreference = 'Stop'

$BucketName = 'Jonas8272'
$BucketUrl  = 'https://codefloe.com/Jonas8272/scoop-bucket'

function Test-Command($name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

# 1. Scoop -------------------------------------------------------------------
if (-not (Test-Command 'scoop')) {
    Write-Host 'Scoop not found. Installing Scoop...' -ForegroundColor Cyan
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression

    # Make scoop available in this session without reopening PowerShell
    $env:PATH = "$env:USERPROFILE\scoop\shims;$env:PATH"

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
    $env:PATH = "$env:USERPROFILE\scoop\shims;$env:PATH"
} else {
    Write-Host 'git is already installed.' -ForegroundColor Green
}

# 3. Bucket ------------------------------------------------------------------
$existing = scoop bucket list | Where-Object {
    $_.Name -eq $BucketName -or $_.Source -like '*Jonas8272/scoop-bucket*'
}

if ($existing) {
    Write-Host "Bucket '$($existing.Name)' is already added." -ForegroundColor Green
} else {
    Write-Host "Adding bucket '$BucketName'..." -ForegroundColor Cyan
    scoop bucket add $BucketName $BucketUrl
    if ($LASTEXITCODE -ne 0) { throw "Failed to add bucket '$BucketName'." }
}

Write-Host ''
Write-Host 'Done. Install an app with, for example:' -ForegroundColor Green
Write-Host "  scoop install $BucketName/mornye"
Write-Host "  scoop install $BucketName/socialstreamninja"