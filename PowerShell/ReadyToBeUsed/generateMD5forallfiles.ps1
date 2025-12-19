$folder = "C:\Users\dusmat00\Downloads\1st_Delivery_Initial_Installation"
$log = "C:\Temp\MD5\md5.txt"

Get-ChildItem -Path $folder -File -Recurse | ForEach-Object {
    $hash = Get-FileHash -Path $_.FullName -Algorithm MD5
    "$($_.FullName) : $($hash.Hash)" | Out-File -FilePath $log -Append
}