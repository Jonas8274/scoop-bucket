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

Apps that need administrator rights (FxSound) are skipped unless you run it from an elevated PowerShell. To choose which apps to install, download the script and pass `-Only` or `-Exclude`:

```powershell
irm https://codefloe.com/Jonas8272/scoop-bucket/raw/branch/master/installations/install-all.ps1 -OutFile install-all.ps1
.\install-all.ps1 -Exclude fxsound
.\install-all.ps1 -Only mornye,socialstreamninja
```

### Install a single app with a script

Every app also has its own script (`install-<app>.ps1`) in the [`installations`](installations) folder. It does the same setup as above (Scoop, git and the bucket, only if missing) and then installs just that app. The one-liner for each app is in its section below. Run it in a normal (non-admin) PowerShell window, except for FxSound, which needs an elevated one.

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
- [Jonas8272 Scoop Bucket mirror repository](https://github.com/Jonas8274/scoop-bucket)

## License

See the repository for licensing information.