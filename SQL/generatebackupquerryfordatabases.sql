-- !!! Upisati putanju za backup

DECLARE @putanja NVARCHAR(255)

SET @putanja = 'D:\dusmat00\databases for new environments\' -- mora na kraju \
 
DECLARE @nl NVARCHAR(10)

SET @nl = CHAR(10) + CHAR(13)
 
SELECT 

	'BACKUP DATABASE [' + name + '] TO DISK = ''' + @putanja + name + '_' + cast(cast(getdate() as date) as nvarchar(50)) + '.bak''' + ' WITH COMPRESSION' + @nl + 'GO' + @nl

	,[name] AS DatabaseName

FROM sys.databases

WHERE database_id > 4

-- AND [name] LIKE '%stage%'