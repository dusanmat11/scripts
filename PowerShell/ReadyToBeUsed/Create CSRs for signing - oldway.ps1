# ==========================================================
# Generate CSRs from Existing IIS Certificates
# Hybrid Stable Version
# ==========================================================

Import-Module WebAdministration

# -----------------------------
# Configuration
# -----------------------------
$certStore = "Cert:\LocalMachine\My"
$outputPath = "C:\Temp\CSRRenewals"
$daysUntilExpire = 30

# ONLY process IIS HTTPS-bound certificates
$onlyIISBound = $true

# -----------------------------
# Prepare output folder
# -----------------------------
if (-not (Test-Path $outputPath)) {

    New-Item -Path $outputPath -ItemType Directory | Out-Null

}

# -----------------------------
# Logging
# -----------------------------
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $outputPath "CSR_GenerationLog_$timestamp.txt"

function Write-Log {

    param([string]$Message)

    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$time] $Message"

    Write-Host $entry
    Add-Content -Path $logFile -Value $entry

}

Write-Log "=== Starting CSR generation process ==="

# -----------------------------
# Verify Administrator
# -----------------------------
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()

$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    Write-Log "ERROR: Script must be run as Administrator."
    exit 1

}

# -----------------------------
# Get IIS HTTPS bindings
# -----------------------------
$bindingThumbprints = @()

if ($onlyIISBound) {

    $bindings = Get-WebBinding | Where-Object {

        $_.protocol -eq 'https'

    }

    foreach ($binding in $bindings) {

        if ($binding.certificateHash) {

            if ($binding.certificateHash -is [byte[]]) {

                $thumbprint = [System.BitConverter]::ToString(
                    $binding.certificateHash
                ).Replace('-', '')

            }
            else {

                $thumbprint = $binding.certificateHash.ToString()

            }

            $thumbprint = $thumbprint.Replace(' ', '').ToUpper()

            $bindingThumbprints += $thumbprint

        }
    }

    $bindingThumbprints = $bindingThumbprints | Select-Object -Unique

    Write-Log "Found $($bindingThumbprints.Count) IIS certificate binding(s)."

}

# -----------------------------
# Find expiring certificates
# -----------------------------
$cutoff = (Get-Date).AddDays($daysUntilExpire)

if ($onlyIISBound) {

    $certs = Get-ChildItem $certStore | Where-Object {

        $_.Thumbprint -in $bindingThumbprints -and
        $_.NotAfter -lt $cutoff

    }

}
else {

    $certs = Get-ChildItem $certStore | Where-Object {

        $_.NotAfter -lt $cutoff

    }

}

if (-not $certs) {

    Write-Log "No expiring certificates found."
    exit

}

Write-Log "Found $($certs.Count) expiring certificate(s)."

# -----------------------------
# Process certificates
# -----------------------------
foreach ($cert in $certs) {

    try {

        Write-Log "Processing certificate: $($cert.Subject)"

        # -----------------------------
        # Extract CN
        # -----------------------------
        $certName = $cert.GetNameInfo(
            [System.Security.Cryptography.X509Certificates.X509NameType]::DnsName,
            $false
        )

        if ([string]::IsNullOrWhiteSpace($certName)) {

            Write-Log "Skipping certificate with invalid CN."
            continue

        }

        # -----------------------------
        # Handle wildcard certs
        # -----------------------------
        $safeName = $certName.Replace('*', 'wildcard')

        # Remove invalid filename chars
        $safeName = $safeName -replace '[\\/:?"<>|]', '_'

        # -----------------------------
        # Use expiry date in filename
        # -----------------------------
        $expiryDate = $cert.NotAfter.ToString("yyyyMMdd")

        $fileName = "$safeName-$expiryDate"

        $CSRPath = Join-Path $outputPath "$fileName.csr"
        $INFPath = Join-Path $outputPath "$fileName.inf"

        # -----------------------------
        # Extract SANs
        # -----------------------------
        $AlternativeNames = @()

        foreach ($extension in $cert.Extensions) {

            if ($extension.Oid.FriendlyName -eq 'Subject Alternative Name') {

                $formatted = $extension.Format($true)

                $entries = $formatted -split "`r`n"

                foreach ($entry in $entries) {

                    if ($entry -match 'DNS Name=(.+)') {

                        $AlternativeNames += $matches[1].Trim()

                    }
                }
            }
        }

        $AlternativeNames = $AlternativeNames | Select-Object -Unique

        if ($AlternativeNames.Count -gt 0) {

            Write-Log "Found SANs: $($AlternativeNames -join ', ')"

        }
        else {

            Write-Log "No SANs found."

        }

        # -----------------------------
        # Build INF content
        # -----------------------------
        $Signature = '$Windows NT$'

        $INF = @"
[Version]
Signature="$Signature"

[NewRequest]
Subject = "$($cert.Subject)"
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

[EnhancedKeyUsageExtension]
OID=1.3.6.1.5.5.7.3.1
"@

        # -----------------------------
        # Add SAN extension
        # -----------------------------
        if ($AlternativeNames.Count -gt 0) {

            $INF += @"

[Extensions]
2.5.29.17 = "{text}"
_continue_ = "DNS=$($AlternativeNames -join ', DNS=')"
"@
        }

        # -----------------------------
        # Write INF
        # -----------------------------
        $INF | Out-File `
            -FilePath $INFPath `
            -Force `
            -Encoding ASCII

        Write-Log "INF file created: $INFPath"

        # -----------------------------
        # Generate CSR
        # -----------------------------
        certreq.exe -new $INFPath $CSRPath | Out-Null

        if (Test-Path $CSRPath) {

            Write-Log "CSR successfully generated: $CSRPath"

        }
        else {

            Write-Log "ERROR: CSR generation failed for $($cert.Subject)"

        }

    }
    catch {

        Write-Log "ERROR processing certificate $($cert.Subject): $($_.Exception.Message)"

    }
}

Write-Log "=== CSR generation process completed ==="
Write-Log "Log file saved to: $logFile"

Write-Host ""
Write-Host "CSR generation completed."
Write-Host "Log file: $logFile"