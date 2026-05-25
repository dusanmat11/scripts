# Path to your input file
$inputFile = "C:\Users\dusmat00\Documents\GitHub pers\scripts\Testing\IdPPer tabs.txt"

# Path to your output file
$outputFile = "C:\Users\dusmat00\Documents\GitHub pers\scripts\Testing\idpPermissionsFin.txt"

# Read, process, and write single-line output
(
    Get-Content $inputFile |
    ForEach-Object {
        # Split line by tab and take second column
        $cols = $_ -split "`t"
        if ($cols.Length -ge 2) {
            '"' + $cols[1].Trim() + '"'
        }
    } |
    Sort-Object -Unique  # remove duplicates
) -join ',' | Set-Content $outputFile

Write-Host "Output written to $outputFile"