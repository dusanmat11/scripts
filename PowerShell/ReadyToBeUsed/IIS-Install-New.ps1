Import-Module ServerManager

# Ensure log folder exists
$logFolder = "C:\Temp"
if (-not (Test-Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory | Out-Null
}

# Create log file with timestamp
$logFile = Join-Path $logFolder ("IIS_Install_{0}.log" -f (Get-Date -Format "yyyyMMdd_HHmmss"))

# Start logging
Start-Transcript -Path $logFile -Append | Out-Null

Write-Host "Checking IIS installation status..." -ForegroundColor Cyan

# Define all required IIS and related features
$requiredFeatures = @(
    "Web-Server",
    "Web-Common-Http",
    "Web-Health",
    "Web-Performance",
    "Web-Security",
    "Web-App-Dev",
    "Web-Mgmt-Console",
    "Web-Mgmt-Compat",
    "Web-Scripting-Tools",
    "NET-Framework-Features",
    "NET-WCF-Services45"
)

# Define features that should be uninstalled
$featuresToRemove = @(
    "Web-DAV-Publishing",
    "Web-IP-Security",
    "Web-Includes",
    "Web-WebSockets",
    "NET-Non-HTTP-Activ",
    "NET-WCF-MSMQ-Activation45"
)

# Tracking results
$installedList = @()
$skippedList = @()
$removedList = @()
$failedList = @()

# Check IIS installation
$feature = Get-WindowsFeature -Name Web-Server

if ($feature.Installed) {
    Write-Host "IIS is already installed. Checking for missing components..." -ForegroundColor Yellow
} else {
    Write-Host "IIS is not installed. Installing now..." -ForegroundColor Yellow
}

# Install missing required features
foreach ($featureName in $requiredFeatures) {
    $feature = Get-WindowsFeature -Name $featureName
    if (-not $feature.Installed) {
        Write-Host "Installing feature: $featureName" -ForegroundColor Yellow
        try {
            Add-WindowsFeature -Name $featureName -IncludeAllSubFeature -ErrorAction Stop | Out-Null
            $installedList += $featureName
        } catch {
            Write-Host ("Error installing feature ${featureName}: $_") -ForegroundColor Red
            $failedList += $featureName
        }
    } else {
        $skippedList += $featureName
    }
}

# Remove unwanted features
foreach ($removeFeature in $featuresToRemove) {
    $feature = Get-WindowsFeature -Name $removeFeature
    if ($feature -and $feature.Installed) {
        Write-Host "Removing unwanted feature: $removeFeature" -ForegroundColor DarkYellow
        try {
            Uninstall-WindowsFeature -Name $removeFeature -ErrorAction Stop | Out-Null
            $removedList += $removeFeature
        } catch {
            Write-Host ("Error removing feature ${removeFeature}: $_") -ForegroundColor Red
            $failedList += $removeFeature
        }
    }
}

# Verify final IIS installation
if ((Get-WindowsFeature -Name Web-Server).Installed) {
    Write-Host "IIS and all required components are installed and verified." -ForegroundColor Green
} else {
    Write-Host "IIS installation failed or incomplete." -ForegroundColor Red
    $failedList += "Web-Server"
}

# Print summary
Write-Host "`n-----------------------------"
Write-Host "Installation Summary"
Write-Host "-----------------------------"
Write-Host ("Installed features: " + ($installedList -join ", ")) -ForegroundColor Green
Write-Host ("Skipped (already installed): " + ($skippedList -join ", ")) -ForegroundColor Cyan
Write-Host ("Removed features: " + ($removedList -join ", ")) -ForegroundColor DarkYellow
if ($failedList.Count -gt 0) {
    Write-Host ("Failed actions: " + ($failedList -join ", ")) -ForegroundColor Red
} else {
    Write-Host "No failures detected." -ForegroundColor Green
}

Write-Host "`nLog saved to: $logFile" -ForegroundColor Cyan

# Stop logging
Stop-Transcript | Out-Null
