# ================================
# MD5 Hash Generator
# ================================

$folder = "C:\Users\dusmat00\Downloads\1st_Delivery_Initial_Installation"
$log = "C:\Temp\MD5\output.txt"

# Header for output file
"===============================" | Out-File $log
" MD5 HASH REPORT"               | Out-File $log -Append
" Generated: $(Get-Date)"        | Out-File $log -Append
" Folder: $folder"               | Out-File $log -Append
"===============================" | Out-File $log -Append
""                               | Out-File $log -Append

Write-Host "`nScanning folder:" -ForegroundColor Cyan
Write-Host " $folder`n" -ForegroundColor Yellow

$files = Get-ChildItem -Path $folder -File -Recurse
$total = $files.Count
$counter = 0

foreach ($file in $files) {
    $counter++
    Write-Progress -Activity "Generating MD5 hashes..." `
                   -Status "$counter / $total ($($file.Name))" `
                   -PercentComplete (($counter / $total) * 100)

    $hash = Get-FileHash -Path $file.FullName -Algorithm MD5
    "$($file.FullName) : $($hash.Hash)" | Out-File -Append $log
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Green
Write-Host " MD5 generation completed successfully" -ForegroundColor Green
Write-Host " Files processed: $total" -ForegroundColor Cyan
Write-Host " Output saved to: $log" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""
