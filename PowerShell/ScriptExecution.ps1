# NOTES: 
# Before running the script check:
# - v6.05.00 - Requires manual adjustments for script: 002, 003

#--------------------------------------
# Script input
#--------------------------------------


#--------------------------------------
# Script Configuration
#--------------------------------------

$SCRIPT_PATH = (Get-Variable MyInvocation).Value.MyCommand.Path
$SCRIPT_DIR = Split-Path -Parent $SCRIPT_PATH

$CONFIG = @{
    ServerInstance= "(local)"
    Database = "IpsEnergy193_AVO"
}

$LOCAL_FILES = @{
    LogFile= "$SCRIPT_DIR\_local\script.log" 
    ErrorLogFile= "$SCRIPT_DIR\_local\error.log"
    ProcessedScriptsFile= "$SCRIPT_DIR\_local\processed_scripts.log"
}

#--------------------------------------
# Functions
#--------------------------------------
function Write-Log {
    param (
        [string]$message,
        [string]$type = "INFO"
    )
    
    # log format
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$type] $message"

    # write to the log file
    Add-Content -Path $LOCAL_FILES.LogFile -Value "$logEntry`n"

    # output to the console for real-time feedback
    switch ($type) {
        "ERROR" { Write-Host $logEntry -ForegroundColor Red }
        "FATAL" { Write-Host $logEntry -ForegroundColor Red }
        default { Write-Host $logEntry }
    }
}

function Test-SqlConnection {
    param (
        [string]$serverInstance,
        [string]$database
    )

    try {
        Write-Log "Test SQL connection for Server: '$serverInstance', Database: '$database'" "INFO"

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

function Write-ProcessedScriptLog {
    param (
        [string]$sqlFilePath
    )

    Add-Content -Path $LOCAL_FILES.ProcessedScriptsFile -Value $sqlFilePath
}

function ExecuteSqlScript {
    param (
        [string]$sqlFilePath
    )
    
    try {
        $startTime = Get-Date
        
        # execute sql command
        Invoke-Sqlcmd -InputFile $sqlFilePath -ServerInstance $CONFIG.ServerInstance -Database $CONFIG.Database -ErrorAction Stop

        $endTime = Get-Date

        # calculate duration
        $duration = $endTime - $startTime

        Write-Log "Successfully executed $($sqlFilePath) in $($duration.TotalSeconds) seconds." "SUCCESS"

        # Log the hash-value | filepath into the processed scripts file
        Write-ProcessedScriptLog -sqlFilePath $sqlFilePath
    }
    catch {
        # get error information
        $errorDetails = $_.Exception.Message
        $stackTraceException = $_.Exception.StackTrace

        # format error message
        $errorMessage = "Error executing $($sqlFilePath): $errorDetails"
        Write-Log $errorMessage "ERROR"

        # Log error
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

try {
    # check administrator privileges
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "[ERROR] Please run this script as an Administrator." -ForegroundColor Red
        exit 1
    }

    # create local files if not exists
    $LOCAL_FILES.GetEnumerator() | ForEach-Object {
        if (-not (Test-Path $_.Value)) { New-Item -Path $_.Value -ItemType File -Force }
    }

    Write-Host "-------------------------------------"
    Write-Host "[INFO] *** Output Information ***"
    Write-Host "-------------------------------------"
    Write-Host "[INFO] Script                                  : $SCRIPT_PATH"
    Write-Host "[INFO] Working directory                       : $SCRIPT_DIR"
    # output configuration
    foreach ($key in $CONFIG.Keys) {
        Write-Host "[INFO] $($key.PadRight(40)): $($CONFIG[$key])"
    }
    # output local files
    foreach ($key in $LOCAL_FILES.Keys) {
        Write-Host "[INFO] $($key.PadRight(40)): $($LOCAL_FILES[$key])"
    }
    Write-Host "-------------------------------------"

    # test SQL Connection first
    if (-not (Test-SqlConnection -serverInstance $CONFIG.ServerInstance -database $CONFIG.Database)) {
        Write-Log "Invalid SQL connection. Exiting script." "ERROR"
        exit 1
    }

    $processedFolders = @()
    if (Test-Path $LOCAL_FILES.ProcessedScriptsFile) {
        $processedFolders = Get-Content $LOCAL_FILES.ProcessedScriptsFile | ForEach-Object { (Split-Path $_ -Parent | Split-Path -Leaf).Trim().ToLower() }
    }

    # process SQL files in the root folder first (if any)
    Write-Log "Processing SQL files in the root directory: $SCRIPT_DIR" "INFO"
    $rootSqlFiles = Get-ChildItem -Path $SCRIPT_DIR -Filter "*.sql" | Sort-Object Name
    
    foreach ($sqlFile in $rootSqlFiles) {
        Write-Log "Executing SQL script: $($sqlFile.FullName)" "INFO"
        ExecuteSqlScript -sqlFilePath $sqlFile.FullName
    }

    # get all subdirectories in the script root directory and sort by name
    $folders = Get-ChildItem -Path $SCRIPT_DIR -Directory | Sort-Object Name

    # start process each found folder
    foreach ($folder in $folders) {
        # If the folder version was already processed, skip it
        if ($processedFolders -contains $folder.Name.Trim().ToLower()) {
            Write-Log "Skip already processed folder: $($folder.Name)" "INFO"
            continue
        }

        Write-Log "Processing folder: $($folder.Name)" "INFO"

        $sqlFiles = Get-ChildItem -Path $folder.FullName -Filter "*.sql" | Sort-Object Name

        if ($sqlFiles.Count -eq 0) {
            Write-Log "No SQL files found in folder: $($folder.Name)" "INFO"
            continue
        }

        foreach ($sqlFile in $sqlFiles) {
            Write-Log "Executing SQL script: $($sqlFile.FullName)" "INFO"
            ExecuteSqlScript -sqlFilePath $sqlFile.FullName
        }

        Write-Log "Completed processing folder: $($folder.Name)" "INFO"
    }
}
catch 
{
    $exception = $_.Exception
    Write-Host "-------------------------------------"
    Write-Log "Message               : $($exception.Message)" "ERROR"
    Write-Log "Type                  : $($exception.GetType().FullName)" "ERROR"
    Write-Log "StackTrace            : $($exception.StackTrace)" "ERROR"
}
finally
{
    $scriptEndTime = Get-Date
    $totalDuration = $scriptEndTime - $scriptStartTime
    Write-Host "-------------------------------------"
    Write-Log "Script execution completed." "INFO"
    Write-Log "Total execution time: $($totalDuration.TotalMinutes) minutes ($($totalDuration.TotalSeconds) seconds)" "INFO"
}
