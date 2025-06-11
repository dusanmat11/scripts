<#
.SYNOPSIS
    Correctly configures services to show "Automatic (Delayed Start)" in services.msc
.DESCRIPTION
    Properly sets both the service startup type and delayed flag to ensure correct display
    in the Windows Services management console.
.NOTES
    Must be run as Administrator
#>

param (
    [string[]]$ServiceNamePatterns = @("*WebApiService*", "*WebApi193Service*")
)

# Function to get accurate startup type display
function Get-ServiceStartupDisplay {
    param ($ServiceName)
    try {
        $service = Get-CimInstance -ClassName Win32_Service -Filter "Name='$ServiceName'"
        if (-not $service) { return "Not Found" }
        
        $delayed = try {
            (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName" -Name "DelayedAutostart" -ErrorAction Stop).DelayedAutostart
        } catch { 0 }
        
        if ($service.StartMode -eq "Auto" -and $delayed -eq 1) {
            "Automatic (Delayed Start)"
        } elseif ($service.StartMode -eq "Auto") {
            "Automatic"
        } else {
            $service.StartMode
        }
    } catch {
        "Error checking"
    }
}

# Get matching services
$services = Get-CimInstance -ClassName Win32_Service | 
            Where-Object { 
                $service = $_
                $ServiceNamePatterns | Where-Object { $service.Name -like $_ }
            } | 
            Sort-Object -Property Name

if ($services.Count -eq 0) {
    Write-Host "No services found matching the specified patterns."
    exit
}

# Display services with current configuration
Write-Host "`nFound $($services.Count) matching service(s):`n"
$index = 1
$services | ForEach-Object {
    Write-Host "$index`. $($_.Name) (Current: $(Get-ServiceStartupDisplay -ServiceName $_.Name))"
    $index++
}

# Get service selection
$selectedIndices = Read-Host "`nEnter the numbers of services to configure (comma-separated, or 'all')"
if ($selectedIndices -eq "all") {
    $selectedServices = $services
} else {
    $selectedIndices = $selectedIndices -split ',' | ForEach-Object { $_.Trim() }
    $selectedServices = @()
    foreach ($i in $selectedIndices) {
        if ($i -match '^\d+$' -and [int]$i -ge 1 -and [int]$i -le $services.Count) {
            $selectedServices += $services[[int]$i - 1]
        } else {
            Write-Warning "Invalid selection: $i"
        }
    }
}

if ($selectedServices.Count -eq 0) {
    Write-Host "No valid services selected. Exiting."
    exit
}

# Get desired configuration
Write-Host "`nSelect startup type:"
Write-Host "1. Automatic"
Write-Host "2. Automatic (Delayed Start)"
Write-Host "3. Manual"
Write-Host "4. Disabled"
$startupChoice = Read-Host "Enter your choice (1-4)"

$startupConfig = switch ($startupChoice) {
    "1" { @{Type = "Automatic"; Delayed = $false}; break }
    "2" { @{Type = "Automatic (Delayed Start)"; Delayed = $true}; break }
    "3" { @{Type = "Manual"; Delayed = $false}; break }
    "4" { @{Type = "Disabled"; Delayed = $false}; break }
    default { 
        Write-Host "Invalid selection. Exiting."
        exit
    }
}

# Show confirmation
Write-Host "`nThe following services will be changed:"
$selectedServices | ForEach-Object {
    Write-Host "- $($_.Name) => $($startupConfig.Type)"
}

$confirmation = Read-Host "`nDo you want to proceed? (Y/N)"
if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
    Write-Host "Operation cancelled by user."
    exit
}

# Apply changes
$successCount = 0
$failedCount = 0

foreach ($service in $selectedServices) {
    try {
        Write-Host "`nConfiguring $($service.Name)..."
        
        # Set the startup type to Automatic (value = 2) regardless of delayed status
        Write-Host "- Setting base startup type to Automatic..."
        $result = Invoke-CimMethod -InputObject $service -MethodName ChangeStartMode -Arguments @{
            StartMode = "Automatic"
        }
        
        if ($result.ReturnValue -ne 0) {
            throw "Failed to change startup type (Error: $($result.ReturnValue))"
        }

        # Set delayed start flag if requested
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($service.Name)"
        if (-not (Test-Path $regPath)) {
            throw "Registry path not found for service"
        }
        
        if ($startupConfig.Delayed) {
            Write-Host "- Enabling Delayed Start flag..."
            Set-ItemProperty -Path $regPath -Name "DelayedAutostart" -Value 1 -Type DWORD -Force
        } else {
            Write-Host "- Disabling Delayed Start flag..."
            Set-ItemProperty -Path $regPath -Name "DelayedAutostart" -Value 0 -Type DWORD -Force
        }
        
        # Verify changes
        Start-Sleep -Milliseconds 500
        $currentDisplay = Get-ServiceStartupDisplay -ServiceName $service.Name
        
        if ($currentDisplay -ne $startupConfig.Type) {
            throw "Verification failed! Current display: $currentDisplay, Expected: $($startupConfig.Type)"
        }
        
        Write-Host "Successfully configured $($service.Name) - now shows as: $currentDisplay"
        $successCount++
    } catch {
        Write-Warning "FAILED to configure $($service.Name): $_"
        $failedCount++
    }
}

# Final instructions
Write-Host "`nOperation complete:"
Write-Host "- Successfully configured: $successCount service(s)"
Write-Host "- Failed to configure: $failedCount service(s)"

if ($successCount -gt 0) {
    Write-Host "`nPlease open services.msc to verify the changes."
    Write-Host "The Startup Type column should now show: $($startupConfig.Type)"
    
    if ($startupConfig.Delayed) {
        Write-Host "`nNote: You may need to refresh services.msc (F5) to see the changes."
    }
}
