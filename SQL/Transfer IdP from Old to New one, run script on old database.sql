
/*
-- This script should be run on the source/old database, and it will generate a script that should be run on the destinational/new database.


SELECT * FROM sys.tables
WHERE type = 'U'
AND [Name] NOT IN ('sysdiagrams', '__EFMigrationsHistory', '_AspNetUsers')
ORDER BY [Name]
*/

DECLARE @sqlupit NVARCHAR(MAX) = ''


-- modify database names according to your environment
	DECLARE @DatabaseFROM NVARCHAR(200) = '[IpsIdentityProvider_old]'
	DECLARE @DatabaseTO NVARCHAR(200) = '[IpsIdentityProvider_new]'


SELECT 
	@sqlupit = @sqlupit + 
	'-- we run script on destination database !!!' + CHAR(13)+CHAR(10) +
	CONCAT('USE ', @DatabaseTO, CHAR(13)+CHAR(10), 'GO',  CHAR(13)+CHAR(10), CHAR(13)+CHAR(10))

-- drop constraint
SELECT  
	@sqlupit = @sqlupit + 
	'-- disable constraint' + CHAR(13)+CHAR(10) +
	CONCAT( 'ALTER TABLE ', @DatabaseTO, '.', QUOTENAME(SCHEMA_NAME(schema_id)), '.', QUOTENAME([name]), ' NOCHECK CONSTRAINT ALL;')
	--, *
FROM sys.tables
WHERE type = 'U'
AND [Name] NOT IN ('sysdiagrams', '__EFMigrationsHistory', '_AspNetUsers')
ORDER BY [Name]

SET  @sqlupit = @sqlupit + CHAR(13)+CHAR(10) + 'GO ' + CHAR(13)+CHAR(10)

-- delete from existing tables
SELECT  
	@sqlupit = @sqlupit + 
	'-- delete existing data from destination ' + CHAR(13)+CHAR(10) +
	CONCAT( 'DELETE FROM ', @DatabaseTO, '.', QUOTENAME(SCHEMA_NAME(schema_id)), '.', QUOTENAME([name]), ';') 
	-- * 
FROM sys.tables
WHERE type = 'U'
AND [Name] NOT IN ('sysdiagrams', '__EFMigrationsHistory', '_AspNetUsers')
ORDER BY [Name]

SET  @sqlupit = @sqlupit + CHAR(13)+CHAR(10) + 'GO ' + CHAR(13)+CHAR(10)

---- kreiramo komandu za insert
---- Mora na bazi sa koje prepisujemo
--SELECT
--	t.[Name] TabName
--	, STRING_AGG( QUOTENAME(c.[name]), ', ') WITHIN GROUP (ORDER BY c.column_id) SpisakKolona
--FROM sys.tables t
--JOIN sys.columns c ON t.[object_id] = c.[object_id]
--WHERE t.type = 'U'
--AND t.[Name] NOT IN ('sysdiagrams', '__EFMigrationsHistory', '_AspNetUsers')
--GROUP BY t.[Name]
--ORDER BY t.[Name]


	; WITH Pom
	AS
	(
		SELECT
			QUOTENAME(SCHEMA_NAME(t.[schema_id])) SchName,
			QUOTENAME(t.[Name]) TabName,
			STRING_AGG( QUOTENAME(c.[name]), ', ') WITHIN GROUP (ORDER BY c.column_id) SpisakKolona,
			SUM(CAST(c.is_identity AS SMALLINT)) HasIdentity
		FROM sys.tables t
		JOIN sys.columns c ON t.[object_id] = c.[object_id]
		WHERE t.type = 'U'
		AND t.[Name] NOT IN ('sysdiagrams', '__EFMigrationsHistory', '_AspNetUsers')
		GROUP BY t.[Name], SCHEMA_NAME(t.[schema_id])
		-- ORDER BY t.[Name]
	)

	SELECT  @sqlupit = @sqlupit + 
		'-- Insert into destination database from source database' +  CHAR(13)+CHAR(10) +
		CONCAT(
				CASE WHEN HasIdentity > 0 THEN CONCAT('SET IDENTITY_INSERT ', @DatabaseTO, '.', Pom.SchName, '.', Pom.TabName, ' ON;')
					 WHEN HasIdentity = 0 THEN ''
				END, CHAR(13)+CHAR(10), 
				'INSERT INTO ', @DatabaseTO, '.', Pom.SchName, '.', Pom.TabName, 
				' (', Pom.SpisakKolona, ')', CHAR(13)+CHAR(10), 
				'SELECT ', Pom.SpisakKolona,  CHAR(13)+CHAR(10), 'FROM ', @DatabaseFROM, '.', Pom.SchName, '.', Pom.TabName, '; ', CHAR(13)+CHAR(10), 
				CASE WHEN HasIdentity > 0 THEN CONCAT('SET IDENTITY_INSERT ', @DatabaseTO, '.', Pom.SchName, '.', Pom.TabName, ' OFF;')
					 WHEN HasIdentity = 0 THEN ''
				END,
				CHAR(13)+CHAR(10), CHAR(13)+CHAR(10)
		) 
	FROM Pom

SET  @sqlupit = @sqlupit + CHAR(13)+CHAR(10) + 'GO ' + CHAR(13)+CHAR(10)

-- da vratimo constrainte
-- enable constraint
-- Ovo moze i na bazi na koju prepisujemo
SELECT  
	@sqlupit = @sqlupit + 
	'-- enable constraints on destination' + CHAR(13)+CHAR(10) +
	CONCAT( 'ALTER TABLE ', @DatabaseTO, '.', QUOTENAME(SCHEMA_NAME(schema_id)), '.', QUOTENAME([name]), ' WITH CHECK CHECK CONSTRAINT ALL;') 
	-- , * 
FROM sys.tables
WHERE type = 'U'
AND [Name] NOT IN ('sysdiagrams', '__EFMigrationsHistory', '_AspNetUsers')
ORDER BY [Name]

SET  @sqlupit = @sqlupit + CHAR(13)+CHAR(10) + 'GO ' + CHAR(13)+CHAR(10)


SELECT CAST(@sqlupit AS XML)

