# Ask for comma-separated hostname:port values
$InputLine = Read-Host "Enter hostname:port values (comma-separated)"

$HostnamePorts = $InputLine -split ',' |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -match '^[^:]+:\d+$' }

if ($HostnamePorts.Count -eq 0) {
    Write-Host "No valid hostname:port entries provided." -ForegroundColor Red
    return
}

# Certificate selection
Write-Host "`nCertificate selection:"
Write-Host "1 - Enter certificate thumbprint manually"
Write-Host "2 - Auto-detect certificate by subject"

$Choice = Read-Host "Choose option (1 or 2)"

switch ($Choice) {
    "1" {
        $Thumbprint = Read-Host "Enter certificate thumbprint"
        $Thumbprint = $Thumbprint -replace '\s',''

        if ($Thumbprint -notmatch '^[A-Fa-f0-9]{40}$') {
            Write-Host "Invalid thumbprint format." -ForegroundColor Red
            return
        }
    }

    "2" {
        $CertSubject = Read-Host "Enter part of certificate Subject (e.g. ips-energy.com)"

        $Cert = Get-ChildItem Cert:\LocalMachine\My |
                Where-Object { $_.Subject -like "*$CertSubject*" } |
                Sort-Object NotAfter -Descending |
                Select-Object -First 1

        if (-not $Cert) {
            Write-Host "Certificate not found." -ForegroundColor Red
            return
        }

        $Thumbprint = $Cert.Thumbprint
    }

    default {
        Write-Host "Invalid choice." -ForegroundColor Red
        return
    }
}

$AppId = "{00000000-0000-0000-0000-000000000000}"

Write-Host "`nGenerated commands:" -ForegroundColor Green

foreach ($Hp in $HostnamePorts) {
    $Command = "netsh.exe http add sslcert hostnameport=$Hp certhash=$Thumbprint appid=`"$AppId`" certstorename=MY"
    Write-Host $Command -ForegroundColor Cyan
}
