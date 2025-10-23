# Requires Administrator privileges to manage services
# =========================================================================
# SCRIPT CONFIGURATION AND PREREQUISITES
# To target specific services when run script: .\ScriptName.ps1 -Patterns "*ServiceName*"
# =========================================================================

param (
    [Parameter(Mandatory=$false)]
    [string[]]$Patterns = @("*WebApiService*", "*WebApi193Service*")
)

# Enforce Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script must be run as Administrator. Exiting."
    exit 1
}


# Define the output directory and ensure it exists
$outputDir = $PSScriptRoot


# Use Script-scope cache for efficiency
$script:ServiceCache = $null


# =========================================================================
# CORE DATA RETRIEVAL FUNCTION (Advanced Function - Decouples Data from View)
# =========================================================================

# This function consolidates service fetching, path cleanup, and version retrieval.
function Get-TargetServiceDetail {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Patterns,

        # Allows user to bypass the cache and get current state
        [switch]$ForceRefresh
    )
    # ================================================================

    # Caching Logic
    if ($ForceRefresh -or ($script:ServiceCache -eq $null)) {
        Write-Verbose "Querying all services. ForceRefresh: $ForceRefresh"
        
        # Build a WQL filter query from the patterns
        $filterClauses = $Patterns | ForEach-Object {
            # Convert PowerShell wildcard '*' to WQL '%'
            $wqlPattern = $_ -replace '\*', '%'
            "Name LIKE '$wqlPattern'"
        }
        $wqlFilter = $filterClauses -join ' OR '
        Write-Verbose "Using WQL Filter: $wqlFilter"
        
        # Fetch and filter raw CIM objects directly using the filter
        $services = Get-CimInstance -ClassName Win32_Service -Filter $wqlFilter | Sort-Object Name

        if (-not $services) { return $null }
        
        # Store raw CIM objects in the script cache
        $script:ServiceCache = $services
    }

    # Iterate over cached or refreshed services to build rich output objects
    $currentIndex = 1
    foreach ($svc in $script:ServiceCache) {

        # --- Get Executable Path ---
        $exe = $svc.PathName
        if ($exe.StartsWith('"')) {
            # Extract quoted part only
            if ($exe -match '^"([^"]+)"') { $exe = $matches[1] }
        } else {
            # Split by space and take first token if no quotes
            $exe = $exe.Split(' ')[0]
        }
        $exePath = $exe

        # --- Get File Version ---
        $version = "N/A"
        if ($exePath -and (Test-Path -Path $exePath)) {
            try {
                # Using -ErrorAction Stop for clean Try/Catch
                $version = (Get-Item $exePath -ErrorAction Stop).VersionInfo.FileVersion
            } catch {
                $version = "Error retrieving version"
            }
        }
        
        # --- Get Display Startup Type ---
        $displayType = Get-ServiceStartupDisplay -ServiceName $svc.Name
        
        # Output a rich object to the pipeline (The principle of "Objects Out")
        [pscustomobject]@{
            "Index"           = $currentIndex++
            "ServiceName"     = $svc.Name
            "DisplayName"     = $svc.DisplayName
            "Status"          = $svc.State  # Use CIM property here
            "StartupType"     = $displayType
            "ExecutablePath"  = $exePath
            "Version"         = $version
            "RawCimObject"    = $svc # Include the original object for action functions
        }
    }
}


# =========================================================================
# SUPPORT FUNCTIONS
# =========================================================================

function Get-ServiceStartupDisplay {
    param ($ServiceName)
    try {
        $service = Get-CimInstance -ClassName Win32_Service -Filter "Name='$ServiceName'"
        if (-not $service) { return "Not Found" }

        $delayed = 0
        try {
            # Using -ErrorAction Stop for better Try/Catch reliability
            $delayed = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName" -Name "DelayedAutostart" -ErrorAction Stop).DelayedAutostart
        } catch { }

        if ($service.StartMode -eq "Auto" -and $delayed -eq 1) {
            return "Automatic (Delayed Start)"
        }
        elseif ($service.StartMode -eq "Auto") {
            return "Automatic"
        }
        else {
            return $service.StartMode
        }
    }
    catch {
        return "Error checking"
    }
}

# Simplified Refresh Status
function Refresh-ServiceStatus {
    param([string]$ServiceName)
    try {
        # Use Get-Service for a quick status check
        $updatedService = Get-Service -Name $ServiceName -ErrorAction Stop
        return $updatedService.Status
    } catch {
        Write-Warning "Failed to refresh status for service '$ServiceName': $($_.Exception.Message)"
        return "Unknown"
    }
}


# =========================================================================
# ACTION FUNCTIONS
# =========================================================================

function Start-Services {
    [CmdletBinding(SupportsShouldProcess=$true)] # Added WhatIf/Confirm support
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [array]$Services
    )
    
    # Process all input services
    $Services | ForEach-Object {
        $serviceName = $_.ServiceName
        
        if ($_.Status -ne 'Running') {
            if ([string]::IsNullOrWhiteSpace($serviceName)) {
                Write-Warning "Service name is null or empty. Skipping..."
                return
            }
            Write-Host "Starting service '$serviceName'..." -ForegroundColor Cyan
            
            if ($PSCmdlet.ShouldProcess($serviceName, "Start-Service")) {
                try {
                    # Use splatting (cleaner code)
                    $startParams = @{ Name = $serviceName; ErrorAction = 'Stop' }
                    Start-Service @startParams
    
                    # Refresh status
                    $newStatus = Refresh-ServiceStatus -ServiceName $serviceName
                    Write-Host "Service '$serviceName' started successfully. Status: $newStatus" -ForegroundColor Green
                } catch {
                    Write-Warning "Failed to start service '$serviceName': $($_.Exception.Message)"
                }
            }
        } else {
            Write-Host "Service '$serviceName' is already running." -ForegroundColor Yellow
        }
    }
}

function Stop-Services {
    [CmdletBinding(SupportsShouldProcess=$true)] # Added WhatIf/Confirm support
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [array]$Services
    )

    # Process all input services
    $Services | ForEach-Object {
        $serviceName = $_.ServiceName
        
        if ($_.Status -ne 'Stopped') {
            if ([string]::IsNullOrWhiteSpace($serviceName)) {
                Write-Warning "Service name is null or empty. Skipping..."
                return
            }
            Write-Host "Stopping service '$serviceName'..." -ForegroundColor Cyan
            
            if ($PSCmdlet.ShouldProcess($serviceName, "Stop-Service")) {
                try {
                    # Use splatting (cleaner code)
                    $stopParams = @{ Name = $serviceName; ErrorAction = 'Stop' }
                    Stop-Service @stopParams
    
                    # Refresh status
                    $newStatus = Refresh-ServiceStatus -ServiceName $serviceName
                    Write-Host "Service '$serviceName' stopped successfully. Status: $newStatus" -ForegroundColor Green
                } catch {
                    Write-Warning "Failed to stop service '$serviceName': $($_.Exception.Message)"
                }
            }
        } else {
            Write-Host "Service '$serviceName' is already stopped." -ForegroundColor Yellow
        }
    }
}

function Export-ServiceDetails {
    param (
        [Parameter(Mandatory=$true)]
        [array]$Services
    )
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $outputFile = Join-Path -Path $outputDir -ChildPath "ServiceDetails_$timestamp.txt"

    try {
        $content = @()
        foreach ($svc in $Services) {
            $content += "Service Name      : $($svc.ServiceName)"
            $content += "Display Name    : $($svc.DisplayName)"
            $content += "Status          : $($svc.Status)"
            $content += "Startup Type    : $($svc.StartupType)"
            $content += "Executable Path : $($svc.ExecutablePath)"
            $content += "Version         : $($svc.Version)"
            $content += "-" * 40
        }
        $content | Out-File -FilePath $outputFile -Encoding UTF8 -ErrorAction Stop
        Write-Host "Service details exported to $outputFile" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to export service details: $($_.Exception.Message)"
    }
}

function Check-ServiceStatus {
    param (
        [Parameter(Mandatory=$true)]
        [array]$Services
    )
    if (-not $Services) { return }

    do {
        $inputChoice = Read-Host "Enter the number of services to display (type 'all' or press Enter for all)"
        $inputChoice = $inputChoice.Trim() # Input sanitization

        if ([string]::IsNullOrWhiteSpace($inputChoice) -or $inputChoice.ToLower() -eq 'all') {
            $limit = $Services.Count
            break
        }
        elseif ([int]::TryParse($inputChoice, [ref]$limit)) {
            if ($limit -gt 0 -and $limit -le $Services.Count) {
                break
            } else {
                Write-Host "Please enter a positive number up to $($Services.Count), or 'all'." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Invalid input. Please enter a valid number or 'all'." -ForegroundColor Yellow
        }
    } while ($true)

    Write-Host "`nCurrent status of services (showing $limit):" -ForegroundColor Cyan
    $Services |
        Select-Object -First $limit |
        ForEach-Object {
            # Refresh the status property just before displaying
            $status = Refresh-ServiceStatus -ServiceName $_.ServiceName
            
            # ================================================================
            # FIX 3: Changed $_.'ServiceName' to $_.ServiceName
            # ================================================================
            Write-Host "Service Name: $($_.ServiceName)"
            Write-Host "Status: $status"
            Write-Host ("-" * 40)
        }
}


function Change-StartupType {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        # ================================================================
        # FIX 2: Changed type to [array] for consistency
        # ================================================================
        [Parameter(Mandatory=$true)]
        [array]$Services
    )

    # Use the raw CIM objects for configuration, since they contain 'Name' property directly
    $CimServices = $Services | Select-Object -ExpandProperty RawCimObject
    if (-not $CimServices) {
        Write-Warning "Cannot proceed without raw service objects."
        return
    }

    Write-Host "`nFound $($CimServices.Count) matching service(s):`n" -ForegroundColor Cyan
    for ($i = 0; $i -lt $CimServices.Count; $i++) {
        $svc = $CimServices[$i]
        $displayType = Get-ServiceStartupDisplay -ServiceName $svc.Name
        Write-Host "$($i+1). $($svc.Name) (Current: $displayType)"
    }

    $selectedIndices = Read-Host "`nEnter the numbers of services to configure (comma-separated, or 'all')"
    $selectedIndices = $selectedIndices.Trim() # Input sanitization

    if ($selectedIndices.ToLower() -eq "all") {
        $selectedCimServices = $CimServices
    } else {
        $indices = $selectedIndices -split ',' | ForEach-Object { $_.Trim() }
        $selectedCimServices = @()
        foreach ($i in $indices) {
            if ($i -match '^\d+$' -and [int]$i -ge 1 -and [int]$i -le $CimServices.Count) {
                $selectedCimServices += $CimServices[[int]$i - 1]
            } else {
                Write-Warning "Invalid selection: $i"
            }
        }
    }

    if ($selectedCimServices.Count -eq 0) {
        Write-Warning "No valid services selected. Exiting."
        return
    }

    Write-Host "`nSelect startup type:"
    Write-Host "1. Automatic"
    Write-Host "2. Automatic (Delayed Start)"
    Write-Host "3. Manual"
    Write-Host "4. Disabled"
    $startupChoice = Read-Host "Enter your choice (1-4)"
    $startupChoice = $startupChoice.Trim() # Input sanitization

    $startupConfig = switch ($startupChoice) {
        "1" { @{Type = "Automatic"; StartMode = "Automatic"; Delayed = $false} }
        "2" { @{Type = "Automatic (Delayed Start)"; StartMode = "Automatic"; Delayed = $true} }
        "3" { @{Type = "Manual"; StartMode = "Manual"; Delayed = $false} }
        "4" { @{Type = "Disabled"; StartMode = "Disabled"; Delayed = $false} }
        default {
            Write-Warning "Invalid choice. Operation cancelled."
            return
        }
    }

    $confirm = Read-Host "Confirm setting startup type '$($startupConfig.Type)' for $($selectedCimServices.Count) service(s)? (Y/N)"
    if ($confirm.ToUpper() -ne 'Y') {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        return
    }

    foreach ($svc in $selectedCimServices) {
        Write-Host "Setting startup type of service '$($svc.Name)' to $($startupConfig.Type)..." -ForegroundColor Cyan

        if ($PSCmdlet.ShouldProcess($svc.Name, "Set-Service Startup Type to $($startupConfig.Type)")) {
            try {
                # Use splatting for Set-Service
                $setSvcParams = @{
                    Name = $svc.Name
                    StartupType = $startupConfig.StartMode
                    ErrorAction = 'Stop'
                }
                Set-Service @setSvcParams
        
                $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($svc.Name)"
                if ($startupConfig.StartMode -eq "Automatic") {
                    # Use splatting for Set-ItemProperty
                        $setRegParams = @{
                            Path = $regPath
                            Name = "DelayedAutostart"
                            Value = ([int]$startupConfig.Delayed)
                            ErrorAction = 'Stop'
                        }
                    Set-ItemProperty @setRegParams
                } else {
                    # Clean up DelayedAutostart registry value
                    if (Get-ItemProperty -Path $regPath -Name DelayedAutostart -ErrorAction SilentlyContinue) {
                        Remove-ItemProperty -Path $regPath -Name DelayedAutostart -ErrorAction SilentlyContinue
                    }
                }
                Write-Host "Startup type set successfully." -ForegroundColor Green
            } catch {
                Write-Warning "Failed to set startup type for service '$($svc.Name)': $($_.Exception.Message)"
            }
        }
    }
}


# =========================================================================
# MENU LOGIC
# =========================================================================

function Show-Menu {
    do {
        Write-Host "`n===== Manage Services Menu (Updated) =====" -ForegroundColor Cyan
        Write-Host "1. List all matching services (Cached Data)"
        Write-Host "2. Start all stopped matching services"
        Write-Host "3. Stop all running matching services"
        Write-Host "4. Export service details to txt"
        Write-Host "5. Check status of services (live check/limited display)"
        Write-Host "6. Change startup type of matching services"
        Write-Host "R. Refresh all service data (clear cache)"
        Write-Host "7. Exit"
        $choice = Read-Host "Enter your choice (1-7, R)"
        $choice = $choice.Trim().ToUpper()

        # If choice is 'R', clear the cache and continue the loop to re-show the menu
        if ($choice -eq "R") {
            $script:ServiceCache = $null
            Write-Host "Service cache cleared. Please re-run Option 1 to fetch current data." -ForegroundColor Yellow
            continue
        }

        # Get service details (uses cache by default)
        $details = Get-TargetServiceDetail -Patterns $patterns

        if (-not $details -or $details.Count -eq 0) {
            Write-Warning "No matching services found."
            if ($choice -ne "7") { continue }
        }

        switch ($choice) {
            "1" {
                Write-Host "`nAll Matching Services (Cached Details):" -ForegroundColor Cyan
                # Present data using Format-Table for better readability
                $details | Format-Table -Property Index, ServiceName, Status, StartupType, Version -AutoSize
            }
            "2" {
                # Filter for stopped services and pipe them directly to the action function
                $stoppedServices = $details | Where-Object { $_.Status -ne "Running" }
                if ($stoppedServices.Count -eq 0) {
                    Write-Host "No stopped services found to start." -ForegroundColor Yellow
                } else {
                    Start-Services -Services $stoppedServices
                }
            }
            "3" {
                # Filter for running services and pipe them directly to the action function
                $runningServices = $details | Where-Object { $_.Status -eq "Running" }
                if ($runningServices.Count -eq 0) {
                    Write-Host "No running services found to stop." -ForegroundColor Yellow
                } else {
                    Stop-Services -Services $runningServices
                }
            }
            "4" {
                Export-ServiceDetails -Services $details
            }
            "5" {
                Check-ServiceStatus -Services $details
            }
            "6" {
                Change-StartupType -Services $details
            }
            "7" {
                Write-Host "Exiting script... Goodbye!" -ForegroundColor Green
                break
            }
            default {
                Write-Warning "Invalid choice. Please select a valid option (1-7, R)."
            }
        }
    } while ($true)
}

# Start the menu loop
Show-Menu