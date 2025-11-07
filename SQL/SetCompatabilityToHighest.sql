DECLARE @MaxCompatLevel INT;

-- Get the highest compatibility level supported by this SQL Server instance
SELECT @MaxCompatLevel = compatibility_level
FROM sys.databases
WHERE name = 'tempdb';  -- tempdb always matches the current SQL Server version

PRINT 'Highest supported compatibility level is: ' + CAST(@MaxCompatLevel AS VARCHAR(10));

DECLARE @DBName SYSNAME;
DECLARE @SQL NVARCHAR(MAX);

-- Cursor through all user databases (excluding system ones)
DECLARE db_cursor CURSOR FOR
SELECT name 
FROM sys.databases 
WHERE database_id > 4;  -- skip master, model, msdb, tempdb

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DBName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = 'ALTER DATABASE [' + @DBName + '] SET COMPATIBILITY_LEVEL = ' + CAST(@MaxCompatLevel AS VARCHAR(10)) + ';';
    PRINT @SQL;  -- for review/logging
    EXEC sp_executesql @SQL;

    FETCH NEXT FROM db_cursor INTO @DBName;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;
