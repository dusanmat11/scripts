# Path to Chrome (change if needed)
$ChromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"

Import-Module WebAdministration

# Get all started IIS sites
$StartedSites = Get-Website | Where-Object { $_.state -eq "Started" }

# Collect all URLs
$Urls = @()
foreach ($Site in $StartedSites) {
    $Bindings = Get-WebBinding -Name $Site.Name
    foreach ($Binding in $Bindings) {
        $Protocol = $Binding.protocol
        $Parts    = $Binding.bindingInformation -split ':'
        $IP       = $Parts[0]
        $Port     = $Parts[1]
        $Hostname = $Parts[2]

        # Use hostname or localhost if empty/wildcard
        if ([string]::IsNullOrEmpty($Hostname) -or $Hostname -eq '*') {
            $HostPart = "localhost"
        } else {
            $HostPart = $Hostname
        }

        $Urls += "${Protocol}://${HostPart}:${Port}"
    }
}

# Remove duplicates
$Urls = $Urls | Sort-Object -Unique

# Open all URLs with progress
$TotalUrls = $Urls.Count
for ($i = 0; $i -lt $TotalUrls; $i++) {
    $Url = $Urls[$i]
    Write-Progress -Activity "Opening IIS Sites" `
                   -Status "Opening $Url ($($i+1) of $TotalUrls)" `
                   -PercentComplete ((($i+1)/$TotalUrls)*100)
    Start-Process $ChromePath $Url
}

Write-Host "All started IIS sites have been opened." -ForegroundColor Green
