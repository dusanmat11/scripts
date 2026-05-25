# Folder where the script is located
$scriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Output file
$outputFile = Join-Path $scriptFolder "InstallerVersions.txt"

# Create / overwrite output file
"" | Out-File $outputFile -Encoding UTF8

# Function to get MSI Product Version
function Get-MsiVersion {
    param ([string]$Path)

    try {
        $installer = New-Object -ComObject WindowsInstaller.Installer
        $database = $installer.OpenDatabase($Path, 0)
        $view = $database.OpenView("SELECT Value FROM Property WHERE Property='ProductVersion'")
        $view.Execute()
        $record = $view.Fetch()

        if ($record) {
            return $record.StringData(1)
        } else {
            return "No version info"
        }
    }
    catch {
        return "Unable to read MSI version"
    }
}

# Get EXE and MSI files (FIX)
$files = Get-ChildItem -Path $scriptFolder -File |
         Where-Object { $_.Extension -in ".exe", ".msi" }

foreach ($file in $files) {

    if ($file.Extension -eq ".exe") {
        $version = $file.VersionInfo.FileVersion
        if (-not $version) { $version = "No version info" }
        $type = "EXE"
    }
    else {
        $version = Get-MsiVersion -Path $file.FullName
        $type = "MSI"
    }

    @"
File Name : $($file.Name)
File Type : $type
Version   : $version
Path      : $($file.FullName)
----------------------------------------
"@ | Add-Content -Path $outputFile
}

Write-Host "Done. Output written to: $outputFile"
