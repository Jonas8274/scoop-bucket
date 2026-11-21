Jonas8272 Scoop Bucket

A custom Scoop bucket maintained by Jonas8272.

Installation
1. Install Scoop

If you haven't installed Scoop yet, open PowerShell and run:

powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

2. Add the bucket

Run the following command in PowerShell:

powershell
scoop bucket add Jonas8272 https://codefloe.com/Jonas8272/scoop-bucket

3. Verify installation

To verify that the bucket was added successfully:

powershell
scoop bucket list


You should see Jonas8272 in the list of installed buckets.

Installing Applications

To install an application from this bucket, use:

powershell
scoop install Jonas8272/<app-name>


Replace <app-name> with the name of the application manifest available in this bucket.

Updating

Update Scoop and its bucket manifests:

powershell
scoop update


Update all installed applications:

powershell
scoop update *

Uninstallation

To remove this bucket from Scoop:

powershell
scoop bucket rm Jonas8272


Removing the bucket does not automatically uninstall applications previously installed from it.

Useful Links
Scoop Official Website
Scoop Documentation
Jonas8272 Scoop Bucket Repository
License

See the repository for licensing information.