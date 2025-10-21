$registryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'
$propertyName = 'DisableLoopbackCheck'
$propertyValue = 1

# Check if the property already exists
try {
    $existing = Get-ItemProperty -Path $registryPath -Name $propertyName -ErrorAction Stop
    Write-Output "Registry value '$propertyName' already exists. Current value: $($existing.$propertyName)"
}
catch {
    # Property does not exist, create it
    Write-Output "Registry value '$propertyName' does not exist. Creating it..."
    New-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue -PropertyType DWord -Force | Out-Null
    Write-Output "Registry value '$propertyName' created with value $propertyValue."
}