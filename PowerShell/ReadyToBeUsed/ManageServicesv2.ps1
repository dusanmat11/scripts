# Define the patterns to match service names
$patterns = @("*WebApiService*", "*WebApi193Service*")

# Define the output directory and ensure it exists
$outputDir = "C:\Temp"    # Change if needed
if (-not (Test-Path -Path $outputDir)) {
    Write-Output "Creating directory $outputDir..."
    New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
}

function Get-MatchingServices {
    param([string[]]$patterns)
    Get-CimInstance -ClassName Win32_Service | Where-Object {
        foreach ($pattern in $patterns) {
            if ($_.Name -like $pattern) { return $true }
        }
        return $false
    } | Sort-Object Name
}

function Get-ServiceExecutablePath {
    param ([string]$serviceName)
    try {
        $service = Get-CimInstance -ClassName Win32_Service -Filter "Name='$serviceName'"
        if ($service) {
            # Clean executable path: remove arguments and quotes
            $exe = $service.PathName
            if ($exe.StartsWith('"')) {
                # Extract quoted part only
                if ($exe -match '^"([^"]+)"') { $exe = $matches[1] }
            } else {
                # Split by space and take first token if no quotes
                $exe = $exe.Split(' ')[0]
            }
            return $exe
        } else {
            return "Service not found."
        }
    } catch {
        return "Error retrieving path: $_"
    }
}

function List-Services {
    param(
        [switch]$ShowOutput = $true
    )
    $services = Get-MatchingServices -patterns $patterns
    if ($services.Count -eq 0) {
        Write-Warning "No services found matching the patterns."
        return $null
    }

    $serviceDetails = @()
    if ($ShowOutput) {
        Write-Host "Services matching the patterns:`n" -ForegroundColor Cyan
    }

    for ($i = 0; $i -lt $services.Count; $i++) {
        $svc = $services[$i]
        $exePath = Get-ServiceExecutablePath -serviceName $svc.Name

        if ($ShowOutput) {
            Write-Host "$($i+1). Service Name: $($svc.Name)" -ForegroundColor Green
            Write-Host "   Display Name: $($svc.DisplayName)"
            Write-Host "   Status: $($svc.State)"
            Write-Host "   Executable Path: $exePath"
            Write-Host ("-" * 40)
        }

        $serviceDetails += [pscustomobject]@{
            "Index"          = $i + 1
            "Service Name"   = $svc.Name
            "Display Name"   = $svc.DisplayName
            "Status"         = $svc.State
            "Executable Path"= $exePath
        }
    }

    return $serviceDetails
}

function Start-Services {
    param (
        [Parameter(Mandatory=$true)]
        [array]$services
    )
    foreach ($service in $services) {
        if ($service.Status -ne 'Running') {
            if ([string]::IsNullOrWhiteSpace($service.'Service Name')) {
                Write-Warning "Service name is null or empty. Skipping..."
                continue
            }
            Write-Host "Starting service '$($service.'Service Name')'..." -ForegroundColor Cyan
            try {
                Start-Service -Name $service.'Service Name' -ErrorAction Stop
                Write-Host "Service '$($service.'Service Name')' started successfully." -ForegroundColor Green
            } catch {
                Write-Warning "Failed to start service '$($service.'Service Name')': $_"
            }
        } else {
            Write-Host "Service '$($service.'Service Name')' is already running." -ForegroundColor Yellow
        }
    }
}

function Stop-Services {
    param (
        [Parameter(Mandatory=$true)]
        [array]$services
    )
    foreach ($service in $services) {
        if ($service.Status -ne 'Stopped') {
            if ([string]::IsNullOrWhiteSpace($service.'Service Name')) {
                Write-Warning "Service name is null or empty. Skipping..."
                continue
            }
            Write-Host "Stopping service '$($service.'Service Name')'..." -ForegroundColor Cyan
            try {
                Stop-Service -Name $service.'Service Name' -ErrorAction Stop
                Write-Host "Service '$($service.'Service Name')' stopped successfully." -ForegroundColor Green
            } catch {
                Write-Warning "Failed to stop service '$($service.'Service Name')': $_"
            }
        } else {
            Write-Host "Service '$($service.'Service Name')' is already stopped." -ForegroundColor Yellow
        }
    }
}

function Export-ServiceDetails {
    param (
        [Parameter(Mandatory=$true)]
        [array]$services
    )
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $outputFile = Join-Path -Path $outputDir -ChildPath "ServiceDetails_$timestamp.txt"

    try {
        $content = @()
        foreach ($svc in $services) {
            # Get executable path
            $exePath = $svc.'Executable Path'
            $version = "N/A"

            # Try to get version info if executable exists
            if ($exePath -and (Test-Path -Path $exePath)) {
                try {
                    $fileVersionInfo = (Get-Item $exePath).VersionInfo
                    $version = $fileVersionInfo.FileVersion
                } catch {
                    $version = "Error retrieving version"
                }
            }

            $content += "Service Name   : $($svc.'Service Name')"
            $content += "Display Name   : $($svc.'Display Name')"
            $content += "Status         : $($svc.Status)"
            $content += "Executable Path: $exePath"
            $content += "Version        : $version"
            $content += "-" * 40
        }
        $content | Out-File -FilePath $outputFile -Encoding UTF8
        Write-Host "Service details exported to $outputFile" -ForegroundColor Green
    } catch {
        Write-Warning "Failed to export service details: $_"
    }
}

function Check-ServiceStatus {
    param (
        [Parameter(Mandatory=$true)]
        [array]$services
    )
    if (-not $services) { return }

    do {
        $input = Read-Host "Enter the number of services to display (type 'all' or press Enter for all)"
        if ([string]::IsNullOrWhiteSpace($input) -or $input.ToLower() -eq 'all') {
            $limit = $services.Count
            break
        }
        elseif ([int]::TryParse($input, [ref]$limit)) {
            if ($limit -gt 0 -and $limit -le $services.Count) {
                break
            } else {
                Write-Host "Please enter a positive number up to $($services.Count), or 'all'." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Invalid input. Please enter a valid number or 'all'." -ForegroundColor Yellow
        }
    } while ($true)

    Write-Host "`nCurrent status of services (showing $limit):" -ForegroundColor Cyan
    $services |
        Select-Object -First $limit |
        ForEach-Object {
            Write-Host "Service Name: $($_.'Service Name')"
            Write-Host "Status: $($_.Status)"
            Write-Host ("-" * 40)
        }
}

function Get-ServiceStartupDisplay {
    param ($ServiceName)
    try {
        $service = Get-CimInstance -ClassName Win32_Service -Filter "Name='$ServiceName'"
        if (-not $service) { return "Not Found" }

        $delayed = 0
        try {
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

function Change-StartupType {
    param (
        [Parameter(Mandatory=$true)]
        [System.Collections.Generic.IEnumerable[object]]$Services
    )

    Write-Host "`nFound $($Services.Count) matching service(s):`n" -ForegroundColor Cyan
    for ($i = 0; $i -lt $Services.Count; $i++) {
        $svc = $Services[$i]
        $displayType = Get-ServiceStartupDisplay -ServiceName $svc.Name
        Write-Host "$($i+1). $($svc.Name) (Current: $displayType)"
    }

    $selectedIndices = Read-Host "`nEnter the numbers of services to configure (comma-separated, or 'all')"
    if ($selectedIndices.ToLower() -eq "all") {
        $selectedServices = $Services
    } else {
        $indices = $selectedIndices -split ',' | ForEach-Object { $_.Trim() }
        $selectedServices = @()
        foreach ($i in $indices) {
            if ($i -match '^\d+$' -and [int]$i -ge 1 -and [int]$i -le $Services.Count) {
                $selectedServices += $Services[[int]$i - 1]
            } else {
                Write-Warning "Invalid selection: $i"
            }
        }
    }

    if ($selectedServices.Count -eq 0) {
        Write-Warning "No valid services selected. Exiting."
        return
    }

    Write-Host "`nSelect startup type:"
    Write-Host "1. Automatic"
    Write-Host "2. Automatic (Delayed Start)"
    Write-Host "3. Manual"
    Write-Host "4. Disabled"
    $startupChoice = Read-Host "Enter your choice (1-4)"

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

    $confirm = Read-Host "Confirm setting startup type '$($startupConfig.Type)' for $($selectedServices.Count) service(s)? (Y/N)"
    if ($confirm.ToUpper() -ne 'Y') {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        return
    }

    foreach ($svc in $selectedServices) {
        Write-Host "Setting startup type of service '$($svc.Name)' to $($startupConfig.Type)..." -ForegroundColor Cyan
        try {
            Set-Service -Name $svc.Name -StartupType $startupConfig.StartMode -ErrorAction Stop
            $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$($svc.Name)"
            if ($startupConfig.StartMode -eq "Automatic") {
                Set-ItemProperty -Path $regPath -Name DelayedAutostart -Value ([int]$startupConfig.Delayed) -ErrorAction Stop
            } else {
                if (Get-ItemProperty -Path $regPath -Name DelayedAutostart -ErrorAction SilentlyContinue) {
                    Remove-ItemProperty -Path $regPath -Name DelayedAutostart -ErrorAction SilentlyContinue
                }
            }
            Write-Host "Startup type set successfully." -ForegroundColor Green
        } catch {
            Write-Warning "Failed to set startup type for service '$($svc.Name)': $_"
        }
    }
}

function Show-Menu {
    do {
        Write-Host "`n===== Manage Services Menu =====" -ForegroundColor Cyan
        Write-Host "1. List all matching services"
        Write-Host "2. Start all stopped matching services"
        Write-Host "3. Stop all running matching services"
        Write-Host "4. Export matching services details to txt"
        Write-Host "5. Check status of services (limited display)"
        Write-Host "6. Change startup type of matching services"
        Write-Host "7. Exit"
        $choice = Read-Host "Enter your choice (1-7)"

        $services = Get-MatchingServices -patterns $patterns
        if (-not $services -or $services.Count -eq 0) {
            Write-Warning "No matching services found."
            if ($choice -ne "7") { continue }
        }

        switch ($choice) {
            "1" {
                List-Services -ShowOutput
            }
            "2" {
                $details = List-Services -ShowOutput:$false
                if ($details) { Start-Services -services $details }
            }
            "3" {
                $details = List-Services -ShowOutput:$false
                if ($details) { Stop-Services -services $details }
            }
            "4" {
                $details = List-Services -ShowOutput:$false
                if ($details) { Export-ServiceDetails -services $details }
            }
            "5" {
                $details = List-Services -ShowOutput:$false
                if ($details) { Check-ServiceStatus -services $details }
            }
            "6" {
                if ($services.Count -gt 0) {
                    Change-StartupType -Services $services
                } else {
                    Write-Warning "No matching services found."
                }
            }
            "7" {
                Write-Host "Exiting script..." -ForegroundColor Cyan
                break
            }
            default {
                Write-Warning "Invalid choice. Please select a valid option (1-7)."
            }
        }
    } while ($true)
}

# Start the menu loop
Show-Menu
