<#
.SYNOPSIS
    Filters text from an input file based on user input.

.DESCRIPTION
    Searches the input.txt file for lines containing the specified text,
    displays the matching results, and optionally saves them to
    filtered_output.txt.

.NOTES
    - The input.txt file must be located in the same folder as the script.
#>

# --- Configuration ---
# Get the folder where this script is located
$scriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Path

# Full paths for input and output files in the script folder
$inputFilePath = Join-Path $scriptFolder "input.txt"
$outputFilePath = Join-Path $scriptFolder "filtered_output.txt"

# --- Script Body ---

# Prompt the user to enter the text they want to search for
$filterText = Read-Host -Prompt "Enter the text to filter for"

# Check if the input file exists
if (-not (Test-Path $inputFilePath)) {
    Write-Host "Error: The file '$inputFilePath' was not found."
    Read-Host -Prompt "Press Enter to exit"
    exit
}

# Read and filter the content
$filteredContent = Get-Content $inputFilePath | Where-Object { $_ -like "*$filterText*" }

# Display or save results
if ($filteredContent) {
    Write-Host "`n--- Filtered Results ---"
    $filteredContent

    $choice = Read-Host -Prompt "`nDo you want to save these results to a file? (y/n)"
    if ($choice -eq 'y') {
        $filteredContent | Set-Content -Path $outputFilePath
        Write-Host "Results have been saved to '$outputFilePath'"
    }
}
else {
    Write-Host "No lines containing '$filterText' were found in the file."
}

Read-Host -Prompt "Press Enter to exit"
