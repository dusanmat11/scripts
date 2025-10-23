# ===============================
# Export IIS Application Pool Settings
# ===============================

Import-Module WebAdministration

# --- Configuration ---
# Folder where JSON files will be saved
$exportFolder = "C:\Temp\IIS_AppPools_Export"
if (-not (Test-Path $exportFolder)) { New-Item -Path $exportFolder -ItemType Directory | Out-Null }

# Get all websites
$sites = Get-Website

foreach ($site in $sites) {
    $appPoolName = $site.ApplicationPool
    $appPoolPath = "IIS:\AppPools\$appPoolName"

    # Check if app pool exists
    if (Test-Path $appPoolPath) {
        $appPool = Get-Item $appPoolPath

        # Convert app pool settings to JSON
        $json = $appPool | Select-Object * | ConvertTo-Json -Depth 5

        # Save to file
        $fileName = "$exportFolder\$appPoolName.json"
        $json | Out-File -FilePath $fileName -Encoding UTF8

        Write-Host "Exported app pool '$appPoolName' to $fileName"
    } else {
        Write-Warning "App pool '$appPoolName' for site '$($site.Name)' does not exist."
    }
}

Write-Host "Export completed for all sites."
