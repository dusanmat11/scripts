#--------------------------------------
# SCRIPT RELEASE NOTES
#--------------------------------------
# Script Name        : Execute SQL Scripts with Version & Update Checks
# Description        : 
#   - Recursively executes all SQL scripts in the folder where the script resides.
#   - Checks UpdateIps table to skip scripts already executed.
#   - Checks sch.dbversion table to skip scripts from already applied versions.
#   - Early sch folders (pre-database versions) tracked locally in _local\sch_executed.log 
#     to prevent re-execution if the database table does not exist yet.
#   - Full logging to _local\script.log and _local\error.log
#
# Recent Changes     :
#   1. Added exception handling for early sch folders (5.06.00 – 5.23.02).
#   2. Added local log (_local\sch_executed.log) to track executed scripts in exception folders.
#   3. Added safe check for sch.dbversion table existence.
#   4. Added summary of executed and skipped scripts at the end.
#
# Usage              :
#   Run the script as Administrator. Prompts for confirmation before executing scripts.
#
# What is not working:
# AIP Scripts check and re-execution
#---------------------------------------------------------------------------

param(
    [string]$ServerInstance = "RS-MATICD",
    [string]$Database = "IpsEnergy193_AVO"
)

#--------------------------------------
# Script Configuration
#--------------------------------------

$SCRIPT_PATH = (Get-Variable MyInvocation).Value.MyCommand.Path
$SCRIPT_DIR = Split-Path -Parent $SCRIPT_PATH

$LOCAL_FILES = @{
    LogFile= "$SCRIPT_DIR\_local\script.log" 
    ErrorLogFile= "$SCRIPT_DIR\_local\error.log"
}

# Create _local folder if not exists
$resultsFolder = Join-Path $SCRIPT_DIR "_local"
if (-not (Test-Path $resultsFolder)) {
    New-Item -Path $resultsFolder -ItemType Directory | Out-Null
}

# Ensure log files exist
$LOCAL_FILES.GetEnumerator() | ForEach-Object {
    if (-not (Test-Path $_.Value)) { New-Item -Path $_.Value -ItemType File -Force | Out-Null }
}

#--------------------------------------
# Exceptions for early sch folders (tracked locally until DB exists)
#--------------------------------------
$SchExceptions = @(
    "5.06.00","5.07.00","5.10.00","5.11.00","5.12.00","5.12.01","5.12.02","5.12.03",
    "5.13.00","5.13.01","5.14.00","5.14.01","5.14.02","5.15.00","5.15.01","5.15.02",
    "5.16.00","5.16.01","5.16.02","5.16.03","5.18.00","5.18.01","5.20.00","5.21.00",
    "5.21.01","5.22.00","5.23.00","5.23.01","5.23.02"
) | ForEach-Object { $_.ToLower() }

$SchExecutedFile = "$SCRIPT_DIR\_local\sch_executed.log"
if (-not (Test-Path $SchExecutedFile)) { New-Item -Path $SchExecutedFile -ItemType File -Force | Out-Null }
$schExecuted = Get-Content $SchExecutedFile | ForEach-Object { $_.Trim().ToLower() }

#--------------------------------------
# Functions
#--------------------------------------
function Write-Log {
    param (
        [string]$message,
        [string]$type = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$type] $message"
    Add-Content -Path $LOCAL_FILES.LogFile -Value "$logEntry`n"

    switch ($type) {
        "ERROR" { Write-Host $logEntry -ForegroundColor Red }
        "FATAL" { Write-Host $logEntry -ForegroundColor Red }
        "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
        default { Write-Host $logEntry }
    }
}

function Test-SqlConnection {
    param (
        [string]$serverInstance,
        [string]$database
    )
    try {
        Write-Log "Testing SQL connection for Server: '$serverInstance', Database: '$database'" "INFO"
        $connectionString = "Server=$serverInstance;Database=$database;Integrated Security=True"
        $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
        $connection.Open()
        $connection.Close()
        $connection.Dispose()
        Write-Log "SQL connection is valid." "INFO"
        return $true
    } catch {
        Write-Log "Failed to connect to SQL Server." "ERROR"
        return $false
    }
}

function ExecuteSqlScript {
    param (
        [string]$sqlFilePath
    )
    try {
        $startTime = Get-Date
        Invoke-Sqlcmd -InputFile $sqlFilePath -ServerInstance $ServerInstance -Database $Database -ErrorAction Stop
        $endTime = Get-Date
        $duration = $endTime - $startTime
        Write-Log "Successfully executed $($sqlFilePath) in $($duration.TotalSeconds) seconds." "SUCCESS"
    }
    catch {
        $errorDetails = $_.Exception.Message
        $stackTraceException = $_.Exception.StackTrace
        $errorMessage = "Error executing $($sqlFilePath): $errorDetails"
        Write-Log $errorMessage "ERROR"
        $errorLogEntry = "[$(Get-Date)] Error executing $($sqlFilePath): $errorDetails"
        $errorLogEntry += "`nStack Trace: $stackTraceException"
        Add-Content -Path $LOCAL_FILES.ErrorLogFile -Value $errorLogEntry
        Write-Log "Stopping script execution due to error in script $($sqlFilePath)." "FATAL"
        exit 1
    }
}

#--------------------------------------
# Main Script Execution
#--------------------------------------
$scriptStartTime = Get-Date

$executedCount = 0
$skippedUpdateIpsCount = 0
$skippedDbVersionCount = 0

try {
    # check administrator privileges
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "[ERROR] Please run this script as an Administrator." -ForegroundColor Red
        exit 1
    }

    Write-Host "-------------------------------------"
    Write-Host "[INFO] Script          : $SCRIPT_PATH"
    Write-Host "[INFO] Working directory: $SCRIPT_DIR"
    Write-Host "-------------------------------------"

    if (-not (Test-SqlConnection -serverInstance $ServerInstance -database $Database)) {
        Write-Log "Invalid SQL connection. Exiting script." "ERROR"
        exit 1
    }

    $confirmation = Read-Host "Confirm running scripts on Server: '$ServerInstance', Database: '$Database' (Y/N)"
    if ($confirmation.ToUpper() -ne "Y") {
        Write-Log "User aborted script execution." "FATAL"
        exit 1
    }

    Write-Log "Processing all SQL files recursively under: $SCRIPT_DIR" "INFO"
    $sqlFiles = Get-ChildItem -Path $SCRIPT_DIR -Filter "*.sql" -Recurse | Sort-Object FullName

    # --- connect to DB ---
    $connectionString = "Server=$ServerInstance;Database=$Database;Integrated Security=True;"
    $connection = New-Object System.Data.SqlClient.SqlConnection $connectionString
    $connection.Open()

    # --- get applied scripts from UpdateIps ---
    $command = $connection.CreateCommand()
    $command.CommandText = "SELECT LOWER(RTRIM(LTRIM(REPLACE(ScriptName, '.sql','')))) AS ScriptName FROM UpdateIps"
    $reader = $command.ExecuteReader()
    $appliedScripts = @()
    while ($reader.Read()) { $appliedScripts += $reader["ScriptName"] }
    $reader.Close()

    # --- get applied versions from sch.dbversion safely ---
    $command.CommandText = @"
IF OBJECT_ID('sch.dbversion', 'U') IS NOT NULL
    SELECT DbVersion FROM sch.dbversion
ELSE
    SELECT NULL AS DbVersion WHERE 1=0
"@
    $reader = $command.ExecuteReader()
    $appliedVersions = @()
    while ($reader.Read()) { 
        if ($reader["DbVersion"] -ne $null) {
            $appliedVersions += $reader["DbVersion"].Trim().ToLower() 
        }
    }
    $reader.Close()

    # --- loop through SQL files ---
    foreach ($sqlFile in $sqlFiles) {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($sqlFile.FullName).Trim().ToLower()
        $versionFolder = Split-Path -Leaf $sqlFile.DirectoryName
        $versionFolderLower = $versionFolder.Trim().ToLower()

        $folderBase = ($versionFolderLower -replace '[a-z]$','')
        $appliedBaseVersions = $appliedVersions | ForEach-Object { ($_ -replace '[a-z]$','') }

        $isExceptionFolder = $SchExceptions -contains $versionFolderLower

        $skipScript = $false

        # 1. Already applied in UpdateIps
        if ($baseName -in $appliedScripts) { $skipScript = $true }

        # 2. Normal sch.dbversion check (skip only if not exception)
        elseif (-not $isExceptionFolder -and $folderBase -in $appliedBaseVersions) { $skipScript = $true }

        # 3. Exception folder check using local log
        elseif ($isExceptionFolder -and $baseName -in $schExecuted) { $skipScript = $true }

        if ($skipScript) {
            Write-Log "Skipping script: $($sqlFile.FullName)" "INFO"
            if ($isExceptionFolder) { $skippedDbVersionCount++ } else { $skippedUpdateIpsCount++ }
            continue
        }

        # Execute script
        Write-Log "Executing SQL script: $($sqlFile.FullName)" "INFO"
        ExecuteSqlScript -sqlFilePath $sqlFile.FullName
        $executedCount++

        # If this is an exception folder, log it locally
        if ($isExceptionFolder) {
		$logEntry = "$versionFolderLower\$baseName"
		Add-Content -Path $SchExecutedFile -Value $logEntry
}
    }

    $connection.Close()
}
catch {
    $exception = $_.Exception
    Write-Host "-------------------------------------"
    Write-Log "Message      : $($exception.Message)" "ERROR"
    Write-Log "Type         : $($exception.GetType().FullName)" "ERROR"
    Write-Log "StackTrace   : $($exception.StackTrace)" "ERROR"
}
finally {
    $scriptEndTime = Get-Date
    $totalDuration = $scriptEndTime - $scriptStartTime
    Write-Host "-------------------------------------"
    Write-Log "Script execution completed." "INFO"
    Write-Log "Total scripts executed       : $executedCount" "INFO"
    Write-Log "Total scripts skipped UpdateIps : $skippedUpdateIpsCount" "INFO"
    Write-Log "Total scripts skipped sch.dbversion exceptions : $skippedDbVersionCount" "INFO"
    Write-Log "Total execution time: $($totalDuration.TotalMinutes) minutes ($($totalDuration.TotalSeconds) seconds)" "INFO"
}
