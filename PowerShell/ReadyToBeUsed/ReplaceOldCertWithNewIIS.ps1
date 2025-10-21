Version 1

# =========================================
# Auto-Replace Expired Certificates in IIS
# =========================================
# - Scans Cert:\LocalMachine\My for certificates
# - Matches expired and valid certs by Subject CN
# - Updates IIS bindings using the old cert
# - Keeps old certificates (no deletion)
# - Logs all activity to C:\Temp\CertUpdateLog_yyyyMMdd_HHmmss.txt
# =========================================

Import-Module WebAdministration

# --- Logging Setup ---
$logFolder = "C:\Temp"
if (-not (Test-Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logFolder "CertUpdateLog_$timestamp.txt"

# Logging helper function
function Write-Log {
    param ([string]$message)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$time] $message"
    Write-Host $entry
    Add-Content -Path $logFile -Value $entry
}

Write-Log "=== Starting IIS Certificate Replacement Script ==="

# --- Load certificates ---
$allCerts = Get-ChildItem Cert:\LocalMachine\My
$groupedCerts = $allCerts | Group-Object Subject

foreach ($group in $groupedCerts) {
    $subject = $group.Name
    $certs = $group.Group

    # Find newest expired and newest valid certificate for this CN
    $expired = $certs | Where-Object { $_.NotAfter -lt (Get-Date) } | Sort-Object NotAfter -Descending | Select-Object -First 1
    $valid   = $certs | Where-Object { $_.NotAfter -gt (Get-Date) } | Sort-Object NotAfter -Descending | Select-Object -First 1

    if ($expired -and $valid) {
        Write-Log "Found expired + valid pair for: $subject"
        Write-Log " - Old (expired): $($expired.Thumbprint) [Expired $($expired.NotAfter)]"
        Write-Log " - New (valid):   $($valid.Thumbprint) [Expires $($valid.NotAfter)]"

        # Update IIS bindings using the old cert
        $bindings = Get-WebBinding | Where-Object { $_.certificateHash -eq $expired.Thumbprint }

        if ($bindings) {
            foreach ($binding in $bindings) {
                Write-Log "Updating IIS binding: $($binding.bindingInformation)"
                try {
                    $binding.AddSslCertificate($valid.Thumbprint, "My")
                    Write-Log " → Updated successfully."
                }
                catch {
                    Write-Log " Failed to update binding for $($binding.bindingInformation): $_"
                }
            }
        }
        else {
            Write-Log "No IIS bindings found using expired certificate for $subject."
        }
    }
}

Write-Log "=== Certificate replacement process completed ==="
Write-Log "Log file saved to: $logFile"



Version2 .\scripts


# =========================================
# Auto-Replace Expired Certificates in IIS
# =========================================
# - Scans Cert:\LocalMachine\My for certificates
# - Matches expired and valid certs by Subject CN
# - Shows what will be updated (preview mode)
# - Asks for confirmation before making changes
# - Keeps old certificates (no deletion)
# - Logs all activity to C:\Temp\CertUpdateLog_yyyyMMdd_HHmmss.txt
# =========================================

Import-Module WebAdministration

# --- Logging Setup ---
$logFolder = "C:\Temp"
if (-not (Test-Path $logFolder)) {
    New-Item -Path $logFolder -ItemType Directory | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $logFolder "CertUpdateLog_$timestamp.txt"

function Write-Log {
    param ([string]$message)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$time] $message"
    Write-Host $entry
    Add-Content -Path $logFile -Value $entry
}

Write-Log "=== Starting IIS Certificate Replacement Script ==="

# --- Load certificates ---
$allCerts = Get-ChildItem Cert:\LocalMachine\My
$groupedCerts = $allCerts | Group-Object Subject

# Store pairs to process later
$pairs = @()

foreach ($group in $groupedCerts) {
    $subject = $group.Name
    $certs = $group.Group

    # Find newest expired and newest valid certificate for this CN
    $expired = $certs | Where-Object { $_.NotAfter -lt (Get-Date) } | Sort-Object NotAfter -Descending | Select-Object -First 1
    $valid   = $certs | Where-Object { $_.NotAfter -gt (Get-Date) } | Sort-Object NotAfter -Descending | Select-Object -First 1

    if ($expired -and $valid) {
        $pairs += [PSCustomObject]@{
            Subject      = $subject
            OldThumbprint = $expired.Thumbprint
            OldExpiry     = $expired.NotAfter
            NewThumbprint = $valid.Thumbprint
            NewExpiry     = $valid.NotAfter
        }
    }
}

if (-not $pairs) {
    Write-Log "No expired certificates with valid replacements found. Exiting."
    exit
}

Write-Host "`n==============================="
Write-Host "PREVIEW: Certificates to be updated"
Write-Host "==============================="
foreach ($p in $pairs) {
    Write-Host "`nSubject: $($p.Subject)"
    Write-Host " Old (expired): $($p.OldThumbprint) [Expired $($p.OldExpiry)]"
    Write-Host " New (valid):   $($p.NewThumbprint) [Expires $($p.NewExpiry)]"

    $bindings = Get-WebBinding | Where-Object { $_.certificateHash -eq $p.OldThumbprint }
    if ($bindings) {
        Write-Host " IIS Bindings to be updated:"
        foreach ($b in $bindings) {
            Write-Host "   - $($b.bindingInformation)"
        }
    } else {
        Write-Host " No IIS bindings found for this certificate."
    }
}

# --- Ask for confirmation ---
Write-Host "`n"
$confirm = Read-Host "Proceed with updating these bindings? (Y/N)"

if ($confirm -notin @("Y", "y")) {
    Write-Log "User cancelled the operation. No changes were made."
    Write-Host "Operation cancelled."
    exit
}

# --- Perform updates ---
foreach ($p in $pairs) {
    Write-Log "Updating certificates for: $($p.Subject)"
    $bindings = Get-WebBinding | Where-Object { $_.certificateHash -eq $p.OldThumbprint }

    foreach ($binding in $bindings) {
        Write-Log "Updating IIS binding: $($binding.bindingInformation)"
        try {
            $binding.AddSslCertificate($p.NewThumbprint, "My")
            Write-Log "Updated successfully."
        }
        catch {
            Write-Log "Failed to update binding for $($binding.bindingInformation): $_"
        }
    }
}

Write-Log "=== Certificate replacement process completed ==="
Write-Log "Log file saved to: $logFile"
Write-Host "`nScript completed. Log saved to: $logFile"
