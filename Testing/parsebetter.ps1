(
    Get-Content "C:\Users\dusmat00\Documents\GitHub pers\scripts\Testing\idpPermissions.txt" |
    ForEach-Object {
        if ($_ -match "\(\s*'[^']+'\s*,\s*'([^']+)'\s*,") {
            '"' + $matches[1] + '"'
        }
    } |
    Sort-Object -Unique
) -join ',' | Set-Content "C:\Users\dusmat00\Documents\GitHub pers\scripts\Testing\outputAAAA.txt"