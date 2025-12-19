# =========================================
# Compare full schema between two SQL Server DBs (Console-only)
# - Columns, PKs, FKs, Unique constraints, Indexes
# =========================================

# -----------------------------
# CONFIG
# -----------------------------
$Server = "RS-MATICD"         # e.g. "localhost\SQLEXPRESS"
$DB1    = "IpsIdentityProvider"
$DB2    = "IpsIdentityProvider_v8"
$AutoInstallSqlModule = $true

# -----------------------------
# PREP: Ensure SqlServer module
# -----------------------------
function Ensure-SqlModule {
    param([bool]$AutoInstall = $true)
    if (Get-Command Invoke-Sqlcmd -ErrorAction SilentlyContinue) { return $true }

    Write-Host "Invoke-Sqlcmd not found."
    if (-not $AutoInstall) { throw "SqlServer module not found. Please Install-Module SqlServer." }

    Write-Host "Installing SqlServer module..."
    Install-Module -Name SqlServer -Scope CurrentUser -Force -AllowClobber
    Import-Module SqlServer
}

Ensure-SqlModule -AutoInstall:$AutoInstallSqlModule

# -----------------------------
# QUERIES
# -----------------------------
$QueryColumns = @"
SELECT 
    c.TABLE_SCHEMA,
    c.TABLE_NAME,
    c.COLUMN_NAME,
    c.ORDINAL_POSITION,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(object_id(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IsIdentity
FROM INFORMATION_SCHEMA.COLUMNS c
ORDER BY c.TABLE_SCHEMA, c.TABLE_NAME, c.ORDINAL_POSITION;
"@

$QueryPKs = @"
SELECT
    s.name AS TABLE_SCHEMA,
    o.name AS TABLE_NAME,
    kc.name AS PK_NAME,
    col.name AS COLUMN_NAME,
    ic.key_ordinal
FROM sys.key_constraints kc
JOIN sys.objects o ON kc.parent_object_id = o.object_id
JOIN sys.schemas s ON o.schema_id = s.schema_id
JOIN sys.index_columns ic ON kc.unique_index_id = ic.index_id AND ic.object_id = o.object_id
JOIN sys.columns col ON ic.object_id = col.object_id AND ic.column_id = col.column_id
WHERE kc.type = 'PK'
ORDER BY s.name, o.name, kc.name, ic.key_ordinal;
"@

$QueryUQ = @"
SELECT
    s.name AS TABLE_SCHEMA,
    o.name AS TABLE_NAME,
    kc.name AS UQ_NAME,
    col.name AS COLUMN_NAME,
    ic.key_ordinal
FROM sys.key_constraints kc
JOIN sys.objects o ON kc.parent_object_id = o.object_id
JOIN sys.schemas s ON o.schema_id = s.schema_id
JOIN sys.index_columns ic ON kc.unique_index_id = ic.index_id AND ic.object_id = o.object_id
JOIN sys.columns col ON ic.object_id = col.object_id AND ic.column_id = col.column_id
WHERE kc.type = 'UQ'
ORDER BY s.name, o.name, kc.name, ic.key_ordinal;
"@

$QueryFKs = @"
SELECT
    s.name AS TABLE_SCHEMA,
    o.name AS TABLE_NAME,
    fk.name AS FK_NAME,
    parent_col.name AS PARENT_COLUMN,
    ref_s.name AS REF_SCHEMA,
    ref_o.name AS REF_TABLE,
    ref_col.name AS REF_COLUMN,
    fkcols.constraint_column_id
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkcols ON fk.object_id = fkcols.constraint_object_id
JOIN sys.objects o ON fk.parent_object_id = o.object_id
JOIN sys.schemas s ON o.schema_id = s.schema_id
JOIN sys.objects ref_o ON fk.referenced_object_id = ref_o.object_id
JOIN sys.schemas ref_s ON ref_o.schema_id = ref_s.schema_id
JOIN sys.columns parent_col ON fkcols.parent_object_id = parent_col.object_id AND fkcols.parent_column_id = parent_col.column_id
JOIN sys.columns ref_col ON fkcols.referenced_object_id = ref_col.object_id AND fkcols.referenced_column_id = ref_col.column_id
ORDER BY s.name, o.name, fk.name, fkcols.constraint_column_id;
"@

$QueryIndexes = @"
SELECT
    s.name AS TABLE_SCHEMA,
    o.name AS TABLE_NAME,
    i.name AS INDEX_NAME,
    i.is_unique,
    i.is_primary_key,
    i.is_unique_constraint,
    i.type_desc,
    col.name AS COLUMN_NAME,
    ic.key_ordinal,
    ic.is_included_column
FROM sys.indexes i
JOIN sys.objects o ON i.object_id = o.object_id
JOIN sys.schemas s ON o.schema_id = s.schema_id
JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN sys.columns col ON ic.object_id = col.object_id AND ic.column_id = col.column_id
WHERE o.type = 'U'
ORDER BY s.name, o.name, i.name, ic.key_ordinal, ic.is_included_column;
"@

# -----------------------------
# FUNCTIONS
# -----------------------------
function Get-DbObjects { param($Server,$DB,$Query); Invoke-Sqlcmd -ServerInstance $Server -Database $DB -Query $Query }

function Build-ColumnSignature($rows) {
    if (-not $rows) { return "" }
    $ordered = $rows | Sort-Object @{Expression={ if ($_.PSObject.Properties.Match('ORDINAL_POSITION')) { [int]$_.ORDINAL_POSITION } else { if ($_.PSObject.Properties.Match('key_ordinal')) { [int]$_.key_ordinal } else {0}}}}
    return ($ordered | ForEach-Object { $_.COLUMN_NAME }) -join "|"
}

function Build-IndexSignature($indexRows) {
    if (-not $indexRows) { return "" }
    $keyCols = $indexRows | Where-Object { -not $_.is_included_column } | Sort-Object key_ordinal | ForEach-Object { $_.COLUMN_NAME }
    $incCols = $indexRows | Where-Object { $_.is_included_column -eq 1 } | Sort-Object key_ordinal | ForEach-Object { $_.COLUMN_NAME }
    $sigKey = ($keyCols -join ",")
    $sigInc = if ($incCols) { "|" + ($incCols -join ",") } else { "" }
    return "$sigKey$sigInc"
}

# -----------------------------
# LOAD SCHEMA
# -----------------------------
Write-Host "Loading schema from ${DB1} ..."
$Cols1 = Get-DbObjects $Server $DB1 $QueryColumns
$PKs1  = Get-DbObjects $Server $DB1 $QueryPKs
$UQ1   = Get-DbObjects $Server $DB1 $QueryUQ
$FKs1  = Get-DbObjects $Server $DB1 $QueryFKs
$Idx1  = Get-DbObjects $Server $DB1 $QueryIndexes

Write-Host "Loading schema from ${DB2} ..."
$Cols2 = Get-DbObjects $Server $DB2 $QueryColumns
$PKs2  = Get-DbObjects $Server $DB2 $QueryPKs
$UQ2   = Get-DbObjects $Server $DB2 $QueryUQ
$FKs2  = Get-DbObjects $Server $DB2 $QueryFKs
$Idx2  = Get-DbObjects $Server $DB2 $QueryIndexes

# -----------------------------
# TABLES
# -----------------------------
$Tables1 = $Cols1 | Select-Object TABLE_SCHEMA,TABLE_NAME -Unique
$Tables2 = $Cols2 | Select-Object TABLE_SCHEMA,TABLE_NAME -Unique

$MissingIn2 = Compare-Object $Tables1 $Tables2 -Property TABLE_SCHEMA,TABLE_NAME -PassThru | Where-Object {$_.SideIndicator -eq "<="}
$MissingIn1 = Compare-Object $Tables1 $Tables2 -Property TABLE_SCHEMA,TABLE_NAME -PassThru | Where-Object {$_.SideIndicator -eq "=>"}

if ($MissingIn2) {
    Write-Host "`nTables present in ${DB1} but missing in ${DB2}:" -ForegroundColor Yellow
    $MissingIn2 | ForEach-Object { Write-Host " - $($_.TABLE_SCHEMA).$($_.TABLE_NAME)" }
}
if ($MissingIn1) {
    Write-Host "`nTables present in ${DB2} but missing in ${DB1}:" -ForegroundColor Yellow
    $MissingIn1 | ForEach-Object { Write-Host " - $($_.TABLE_SCHEMA).$($_.TABLE_NAME)" }
}

# -----------------------------
# SHARED TABLES
# -----------------------------
$Shared = $Tables1 | Where-Object { ($Tables2 | Where-Object { $_.TABLE_SCHEMA -eq $_.TABLE_SCHEMA -and $_.TABLE_NAME -eq $_.TABLE_NAME }).Count -gt 0 }
Write-Host "`n==== Comparing shared tables ($($Shared.Count)) ====`n"

foreach ($t in $Shared) {
    $schema = $t.TABLE_SCHEMA
    $name = $t.TABLE_NAME
    $c1 = $Cols1 | Where-Object { $_.TABLE_SCHEMA -eq $schema -and $_.TABLE_NAME -eq $name }
    $c2 = $Cols2 | Where-Object { $_.TABLE_SCHEMA -eq $schema -and $_.TABLE_NAME -eq $name }
    $differencesFound = $false

    # Columns missing
    $onlyIn1 = Compare-Object $c1.COLUMN_NAME $c2.COLUMN_NAME -PassThru | Where-Object { $_.SideIndicator -eq "<=" }
    $onlyIn2 = Compare-Object $c1.COLUMN_NAME $c2.COLUMN_NAME -PassThru | Where-Object { $_.SideIndicator -eq "=>" }

    if ($onlyIn1 -or $onlyIn2) {
        $differencesFound = $true
        Write-Host "[$schema.$name] Columns missing:" -ForegroundColor Cyan
        if ($onlyIn1) { Write-Host "  In ${DB1} only:"; $onlyIn1 | ForEach-Object { Write-Host "   - $_" } }
        if ($onlyIn2) { Write-Host "  In ${DB2} only:"; $onlyIn2 | ForEach-Object { Write-Host "   - $_" } }
    }

    # Shared columns attribute differences
    $sharedCols = ($c1.COLUMN_NAME | Where-Object { $_ -in $c2.COLUMN_NAME })
    foreach ($colName in $sharedCols) {
        $r1 = $c1 | Where-Object { $_.COLUMN_NAME -eq $colName } | Select-Object -First 1
        $r2 = $c2 | Where-Object { $_.COLUMN_NAME -eq $colName } | Select-Object -First 1
        $attrDiffs = @()

        if (($r1.DATA_TYPE) -ne ($r2.DATA_TYPE)) { $attrDiffs += "DataType: $($r1.DATA_TYPE) vs $($r2.DATA_TYPE)" }

        $len1 = if ($r1.CHARACTER_MAXIMUM_LENGTH -ne $null) { $r1.CHARACTER_MAXIMUM_LENGTH } else { "$($r1.NUMERIC_PRECISION),$($r1.NUMERIC_SCALE)" }
        $len2 = if ($r2.CHARACTER_MAXIMUM_LENGTH -ne $null) { $r2.CHARACTER_MAXIMUM_LENGTH } else { "$($r2.NUMERIC_PRECISION),$($r2.NUMERIC_SCALE)" }
        if ($len1 -ne $len2) { $attrDiffs += "Length/Precision: $len1 vs $len2" }

        if (($r1.IS_NULLABLE) -ne ($r2.IS_NULLABLE)) { $attrDiffs += "Nullable: $($r1.IS_NULLABLE) vs $($r2.IS_NULLABLE)" }
        if ((($r1.COLUMN_DEFAULT -as [string]) -ne ($r2.COLUMN_DEFAULT -as [string])) -and ($r1.COLUMN_DEFAULT -ne $null -or $r2.COLUMN_DEFAULT -ne $null)) { $attrDiffs += "Default: $($r1.COLUMN_DEFAULT) vs $($r2.COLUMN_DEFAULT)" }
        if (($r1.IsIdentity) -ne ($r2.IsIdentity)) { $attrDiffs += "Identity: $($r1.IsIdentity) vs $($r2.IsIdentity)" }

        if ($attrDiffs.Count -gt 0) {
            if (-not $differencesFound) { Write-Host "[$schema.$name] Column attribute differences:" -ForegroundColor Cyan; $differencesFound = $true }
            Write-Host "  $colName"
            $attrDiffs | ForEach-Object { Write-Host "    - $_" }
        }
    }

    # Primary Keys
    $pk1rows = $PKs1 | Where-Object { $_.TABLE_SCHEMA -eq $schema -and $_.TABLE_NAME -eq $name }
    $pk2rows = $PKs2 | Where-Object { $_.TABLE_SCHEMA -eq $schema -and $_.TABLE_NAME -eq $name }
    $pkSig1 = Build-ColumnSignature $pk1rows
    $pkSig2 = Build-ColumnSignature $pk2rows
    $pk1 = if ([string]::IsNullOrEmpty($pkSig1)) { "<none>" } else { $pkSig1 }
    $pk2 = if ([string]::IsNullOrEmpty($pkSig2)) { "<none>" } else { $pkSig2 }

    if ($pk1 -ne $pk2) {
        $differencesFound = $true
        Write-Host "[$schema.$name] PRIMARY KEY difference:" -ForegroundColor Magenta
        Write-Host "  ${DB1} PK: $pk1"
        Write-Host "  ${DB2} PK: $pk2"
    }

    # Unique Constraints
    $uq1rows = $UQ1 | Where-Object { $_.TABLE_SCHEMA -eq $schema -and $_.TABLE_NAME -eq $name }
    $uq2rows = $UQ2 | Where-Object { $_.TABLE_SCHEMA -eq $schema -and $_.TABLE_NAME -eq $name }
    $uqNames = ($uq1rows.UQ_NAME + $uq2rows.UQ_NAME) | Sort-Object -Unique
    foreach ($uq in $uqNames) {
        $uqCols1 = $uq1rows | Where-Object { $_.UQ_NAME -eq $uq } | ForEach-Object { [PSCustomObject]@{ COLUMN_NAME = $_.COLUMN_NAME } }
        $uqCols2 = $uq2rows | Where-Object { $_.UQ_NAME -eq $uq } | ForEach-Object { [PSCustomObject]@{ COLUMN_NAME = $_.COLUMN_NAME } }
        $sig1 = Build-ColumnSignature $uqCols1
        $sig2 = Build-ColumnSignature $uqCols2
        if ($sig1 -ne $sig2) {
            $differencesFound = $true
            Write-Host "[$schema.$name] UNIQUE Constraint difference ($uq):" -ForegroundColor Magenta
            Write-Host "  ${DB1}: $sig1"
            Write-Host "  ${DB2}: $sig2"
        }
    }

    # Foreign Keys
    $fk1rows = $FKs1 | Where-Object { $_.TABLE_SCHEMA -eq $schema -and $_.TABLE_NAME -eq $name }
    $fk2rows = $FKs2 | Where-Object { $_.TABLE_SCHEMA -eq $schema -and $_.TABLE_NAME -eq $name }
    $fkNames = ($fk1rows.FK_NAME + $fk2rows.FK_NAME) | Sort-Object -Unique
    foreach ($fk in $fkNames) {
        $fkCols1 = $fk1rows | Where-Object { $_.FK_NAME -eq $fk } | ForEach-Object { [PSCustomObject]@{ COLUMN_NAME = $_.PARENT_COLUMN } }
        $fkCols2 = $fk2rows | Where-Object { $_.FK_NAME -eq $fk } | ForEach-Object { [PSCustomObject]@{ COLUMN_NAME = $_.PARENT_COLUMN } }
        $sig1 = Build-ColumnSignature $fkCols1
        $sig2 = Build-ColumnSignature $fkCols2
        $ref1 = ($fk1rows | Where-Object { $_.FK_NAME -eq $fk } | Select-Object -First 1).REF_TABLE
        $ref2 = ($fk2rows | Where-Object { $_.FK_NAME -eq $fk } | Select-Object -First 1).REF_TABLE
        if ($sig1 -ne $sig2 -or $ref1 -ne $ref2) {
            $differencesFound = $true
            Write-Host "[$schema.$name] FOREIGN KEY difference ($fk):" -ForegroundColor Magenta
            Write-Host "  ${DB1}: $sig1 -> $ref1"
            Write-Host "  ${DB2}: $sig2 -> $ref2"
        }
    }

    # Indexes
    $idx1rows = $Idx1 | Where-Object { $_.TABLE_SCHEMA -eq $schema -and $_.TABLE_NAME -eq $name }
    $idx2rows = $Idx2 | Where-Object { $_.TABLE_SCHEMA -eq $schema -and $_.TABLE_NAME -eq $name }
    $idxNames = ($idx1rows.INDEX_NAME + $idx2rows.INDEX_NAME) | Sort-Object -Unique
    foreach ($idx in $idxNames) {
        $sig1 = Build-IndexSignature ($idx1rows | Where-Object { $_.INDEX_NAME -eq $idx })
        $sig2 = Build-IndexSignature ($idx2rows | Where-Object { $_.INDEX_NAME -eq $idx })
        if ($sig1 -ne $sig2) {
            $differencesFound = $true
            Write-Host "[$schema.$name] INDEX difference ($idx):" -ForegroundColor Magenta
            Write-Host "  ${DB1}: $sig1"
            Write-Host "  ${DB2}: $sig2"
        }
    }

    if (-not $differencesFound) {
        Write-Host "[$schema.$name] OK (no structural differences found)" -ForegroundColor Green
    } else {
        Write-Host "----"
    }
}

Write-Host "`n==== Schema comparison completed ====" -ForegroundColor Cyan
