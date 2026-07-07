$Bundles = @(
    @{
        Version = "8"
        Url = "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/8.0.28/dotnet-hosting-8.0.28-win.exe"
    },
    @{
        Version = "9"
        Url = "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/9.0.17/dotnet-hosting-9.0.17-win.exe"
    },
    @{
        Version = "10"
        Url = "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/10.0.9/dotnet-hosting-10.0.9-win.exe"
    }
)

foreach ($Bundle in $Bundles) {
    $File = "C:\Temp\dotnet-hosting-$($Bundle.Version).exe"

    Invoke-WebRequest -Uri $Bundle.Url -OutFile $File

    Start-Process $File -ArgumentList "/install /quiet /norestart" -Wait
}






2nd version of the script

<#
.SYNOPSIS
    Installs required IIS components and .NET Hosting Bundles.

.DESCRIPTION
    Downloads and installs .NET 8, .NET 9, .NET 10 Hosting Bundles and
    IIS URL Rewrite 2.1 if they are not already installed. IIS is restarted
    after successful installations, and installed .NET runtimes are displayed.

.NOTES
    - Run as Administrator.
    - Internet access is required to download the installers.
#>


# Create download folder
$DownloadFolder = "C:\Temp"

if (!(Test-Path $DownloadFolder)) {
    New-Item -ItemType Directory -Path $DownloadFolder | Out-Null
}

$RestartIIS = $false

# Packages to install
$Packages = @(
    @{
        Name = ".NET 8 Hosting Bundle"
        Runtime = "Microsoft.AspNetCore.App 8."
        Url = "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/8.0.28/dotnet-hosting-8.0.28-win.exe"
        File = "dotnet-hosting-8.exe"
        Type = "EXE"
    },
    @{
        Name = ".NET 9 Hosting Bundle"
        Runtime = "Microsoft.AspNetCore.App 9."
        Url = "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/9.0.17/dotnet-hosting-9.0.17-win.exe"
        File = "dotnet-hosting-9.exe"
        Type = "EXE"
    },
    @{
        Name = ".NET 10 Hosting Bundle"
        Runtime = "Microsoft.AspNetCore.App 10."
        Url = "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/10.0.9/dotnet-hosting-10.0.9-win.exe"
        File = "dotnet-hosting-10.exe"
        Type = "EXE"
    },
    @{
        Name = "IIS URL Rewrite 2.1"
        Url = "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi"
        File = "rewrite_amd64_en-US.msi"
        Type = "MSI"
    }
)

foreach ($Package in $Packages) {

    $Installed = $false

    if ($Package.Type -eq "EXE") {
        $Installed = dotnet --list-runtimes 2>$null | Select-String $Package.Runtime
    }
    else {
        $Installed = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue |
                     Where-Object { $_.DisplayName -like "*URL Rewrite*" }
    }

    if ($Installed) {
        Write-Host "$($Package.Name) is already installed. Skipping." -ForegroundColor Yellow
        continue
    }

    $Installer = Join-Path $DownloadFolder $Package.File

    Write-Host ""
    Write-Host "Downloading $($Package.Name)..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $Package.Url -OutFile $Installer

    Write-Host "Installing $($Package.Name)..." -ForegroundColor Green

    if ($Package.Type -eq "EXE") {
        $Process = Start-Process `
            -FilePath $Installer `
            -ArgumentList "/install /quiet /norestart" `
            -Wait `
            -PassThru
    }
    else {
        $Process = Start-Process `
            -FilePath "msiexec.exe" `
            -ArgumentList "/i `"$Installer`" /qn /norestart" `
            -Wait `
            -PassThru
    }

    if ($Process.ExitCode -eq 0) {
        Write-Host "$($Package.Name) installed successfully." -ForegroundColor Green
        $RestartIIS = $true
    }
    else {
        Write-Warning "$($Package.Name) installation failed with exit code $($Process.ExitCode)"
    }

    Remove-Item $Installer -Force
}

if ($RestartIIS) {
    Write-Host ""
    Write-Host "Restarting IIS..." -ForegroundColor Cyan
    iisreset
}

Write-Host ""
Write-Host "Installed .NET runtimes:" -ForegroundColor Cyan
dotnet --list-runtimes

Write-Host ""
Write-Host "Installation completed." -ForegroundColor Green