# ============================================
# SSL Certificate Management Script (Refactored)
# ============================================

# Configuration
$logFolder = "C:\ProgramData\IPS GmbH\logs"
if (-not (Test-Path $logFolder)) {
    Write-Host "Creating log folder: $logFolder" -ForegroundColor Yellow
    New-Item -Path $logFolder -ItemType Directory | Out-Null
}
$logFile = Join-Path $logFolder "SSLCERT_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# --- Centralized Logging Function ---
function Write-Log {
    param(
        [string]$Message,
        [string]$Type = "INFO"   # INFO, WARNING, ERROR
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "[$timestamp] [$Type] $Message"
    Add-Content -Path $logFile -Value $entry

    switch ($Type) {
        "INFO" { Write-Host $Message -ForegroundColor Green }
        "WARNING" { Write-Host "WARNING: $Message" -ForegroundColor Yellow }
        "ERROR" { Write-Host "ERROR: $Message" -ForegroundColor Red }
        default { Write-Host $Message }
    }
}

# --- Helper Function: Robustly parse netsh output into PowerShell objects ---
function Get-NetshSSLBindings {
    Write-Log "Reading all existing SSL bindings from netsh..." -Type "INFO"
    $netshOutput = netsh http show sslcert

    $bindings = @()
    $currentBinding = $null

    # Regex patterns for key fields (more resilient than simple split)
    $regexBinding = '^(?:IP|Hostname):port\s+:\s+(?<Binding>.+)$'
    $regexHash = '^Certificate Hash\s+:\s+(?<Hash>.+)$'
    $regexAppId = '^Application ID\s+:\s+(?<AppId>.+)$'

    foreach ($line in $netshOutput) {
        $line = $line.Trim()

        if ($line -match $regexBinding) {
            # Start of a new binding entry
            if ($currentBinding) { $bindings += $currentBinding }
            $currentBinding = [PSCustomObject]@{
                Binding = $Matches.Binding.Trim()
                Hash = $null
                AppId = $null
            }
        }
        elseif ($currentBinding) {
            if ($line -match $regexHash) {
                $currentBinding.Hash = $Matches.Hash.Trim()
            }
            elseif ($line -match $regexAppId) {
                $currentBinding.AppId = $Matches.AppId.Trim()
            }
        }
    }
    # Add the last processed binding
    if ($currentBinding) { $bindings += $currentBinding }

    return $bindings
}

# --- Function to save all SSL bindings ---
function Save-SSLCERT {
    $ver = Read-Host "Enter a label for this SSL log (e.g., 'PreChange_2025')"
    if ([string]::IsNullOrWhiteSpace($ver)) { $ver = "ManualSave" }
    
    $savePath = Join-Path $logFolder "$ver`_SSLCERT.txt"
    
    # Use Out-File instead of Transcript for cleaner data (Transcript adds timestamps/metadata)
    netsh http show sslcert | Out-File -FilePath $savePath -Encoding UTF8
    
    Write-Log "All SSL bindings saved to $savePath"
}

# --- Function to view SSL bindings for a hostname ---
function Get-SSLCERT {
    $hostname = Read-Host "Enter the hostname to check (e.g., myserver.local)"
    if ([string]::IsNullOrWhiteSpace($hostname)) {
        Write-Log "Hostname cannot be empty" "ERROR"
        return
    }
    
    $allBindings = Get-NetshSSLBindings
    $matchingBindings = $allBindings | Where-Object { $_.Binding -like "*$hostname*" }

    if (-not $matchingBindings) {
        Write-Log "No SSL bindings found containing '$hostname'" "WARNING"
        return
    }

    Write-Log "SSL bindings found for '$hostname':"
    
    $matchingBindings | Format-Table -AutoSize
    
    Write-Log "Displayed details for all matching bindings."
}

# --- Function to backup current SSL bindings (reused the original logic) ---
function Backup-SSL {
    $backupFile = Join-Path $logFolder "SSLBackup_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    netsh http show sslcert > $backupFile
    Write-Log "SSL bindings backed up to $backupFile"
    return $backupFile
}

# --- Function to change SSL certificate for a hostname (flexible and safe) ---
function Change-SSLCERT {
    $hostname = Read-Host "Enter the hostname to change SSL cert (e.g., myserver.local)"
    if ([string]::IsNullOrWhiteSpace($hostname)) {
        Write-Log "Hostname cannot be empty" "ERROR"
        return
    }

    $thumbprint = Read-Host "Enter the new certificate thumbprint (Hash) to bind for $hostname"
    if (-not ($thumbprint -match '^[0-9a-fA-F]{40}$')) {
        Write-Log "Invalid thumbprint format. Must be a 40-character hexadecimal string." "ERROR"
        return
    }

    $allBindings = Get-NetshSSLBindings
    $bindingsToChange = $allBindings | Where-Object { $_.Binding -like "*$hostname*" }

    if (-not $bindingsToChange) {
        Write-Log "No SSL bindings found containing '$hostname' to modify." "WARNING"
        return
    }

    # Backup current SSL bindings before changes
    $backupFile = Backup-SSL
    Write-Log "Backup complete. Proceeding with SSL certificate changes."

    Write-Log "The following SSL bindings will be modified for '$hostname':"
    $bindingsToChange | Format-Table -Property Binding, AppId

    $confirm = Read-Host "Do you want to apply these changes? (Y/N)"
    if ($confirm -ne 'Y') {
        Write-Log "Operation cancelled by user." "WARNING"
        return
    }

    # Apply changes
    foreach ($binding in $bindingsToChange) {
        $bindingString = $binding.Binding
        $appId = $binding.AppId
        
        Write-Log "Processing binding: $bindingString"
        
        # 1. Delete existing binding
        try {
            Write-Log "Attempting to delete existing binding for $bindingString..."
            $deleteResult = netsh http delete sslcert hostnameport=$bindingString 2>&1
            
            # Check the output/exit code for success
            if ($LASTEXITCODE -eq 0 -or $deleteResult -notmatch 'Error') {
                 Write-Log "Existing binding deleted successfully." "INFO"
            } else {
                 Write-Log "Failed to delete existing binding for $bindingString. Output: $deleteResult" "ERROR"
                 continue # Skip to next binding if delete fails
            }
        }
        catch {
            Write-Log "Critical error during delete operation for $bindingString: $($_.Exception.Message)" "ERROR"
            continue
        }

        # 2. Add new binding
        try {
            Write-Log "Attempting to add new binding for $bindingString (reusing AppID: $appId)..."
            $addResult = netsh http add sslcert hostnameport=$bindingString certhash=$thumbprint appid="{$appId}" certstorename=MY 2>&1
            
            if ($LASTEXITCODE -eq 0 -or $addResult -notmatch 'Error') {
                Write-Log "New SSL binding added successfully with thumbprint $thumbprint." "INFO"
            } else {
                Write-Log "Failed to add new binding. Output: $addResult" "ERROR"
            }
        }
        catch {
            Write-Log "Critical error during add operation for $bindingString: $($_.Exception.Message)" "ERROR"
        }
    }

    Write-Log "--- SSL certificate replacement process finished for '$hostname' ---"
    Write-Log "You can refer to the backup for previous bindings: $backupFile"
}

# --- Main menu ---
function Show-Menu {
    Write-Log "Script started. Log file is at $logFile" -Type "INFO"
    do {
        Write-Host "`n==========================================" -ForegroundColor Magenta
        Write-Host "SSL Certificate Management Menu" -ForegroundColor Magenta
        Write-Host "==========================================" -ForegroundColor Magenta
        Write-Host "1. Save ALL SSL bindings to log file (Reference)"
        Write-Host "2. View specific SSL bindings by hostname"
        Write-Host "3. Change SSL certificate for a hostname (Delete/Add)"
        Write-Host "4. Exit"
        Write-Host "------------------------------------------"
        $choice = Read-Host "Enter your choice (1-4)"
        switch ($choice) {
            "1" { Save-SSLCERT }
            "2" { Get-SSLCERT }
            "3" { Change-SSLCERT }
            "4" { Write-Log "Exiting script."; break }
            default { Write-Log "Invalid choice. Please select 1-4." "WARNING" }
        }
    } while ($true)
}

# Start the menu
Show-Menu
