# FOR OLDER VERSIONS OF POWERSHELL, 
# when calling script add .\Get-IISSites.ps1 -HostnamesOnly

param(
    [switch]$HostnamesOnly  # Use -HostnamesOnly to trim output
)

Import-Module WebAdministration

Get-WebBinding | ForEach-Object {
    $siteName = $_.ItemXPath -replace '.*sites\[(.*?)\].*','$1'
    $parts = $_.bindingInformation -split ':'

    # Extract IP, Port, Host safely
    if ($parts[0] -eq '*') {
        $ip = 'localhost'
    } else {
        $ip = $parts[0]
    }

    $port = $parts[1]

    if ($parts.Count -ge 3 -and $parts[2] -ne '') {
        $hostname = $parts[2]
    } else {
        $hostname = $ip
    }

    $protocol = $_.protocol

    # Build URL
    $url = "${protocol}://${hostname}"
    if ($port -ne 80 -and $port -ne 443) {
        $url += ":$port"
    }

    # Output based on switch
    if ($HostnamesOnly) {
        [PSCustomObject]@{
            SiteName = $siteName
            Hostname = $hostname
        }
    } else {
        [PSCustomObject]@{
            SiteName = $siteName
            Protocol = $protocol
            URL      = $url
        }
    }
} | Format-Table -AutoSize


