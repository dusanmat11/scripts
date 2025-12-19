Import-Module WebAdministration

# Pattern to find and replacement
$Pattern = '^enx'   # hostnames starting with 'enx'
$Replacement = 'enxu'

$Bindings = Get-WebBinding -Protocol https |
            Where-Object { ($_.bindingInformation -split ':')[2] -match $Pattern }

foreach ($Binding in $Bindings) {

    # Parse binding
    $Parts = $Binding.bindingInformation -split ':'
    $IP       = $Parts[0]
    $Port     = $Parts[1]
    $OldHost  = $Parts[2]
    $SiteName = ($Binding.ItemXPath -split "'")[1]
    $Thumbprint = $Binding.certificateHash
    $Store      = $Binding.certificateStoreName

    # New hostname
    $NewHost = $OldHost -replace $Pattern, $Replacement

    Write-Host "Updating $SiteName : $OldHost -> $NewHost"

    # Remove old binding
    Remove-WebBinding `
        -Name $SiteName `
        -Protocol https `
        -IPAddress $IP `
        -Port $Port `
        -HostHeader $OldHost

    # Add new binding
    New-WebBinding `
        -Name $SiteName `
        -Protocol https `
        -IPAddress $IP `
        -Port $Port `
        -HostHeader $NewHost

    # Re-attach certificate (SNI)
    $SslPath = "IIS:\SslBindings\$IP!$Port!$NewHost"
    Set-Item `
        -Path $SslPath `
        -Thumbprint $Thumbprint `
        -SSLFlags 1
}
