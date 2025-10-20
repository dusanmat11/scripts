# === CONFIGURATION ===
$msiFolder      = "D:\_Delivery\20250814_60th_Delivery\02.IPS®WebApis"   # Adjust as needed
$logFile        = Join-Path $msiFolder "InstallLog.txt"
$processedFile  = Join-Path $msiFolder "processed.txt"

# === FUNCTIONS ===

function Write-Log($message) {
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "[$timestamp] $message"
    Add-Content -Path $logFile -Value $entry
    Write-Host $entry
}

function Get-MsiProductName($msiPath) {
    try {
        $installer = New-Object -ComObject WindowsInstaller.Installer
        $database = $installer.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $null, $installer, @($msiPath, 0))
        $view = $database.OpenView("SELECT Value FROM Property WHERE Property = 'ProductName'")
        $view.Execute()
        $record = $view.Fetch()
        return $record.StringData(1)
    } catch {
        Write-Warning "Could not read ProductName from: $msiPath"
        return $null
    }
}

function Is-ProductInstalled($productName) {
    try {
        $apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* ,
                                HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* `
                                -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -eq $productName }

        return $apps -ne $null
    } catch {
        Write-Warning "Could not check installed products: $_"
        return $false
    }
}

# === Load already processed file list ===
$processed = @()
if (Test-Path $processedFile) {
    $processed = Get-Content $processedFile
}

# === Find MSI Files Recursively ===
$msiFiles = Get-ChildItem -Path $msiFolder -Filter *.msi -Recurse | Where-Object {
    $_.FullName -notin $processed
}

$totalFiles = $msiFiles.Count
$counter = 0

foreach ($msi in $msiFiles) {
    $counter++
    $msiPath = $msi.FullName

    Write-Progress -Activity "Installing MSI files..." `
                   -Status "Processing $($msi.Name) ($counter of $totalFiles)" `
                   -PercentComplete (($counter / $totalFiles) * 100)

    Write-Log "Processing: $msiPath"

    $productName = Get-MsiProductName $msiPath

    if ($null -eq $productName) {
        Write-Log "SKIPPED: Could not read ProductName from $($msi.Name)"
        Add-Content -Path $processedFile -Value $msiPath
        continue
    }

    if (Is-ProductInstalled $productName) {
        Write-Log "SKIPPED: Already installed - $productName"
        Add-Content -Path $processedFile -Value $msiPath
        continue
    }

    # Install the MSI silently
    Write-Log "Installing: $productName"
    Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`" /quiet /norestart" -Wait

    if ($LASTEXITCODE -eq 0) {
        Write-Log "SUCCESS: Installed $productName"
    } else {
        Write-Log "ERROR: Failed to install $productName (Exit code: $LASTEXITCODE)"
    }

    # Mark as processed
    Add-Content -Path $processedFile -Value $msiPath
}

Write-Progress -Activity "Installing MSI files..." -Completed
Write-Log "All MSI files processed."
