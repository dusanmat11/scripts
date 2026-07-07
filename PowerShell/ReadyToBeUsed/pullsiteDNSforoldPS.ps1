<#
.SYNOPSIS
    Lists IIS websites and their bindings.

.DESCRIPTION
    Displays IIS websites with their URLs or, when the -HostnamesOnly
    switch is used, outputs only the site names and hostnames.

.NOTES
    - Requires the WebAdministration module.
    - Compatible with older PowerShell versions.
#>

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


