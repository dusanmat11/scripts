# Prompt for user input to filter by a string
$filterString = Read-Host "Enter the string to filter certificates by DNS name"

# Prompt for user input for the expiration year
$expirationYear = Read-Host "Enter the expiration year to filter certificates (2025, 2026)"

# Define the certificate store to check (could be "LocalMachine" or "CurrentUser")
$storeLocation = "LocalMachine"
$storeName = "My"  # This is the Personal certificate store

# Open the certificate store
$certStore = New-Object System.Security.Cryptography.X509Certificates.X509Store($storeName, $storeLocation)
$certStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)

# Get all certificates from the store
$certificates = $certStore.Certificates

# Filter certificates based on user input for expiration year and filter string
$expiredInYearWithFilter = $certificates | Where-Object { 
    $_.NotAfter.Year -eq $expirationYear -and (Get-Date) -and
    ($_.Subject -like "*$filterString*" -or $_.FriendlyName -like "*$filterString*")
}

# Display the filtered certificates with Subject, FriendlyName, and NotAfter
if ($expiredInYearWithFilter.Count -gt 0) {
    $expiredInYearWithFilter | Select-Object @{Name="Certificate Name"; Expression={ $_.FriendlyName }},
                                         @{Name="Subject"; Expression={ $_.Subject }},
                                         @{Name="Expiration Date"; Expression={ $_.NotAfter }} | 
    Format-Table -AutoSize
} else {
    Write-Host "No certificates expired in $expirationYear matching your filter found."
}

# Close the certificate store
$certStore.Close()
