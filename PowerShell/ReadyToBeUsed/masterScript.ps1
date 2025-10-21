# Scribe's Index - A Script to List, Launch, and Return (Now in a tireless loop and separate process!)

# 1. Determine the path where THIS script is located
$ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

# 2. Find all .ps1 scripts in that directory AND all sub-directories
$Scripts = Get-ChildItem -Path $ScriptDirectory -Filter "*.ps1" -Recurse | Where-Object { $_.FullName -ne $MyInvocation.MyCommand.Path } | Select-Object Name, FullName

# 3. Check if any other scripts were found
if ($Scripts.Count -eq 0) {
    Write-Host "Alas! No other .ps1 scripts were found in this very folder or its sub-folders. The Gatekeeper has nothing to guard." -ForegroundColor Yellow
    exit
}

# 4. Begin the Eternal Loop
do {
    # 5. Display the list of scripts to the user (Refreshed each time)
    Write-Host "`n*** Scrolls Found in the Archives ***" -ForegroundColor Green
    for ($i = 0; $i -lt $Scripts.Count; $i++) {
        $Location = Split-Path -Parent $Scripts[$i].FullName
        # Simple display to keep the output clean, only show if in a different folder
        if ($Location -ne $ScriptDirectory) {
            Write-Host ("{0}: {1} (In sub-folder)" -f ($i + 1), $Scripts[$i].Name)
        } else {
            Write-Host ("{0}: {1}" -f ($i + 1), $Scripts[$i].Name)
        }
    }
    Write-Host "`n*********************************" -ForegroundColor Green

    # 6. Get the user's choice
    $Choice = Read-Host "Enter the number of the scroll to run, or type '0' to depart the archives"

    # 7. Validate the choice and execute the script
    if ($Choice -eq "0") {
        Write-Host "Fair well, traveler. The Gatekeeper closes its doors until your return." -ForegroundColor Cyan
        break
    } elseif ($Choice -match '^\d+$' -and [int]$Choice -ge 1 -and [int]$Choice -le $Scripts.Count) {
        
        # Convert the user's input to the array index (subtract 1)
        $Index = [int]$Choice - 1
        $ScriptToRun = $Scripts[$Index]
        
        Write-Host "`n*** Preparing to execute in a separate process: $($ScriptToRun.Name) ***" -ForegroundColor Magenta
        
        # *** KEY CHANGE HERE: Launch the script as a separate PowerShell process and WAIT for it to finish. ***
        # This prevents the called script's 'exit' command from killing the Gatekeeper.
        Start-Process -FilePath 'powershell.exe' -ArgumentList "-NoProfile -File `"$($ScriptToRun.FullName)`"" -Wait
        
        Write-Host "`n*** Execution of $($ScriptToRun.Name) complete. Returning to the Index... ***" -ForegroundColor Green
        
    } else {
        Write-Host "That is a choice unknown to the archives. Please enter a valid number from the list or '0'." -ForegroundColor Red
    }

} while ($True) # This loop continues forever until the 'break' is encountered when the user chooses '0'

# End of Script