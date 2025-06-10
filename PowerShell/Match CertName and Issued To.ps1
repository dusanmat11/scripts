# Specify the certificate store (e.g., local machine's personal store)
$certStore = "Cert:\LocalMachine\My"

# Retrieve the certificate(s) from the store
$certs = Get-ChildItem -Path $certStore

# Check if there are any certificates
if ($certs.Count -eq 0) {
    Write-Host "No certificates found in the store."
} else {
    Write-Host "Checking certificates in the store..."

    # Loop through each certificate
    foreach ($cert in $certs) {
        # Get the Friendly Name (can be empty if not set)
        $friendlyName = $cert.FriendlyName

        # Get the Subject of the certificate, which contains the CN (Issued To)
        $subject = $cert.Subject
        $issuedTo = ($subject -split ",") | Where-Object { $_ -match "^CN=" } | ForEach-Object { $_ -replace "^CN=", "" }

        # Check if the Friendly Name matches the CN (Issued To)
        if ($friendlyName -eq $issuedTo) {
            Write-Host "Certificate Match:"
            Write-Host "-----------------"
            Write-Host "Thumbprint:    $($cert.Thumbprint)"
            Write-Host "Friendly Name: $friendlyName"
            Write-Host "Issued To:     $issuedTo"
            Write-Host "Status:        Match"
            Write-Host "-----------------`n"
        } else {
            Write-Host "Certificate Mismatch:"
            Write-Host "---------------------"
            Write-Host "Thumbprint:    $($cert.Thumbprint)"
            Write-Host "Friendly Name: $friendlyName"
            Write-Host "Issued To:     $issuedTo"
            Write-Host "Status:        Mismatch"
            Write-Host "-----------------`n"
        }
    }
}
