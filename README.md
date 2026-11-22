# Jonas8272 Scoop Bucket

A custom [Scoop](https://scoop.sh/) bucket maintained by Jonas8272.

## Installation

### 1. Install Scoop

If you haven't installed Scoop yet, open PowerShell and run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex
```

### 2. Add the bucket

```powershell
scoop bucket add Jonas8272 https://codefloe.com/Jonas8272/scoop-bucket
```

### 3. Verify installation

```powershell
scoop bucket list
```

You should see `Jonas8272` in the list of installed buckets.

## Installation with a script (alternative)

Instead of the manual steps above, a script can install Scoop, install git through Scoop, and add the bucket for you. Run it in a normal (non-admin) PowerShell window:

```powershell
irm https://codefloe.com/Jonas8272/scoop-bucket/raw/branch/master/add-bucket.ps1 | iex
```

### Install every app in the bucket

This does the same setup and then installs all the apps listed below:

```powershell
irm https://codefloe.com/Jonas8272/scoop-bucket/raw/branch/master/installations/install-all.ps1 | iex
```

Apps that need administrator rights (FxSound and VMware Workstation Pro) are skipped unless you run it from an elevated PowerShell. To choose which apps to install, download the script and pass `-Only` or `-Exclude`:

```powershell
irm https://codefloe.com/Jonas8272/scoop-bucket/raw/branch/master/installations/install-all.ps1 -OutFile install-all.ps1
.\install-all.ps1 -Exclude fxsound,vmware-workstation-pro
.\install-all.ps1 -Only mornye,socialstreamninja
```

### Install a single app with a script

Every app also has its own script (`install-<app>.ps1`) in the [`installations`](installations) folder. It does the same setup as above (Scoop, git and the bucket, only if missing) and then installs just that app. The one-liner for each app is in its section below. Run it in a normal (non-admin) PowerShell window, except for FxSound and VMware Workstation Pro, which need an elevated one.

> **Tip:** Read a script before you run it. All scripts are in the `installations` folder of this repository.

## Installing Mornye

Open-source desktop music player for your personal library.

```powershell
scoop install Jonas8272/mornye
```

Or set up everything and install it with one script:

```powershell
irm https://codefloe.com/Jonas8272/scoop-bucket/raw/branch/master/installations/install-mornye.ps1 | iex
```

## Installing socialstreamninja

Combines live chat from many platforms into one stream for OBS overlays (desktop app).

```powershell
scoop install Jonas8272/socialstreamninja
```

Or set up everything and install it with one script:

```powershell
irm https://codefloe.com/Jonas8272/scoop-bucket/raw/branch/master/installations/install-socialstreamninja.ps1 | iex
```

## Installing bewidgets

Desktop widgets for Windows: clock, weather, photos and app shortcuts.

```powershell
scoop install Jonas8272/bewidgets
```

Or set up everything and install it with one script:

```powershell
irm https://codefloe.com/Jonas8272/scoop-bucket/raw/branch/master/installations/install-bewidgets.ps1 | iex
```

> **Note:** This one is installed from the Microsoft Store through winget. The Store updates it, not `scoop update`.

## Installing fxsound

Open-source audio enhancer with an equalizer, effects and presets.

```powershell
scoop install Jonas8272/fxsound
```

Or set up everything and install it with one script (from an elevated PowerShell):

```powershell
irm https://codefloe.com/Jonas8272/scoop-bucket/raw/branch/master/installations/install-fxsound.ps1 | iex
```

> **Note:** FxSound installs an audio driver, so run PowerShell as administrator for this one. The script stops with a message if it is not elevated.

## Installing wintoys

Free tool to debloat, tweak and repair Windows: manage apps and services, and change privacy, ads and performance settings in one place.

```powershell
scoop install Jonas8272/wintoys
```

Or set up everything and install it with one script:

```powershell
irm https://codefloe.com/Jonas8272/scoop-bucket/raw/branch/master/installations/install-wintoys.ps1 | iex
```

> **Note:** This one is installed from the Microsoft Store through winget. The Store updates it, not `scoop update`.

## Installing Netflix

The Netflix app for Windows, for watching movies and TV shows.

```powershell
scoop install Jonas8272/netflix
```

Or set up everything and install it with one script:

```powershell
irm https://codefloe.com/Jonas8272/scoop-bucket/raw/branch/master/installations/install-netflix.ps1 | iex
```

> **Note:** This one is installed from the Microsoft Store through winget. The Store updates it, not `scoop update`.

## Installing Edge

The Microsoft Edge browser.

```powershell
scoop install Jonas8272/edge
```

Or set up everything and install it with one script:

```powershell
irm https://codefloe.com/Jonas8272/scoop-bucket/raw/branch/master/installations/install-edge.ps1 | iex
```

> **Note:** This one is installed through winget. Edge is already built into Windows, so this usually just reports that it is installed. Edge updates itself, not `scoop update`.

## Installing vmware-workstation-pro

VMware Workstation Pro 26H1u1 (build 25688693): run virtual machines on Windows.

```powershell
scoop install Jonas8272/vmware-workstation-pro
```

Or set up everything and install it with one script (from an elevated PowerShell):

```powershell
irm https://codefloe.com/Jonas8272/scoop-bucket/raw/branch/master/installations/install-vmware-workstation-pro.ps1 | iex
```

> **Note:** VMware installs drivers and virtual network adapters, so run PowerShell as administrator for this one. The script stops with a message if it is not elevated, and you may need to restart Windows afterwards.

> **Note:** The installer (about 267 MB) is downloaded from the [`vmwareworkstationarchive`](https://archive.org/details/vmwareworkstationarchive) item on archive.org, a third-party upload of Broadcom's installer. The download is checked against a pinned SHA-256 hash, and the file's digital signature was verified as Broadcom Inc. VMware is proprietary software, so Broadcom's licence terms apply.

> **Note:** There is no autoupdate for this one. New builds only appear in that archive when its owner uploads them, so the version, URL and hash in `bucket/vmware-workstation-pro.json` are updated by hand.

## Updating

Update Scoop and its bucket manifests:

```powershell
scoop update
```

Update all installed applications:

```powershell
scoop update *
```

## Uninstallation

To remove this bucket from Scoop:

```powershell
scoop bucket rm Jonas8272
```

> **Note:** Removing the bucket does not automatically uninstall applications previously installed from it.

## Useful links

- [Scoop website](https://scoop.sh/)
- [Scoop documentation](https://github.com/ScoopInstaller/Scoop/wiki)
- [Jonas8272 Scoop Bucket repository](https://codefloe.com/Jonas8272/scoop-bucket)
- [Jonas8272 Scoop Bucket mirror repository (github)](https://github.com/Jonas8274/scoop-bucket)
- [Jonas8272 Scoop Bucket mirror repository (gitea)](https://git.jonas8272.com/Jonas8272/scoop-bucket)
- [Status](https://status.jonas8272.com)

> **Note:** You may want to save the links to the mirrors as they have generally better uptime than codefloe

## License

See the repository for licensing information.
