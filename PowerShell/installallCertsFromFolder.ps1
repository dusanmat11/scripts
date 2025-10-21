# ============================================
# Complete Certificate Requests and Set FriendlyName
# ============================================

# === CONFIGURATION ===
$certFolder   = "C:\Temp\Certificates"      # Folder containing .cer files
$certStore    = "LocalMachine\My"          # Local Computer → Personal\Certificates store
$logFile      = Join-Path $certFolder "CertCompletionLog.txt"  # Log file for all actions

# === FUNCTIONS ===

# Function to log messages to both console and log file with timestamp
function Write-Log($message) {
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "[$timestamp] $message"
    Write-Host $entry
    Add-Content -Path $logFile -Value $entry
}

# Ensure the certificate folder exists before proceeding
if (-not (Test-Path $certFolder)) {
    Write-Error "Certificate folder '$certFolder' does not exist."
    exit
}

# Step 1: Find all .cer files in the folder
$cerFiles = Get-ChildItem -Path $certFolder -Filter *.cer

# Exit if no .cer files are found
if ($cerFiles.Count -eq 0) {
    Write-Log "No .cer files found in $certFolder."
    exit
}

# Step 2: Loop through each .cer file
foreach ($cer in $cerFiles) {
    try {
        $cerPath = $cer.FullName
        $friendlyName = $cer.BaseName  # FriendlyName will be set to the filename without extension

        Write-Log "Processing certificate: $cerPath"

        # Step 3: Complete the certificate request and import it into the Local Computer → Personal store
        # certreq.exe -accept imports the certificate to LocalMachine\My
        certreq.exe -accept $cerPath
        Write-Log "Certificate imported into Local Computer\Personal (LocalMachine\My): $cerPath"

        # Step 4: Open the Local Computer Personal store for read/write to update FriendlyName
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("My","LocalMachine")
        $store.Open("ReadWrite")

        # Step 5: Find the imported certificate in the store
        # Match by Subject containing the filename (BaseName)
        # If multiple certs match, select the most recent one
        $importedCert = $store.Certificates |
                        Where-Object { $_.Subject -like "*$friendlyName*" } |
                        Sort-Object NotBefore -Descending |
                        Select-Object -First 1

        # Step 6: Set FriendlyName to match the certificate filename
        if ($importedCert) {
            $importedCert.FriendlyName = $friendlyName
            Write-Log "FriendlyName set to: $friendlyName"
        } else {
            Write-Log "WARNING: Could not find imported certificate in Local Computer\Personal store."
        }

        # Step 7: Close the store
        $store.Close()
    }
    catch {
        Write-Log "ERROR processing $($cer.Name): $_"
    }
}

# Step 8: Finished processing all certificates
Write-Log "=== Certificate completion finished for all certificates ==="
