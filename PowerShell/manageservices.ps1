# Define the patterns to match service names
$patterns = @("*WebApiService*", "*WebApi193Service*")

# Define the output directory and file path
$outputDir = "C:\Temp\automation\output"    # Change if this is running on a different machine or if a different file path is needed

# Ensure the output directory exists
if (-not (Test-Path -Path $outputDir)) {
    Write-Output "Creating directory $outputDir..."
    New-Item -Path $outputDir -ItemType Directory -Force
}

# Function to get the path of the executable associated with a service
function Get-ServiceExecutablePath {
    param (
        [string]$serviceName
    )

    try {
        # Get the service object using WMI
        $service = Get-WmiObject -Class Win32_Service -Filter "Name='$serviceName'"
        if ($service) {
            # Return the executable path of the service
            return $service.PathName
        } else {
            return "Service not found."
        }
    } catch {
        return "Error retrieving path: $_"
    }
}

# Function to list and display services based on patterns
function List-Services {
    $services = Get-Service | Where-Object {
        $match = $false
        foreach ($pattern in $patterns) {
            if ($_.Name -like $pattern) {
                $match = $true
                break
            }
        }
        $match
    }

    $serviceDetails = @()

    if ($services.Count -gt 0) {
        Write-Output "Services matching the patterns:"
        foreach ($service in $services | Sort-Object Name) {
            Write-Output "Service Name: $($service.Name)"
            Write-Output "Display Name: $($service.DisplayName)"
            Write-Output "Status: $($service.Status)"
            
            # Get and display the executable path
            $executablePath = Get-ServiceExecutablePath -serviceName $service.Name
            Write-Output "Executable Path: $executablePath"
            Write-Output "----------------------------------------"
            
            $serviceDetails += [pscustomobject]@{
                "Service Name" = $service.Name
                "Display Name" = $service.DisplayName
                "Status" = $service.Status
                "Executable Path" = $executablePath
            }
        }

        return $serviceDetails
    } else {
        Write-Output "No services found with the patterns."
        return $null
    }
}

# Function to start services based on patterns
function Start-Services {
    $services = List-Services
    if ($services) {
        foreach ($service in $services) {
            if ($service.Status -ne 'Running') {
                if ([string]::IsNullOrWhiteSpace($service.'Service Name')) {
                    Write-Output "Service name is null or empty. Skipping..."
                    continue
                }
                
                Write-Output "Starting service '$($service.'Service Name')'..."
                try {
                    Start-Service -Name $service.'Service Name' -ErrorAction Stop
                    Write-Output "Service '$($service.'Service Name')' started successfully."
                } catch {
                    Write-Output "Failed to start service '$($service.'Service Name')': $_"
                }
            } else {
                Write-Output "Service '$($service.'Service Name')' is already running."
            }
        }
    }
}

# Function to stop services based on patterns
function Stop-Services {
    $services = List-Services
    if ($services) {
        foreach ($service in $services) {
            if ($service.Status -ne 'Stopped') {
                if ([string]::IsNullOrWhiteSpace($service.'Service Name')) {
                    Write-Output "Service name is null or empty. Skipping..."
                    continue
                }
                
                Write-Output "Stopping service '$($service.'Service Name')'..."
                try {
                    Stop-Service -Name $service.'Service Name' -ErrorAction Stop
                    Write-Output "Service '$($service.'Service Name')' stopped successfully."
                } catch {
                    Write-Output "Failed to stop service '$($service.'Service Name')': $_"
                }
            } else {
                Write-Output "Service '$($service.'Service Name')' is already stopped."
            }
        }
    }
}

# Function to export service details to a file
function Export-ServiceDetails {
    $serviceDetails = List-Services
    if ($serviceDetails) {
        $outputFile = Join-Path -Path $outputDir -ChildPath "ServiceDetails_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
        $serviceDetails | Out-File -FilePath $outputFile -Encoding UTF8
        Write-Output "Service details exported to $outputFile"
    }
}

# Function to check the status of services based on patterns with optional limit and non-null names
function Check-ServiceStatus {
    $services = List-Services
    if ($services) {
        $limit = Read-Host "Enter the number of services to display (7 for all): "
        if (-not [int]::TryParse($limit, [ref]$limit)) {
            Write-Output "Invalid input. Displaying all services."
            $limit = 0
        }

        if ($limit -lt 0) {
            Write-Output "Invalid number. Displaying all services."
            $limit = 0
        }

        if ($limit -eq 0 -or $limit -gt $services.Count) {
            $limit = $services.Count
        }

        Write-Output "Current status of services:"
        $services | Where-Object { -not [string]::IsNullOrWhiteSpace($_.'Service Name') } | Select-Object -First $limit | ForEach-Object {
            Write-Output "Service Name: $($_.'Service Name')"
            Write-Output "Status: $($_.Status)"
            Write-Output "----------------------------------------"
        }
    }
}

# Main menu
function Show-Menu {
    while ($true) {
        Write-Output "Select an option:"
        Write-Output "1. List Services With Executable Path"
        Write-Output "2. Start Services"
        Write-Output "3. Stop Services"
        Write-Output "4. Export Service Details to File"
        Write-Output "5. Check Service Status"
        Write-Output "6. Exit"
        
        $choice = Read-Host "Enter your choice (1-6)"
        
        switch ($choice) {
            '1' {
                List-Services
            }
            '2' {
                Start-Services
            }
            '3' {
                Stop-Services
            }
            '4' {
                Export-ServiceDetails
            }
            '5' {
                Check-ServiceStatus
            }
            '6' {
                Write-Output "Exiting script."
                exit
            }
            default {
                Write-Output "Invalid choice. Please enter a number between 1 and 6."
            }
        }
        
        # Prompt to continue or exit
        $continue = Read-Host "Do you want to perform another action? (Y/N)"
        if ($continue -ne 'Y' -and $continue -ne 'y') {
            Write-Output "Exiting script."
            exit
        }
    }
}

# Run the menu function
Show-Menu
