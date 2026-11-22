<#
.SYNOPSIS
    Sets up Scoop, git and the Jonas8272 bucket, then installs the apps in it.

.DESCRIPTION
    1. Installs Scoop if it is missing.
    2. Installs git through Scoop if it is missing.
    3. Adds the Jonas8272 bucket if it is not added yet.
    4. Installs every app found in the bucket, one by one. A failing app does
       not stop the others, and a summary is printed at the end.

    Apps whose manifest needs administrator rights (for example FxSound, which
    installs an audio driver) are skipped unless this is run from an elevated
    PowerShell.

.PARAMETER Only
    Install only these apps (names without the bucket prefix).

.PARAMETER Exclude
    Skip these apps.

.EXAMPLE
    .\install-all.ps1

.EXAMPLE
    .\install-all.ps1 -Exclude fxsound

.EXAMPLE
    .\install-all.ps1 -Only mornye,socialstreamninja

.NOTES
    Run in a normal (non-admin) PowerShell window if Scoop is not installed yet,
    because Scoop's installer refuses to run elevated.
#>

[CmdletBinding()]
param(
    [string[]]$Only = @(),
    [string[]]$Exclude = @()
)

$ErrorActionPreference = 'Stop'

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

# 1. Scoop -------------------------------------------------------------------
if (-not (Test-Command 'scoop')) {
    Write-Host 'Scoop not found. Installing Scoop...' -ForegroundColor Cyan
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression

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
} | Select-Object -First 1

if ($existing) {
    $BucketName = $existing.Name
    Write-Host "Bucket '$BucketName' is already added." -ForegroundColor Green
} else {
    Write-Host "Adding bucket '$BucketName'..." -ForegroundColor Cyan
    scoop bucket add $BucketName $BucketUrl
    if ($LASTEXITCODE -ne 0) { throw "Failed to add bucket '$BucketName'." }
}

# Refresh the bucket so newly added apps are picked up
Write-Host 'Updating Scoop and its buckets...' -ForegroundColor Cyan
scoop update

# 4. Find the apps in the bucket ----------------------------------------------
$root = if ($env:SCOOP) { $env:SCOOP } else { Join-Path $env:USERPROFILE 'scoop' }
$bucketDir = Join-Path $root "buckets\$BucketName\bucket"
if (-not (Test-Path $bucketDir)) {
    $bucketDir = Join-Path $root "buckets\$BucketName"
}
if (-not (Test-Path $bucketDir)) {
    throw "Could not find the bucket folder for '$BucketName' under $root."
}

$manifests = Get-ChildItem -Path $bucketDir -Filter '*.json' -File | Sort-Object Name
if (-not $manifests) {
    throw "No app manifests found in $bucketDir."
}

# 5. Install them ------------------------------------------------------------
$isAdmin = Test-Admin
$results = @()

foreach ($m in $manifests) {
    $app = $m.BaseName

    if ($Only.Count -gt 0 -and $Only -notcontains $app) { continue }
    if ($Exclude -contains $app) { continue }

    $needsAdmin = (Get-Content -Path $m.FullName -Raw) -match 'is_admin'
    if ($needsAdmin -and -not $isAdmin) {
        Write-Warning "$app needs administrator rights. Skipping. Re-run from an elevated PowerShell to include it."
        $results += [pscustomobject]@{ App = $app; Result = 'skipped (needs admin)' }
        continue
    }

    Write-Host ''
    Write-Host "Installing $app..." -ForegroundColor Cyan
    try {
        scoop install "$BucketName/$app"
        if ($LASTEXITCODE -ne 0) { throw "scoop exited with code $LASTEXITCODE" }
        $results += [pscustomobject]@{ App = $app; Result = 'ok' }
    } catch {
        Write-Warning "Failed to install ${app}: $($_.Exception.Message)"
        $results += [pscustomobject]@{ App = $app; Result = "FAILED: $($_.Exception.Message)" }
    }
}

Write-Host ''
Write-Host 'Summary' -ForegroundColor Green
$results | Format-Table -AutoSize
