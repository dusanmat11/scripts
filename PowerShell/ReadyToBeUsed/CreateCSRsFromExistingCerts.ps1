<#
.SYNOPSIS
    Generates CSRs for expiring IIS SSL certificates.

.DESCRIPTION
    Finds IIS-bound SSL certificates that are expired or expiring within
    the configured number of days and generates matching Certificate
    Signing Requests (CSRs), preserving the original subject and SAN entries.

.NOTES
    - Run as Administrator.
    - CSR files and logs are saved to the configured output folder.
#>

Import-Module WebAdministration

# -----------------------------
# Configuration
# -----------------------------
$certStore = "Cert:\LocalMachine\My"
$outputPath = "C:\Temp\CSRRenewals"
$daysUntilExpire = 30

# Set to $true to ONLY process IIS-bound certs
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
# Get IIS-bound thumbprints
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
        # Safe filename
        # -----------------------------
        $safeName = $cert.GetNameInfo(
            [System.Security.Cryptography.X509Certificates.X509NameType]::DnsName,
            $false
        )

        if ([string]::IsNullOrWhiteSpace($safeName)) {

            $safeName = $cert.Thumbprint.Substring(0,8)

        }

        # Handle wildcard certs
        $safeName = $safeName.Replace('*', 'wildcard')

        # Remove invalid filename chars
        $safeName = $safeName -replace '[\\/:?"<>|]', '_'

        # Use expiry date instead of thumbprint
        $expiryDate = $cert.NotAfter.ToString("yyyyMMdd")

        $uniqueName = "$safeName-$expiryDate"

        $infPath = Join-Path $outputPath "$uniqueName.inf"
        $csrPath = Join-Path $outputPath "$uniqueName.csr"

        # -----------------------------
        # Extract SANs
        # -----------------------------
        $dnsSANs = @()

        foreach ($extension in $cert.Extensions) {

            if ($extension.Oid.FriendlyName -eq 'Subject Alternative Name') {

                $formatted = $extension.Format($true)

                $entries = $formatted -split "`r`n"

                foreach ($entry in $entries) {

                    if ($entry -match 'DNS Name=(.+)') {

                        $dnsSANs += $matches[1].Trim()

                    }
                }
            }
        }

        $dnsSANs = $dnsSANs | Select-Object -Unique

        if ($dnsSANs.Count -gt 0) {

            Write-Log "Found SANs: $($dnsSANs -join ', ')"

        }
        else {

            Write-Log "No SANs found."

        }

        # -----------------------------
        # Build INF content
        # -----------------------------
        $infContent = @"
[Version]
Signature="`$Windows NT`$"

[NewRequest]
Subject = "$($cert.Subject)"
KeySpec = 1
KeyLength = 2048
Exportable = TRUE
MachineKeySet = TRUE
SMIME = FALSE
PrivateKeyArchive = FALSE
UserProtected = FALSE
UseExistingKeySet = FALSE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = PKCS10
KeyUsage = 0xa0
HashAlgorithm = SHA256
"@

        # -----------------------------
        # Add SANs
        # -----------------------------
        if ($dnsSANs.Count -gt 0) {

            $infContent += "`r`n[Extensions]`r`n"
            $infContent += '2.5.29.17 = "{text}"' + "`r`n"

            $sanLines = @()

            foreach ($dns in $dnsSANs) {

                $sanLines += "DNS=$dns"

            }

            $infContent += '_continue_ = "' + ($sanLines -join '&') + '"' + "`r`n"
        }

        # -----------------------------
        # Write INF
        # -----------------------------
        Set-Content `
            -Path $infPath `
            -Value $infContent `
            -Encoding ASCII

        Write-Log "INF file created: $infPath"

        # -----------------------------
        # Generate CSR
        # -----------------------------
        $arguments = "-new `"$infPath`" `"$csrPath`""

        $process = Start-Process `
            -FilePath "certreq.exe" `
            -ArgumentList $arguments `
            -Wait `
            -PassThru `
            -NoNewWindow

        if ($process.ExitCode -eq 0 -and (Test-Path $csrPath)) {

            Write-Log "CSR successfully generated: $csrPath"

        }
        else {

            Write-Log "ERROR: certreq.exe failed for $($cert.Subject). ExitCode=$($process.ExitCode)"

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