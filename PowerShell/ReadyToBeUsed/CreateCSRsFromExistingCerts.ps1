# ==========================================================
# Generate CSRs or REQs for Expired / Expiring Certificates
# ==========================================================

# --- Parameters ---
$certStore = "LocalMachine\My"
$outputPath = "C:\Temp\TESTCSR"
$daysUntilExpire = 30  # Certificates expiring within this many days

# --- Prepare output folder ---
if (-not (Test-Path $outputPath)) {
    New-Item -Path $outputPath -ItemType Directory | Out-Null
}

# --- Log setup ---
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $outputPath "CSR_GenerationLog_$timestamp.txt"

function Write-Log {
    param([string]$Message)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$time] $Message"
    Write-Host $entry
    Add-Content -Path $logFile -Value $entry
}

Write-Log "=== Starting CSR/REQ generation for expired or soon-to-expire certificates ==="

# --- Ask user for output format ---
$csrType = Read-Host "Choose CSR type (enter 'csr' or 'req')"
if ($csrType -notin @('csr', 'req')) {
    Write-Host "Invalid selection. Defaulting to .csr"
    $csrType = 'csr'
}

# --- Collect expiring certificates ---
$now = Get-Date
$cutoff = $now.AddDays($daysUntilExpire)
$certs = Get-ChildItem "Cert:\$certStore" | Where-Object { $_.NotAfter -lt $cutoff }

if (-not $certs) {
    Write-Log "No expired or soon-to-expire certificates found in store $certStore."
    exit
}

foreach ($cert in $certs) {
    try {
        # --- Extract subject fields ---
        $subject = $cert.Subject
        $cn = if ($subject -match "CN=([^,]+)") { $matches[1] } else { "" }
        $o  = if ($subject -match "O=([^,]+)")  { $matches[1] } else { "" }
        $ou = if ($subject -match "OU=([^,]+)") { $matches[1] } else { "" }
        $l  = if ($subject -match "L=([^,]+)")  { $matches[1] } else { "" }
        $s  = if ($subject -match "S=([^,]+)")  { $matches[1] } else { "" }
        $c  = if ($subject -match "C=([^,]+)")  { $matches[1] } else { "" }

        # --- Extract SANs ---
        $sanList = @()
        $sanExt = $cert.Extensions | Where-Object { $_.Oid.FriendlyName -eq "Subject Alternative Name" }
        if ($sanExt) {
            $rawData = $sanExt.Format($true)
            $rawData -split ", " | ForEach-Object {
                if ($_ -match "DNS Name=(.+)") { $sanList += $matches[1] }
            }
        }

        # --- Define paths ---
        $infPath = Join-Path $outputPath "$cn.inf"
        $csrFile = Join-Path $outputPath "$cn.$csrType"

        # --- Build INF content ---
        $infContent = @"
[Version]
Signature="\`$Windows NT\$"

[NewRequest]
Subject = "CN=$cn, O=$o, OU=$ou, L=$l, S=$s, C=$c"
KeySpec = 1
KeyLength = 2048
Exportable = TRUE
MachineKeySet = TRUE
SMIME = False
PrivateKeyArchive = FALSE
UserProtected = FALSE
UseExistingKeySet = FALSE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = PKCS10
KeyUsage = 0xa0

[Extensions]
2.5.29.37 = "{text}"
_continue_ = "1.3.6.1.5.5.7.3.1"
"@

        # --- Add SANs if available ---
        if ($sanList.Count -gt 0) {
            $infContent += @"
2.5.29.17 = "{text}"
_continue_ = "DNS=$($sanList -join ', DNS=')"
"@
        }

        # --- Write INF ---
        Set-Content -Path $infPath -Value $infContent -Encoding ASCII
        Write-Log "INF file created for $cn at $infPath"

        # --- Generate CSR/REQ ---
        Start-Process -FilePath "certreq.exe" -ArgumentList "-new `"$infPath`" `"$csrFile`"" -Wait
        Write-Log "Generated $csrType for $cn at $csrFile"

    } catch {
    Write-Log "Error generating CSR/REQ for certificate CN=${cn}: $($_.Exception.Message)"
}
}

Write-Log "=== CSR/REQ generation completed ==="
Write-Log "Log file saved to: $logFile"
Write-Host "`nProcess completed. Log saved to: $logFile"