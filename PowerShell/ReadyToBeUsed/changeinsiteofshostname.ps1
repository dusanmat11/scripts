#Used to change ARM to LAN, look line 22 and 23


Import-Module WebAdministration

# Get all IIS sites
$sites = Get-ChildItem IIS:\Sites

foreach ($site in $sites) {
    Write-Host "Processing site: $($site.Name)" -ForegroundColor Cyan

    # Get all bindings for the current site
    $bindings = Get-WebBinding -Name $site.Name

    foreach ($binding in $bindings) {
        $bindingInfo = $binding.bindingInformation.Split(':')
        $ip = $bindingInfo[0]
        $port = $bindingInfo[1]
        $hostHeader = $bindingInfo[2]

        # Check if the binding hostname contains '-arm.'
        if ($hostHeader -like "*-arm.*") {
            $newHostHeader = $hostHeader -replace "-arm\.", "-lan."
            Write-Host "Updating binding: $hostHeader -> $newHostHeader" -ForegroundColor Yellow

            # Remove the old binding
            Remove-WebBinding -Name $site.Name -Protocol $binding.protocol -BindingInformation "$ip`:$port`:$hostHeader"

            # Add the new binding
            New-WebBinding -Name $site.Name -Protocol $binding.protocol -Port $port -IPAddress $ip -HostHeader $newHostHeader
        }
    }
}

Write-Host "All bindings updated successfully." -ForegroundColor Green
