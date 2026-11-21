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

## Installing Mornye

Open-source desktop music player for your personal library.

```powershell
scoop install Jonas8272/mornye
```

## Installing socialstreamninja

Combines live chat from many platforms into one stream for OBS overlays (desktop app).

```powershell
scoop install Jonas8272/socialstreamninja
```

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