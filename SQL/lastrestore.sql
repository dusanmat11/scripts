SELECT TOP (1)
    rh.destination_database_name AS DatabaseName,
    rh.restore_date,
    bmf.physical_device_name AS BackupFile
FROM msdb.dbo.restorehistory rh
INNER JOIN msdb.dbo.backupset bs
    ON rh.backup_set_id = bs.backup_set_id
INNER JOIN msdb.dbo.backupmediafamily bmf
    ON bs.media_set_id = bmf.media_set_id
WHERE rh.destination_database_name = 'YourDatabaseName'
ORDER BY rh.restore_date DESC;