/*
===================================================================
Object:			Table [dbo].[Settings]
Created:		03/01/2023
Last Update:	03/01/2023
Version:		v.1
Author:			Ivan Stamenic
Description:	Copy all available settings from v4 to v6 database. 
===================================================================
*/

USE [IpsIdentityProvider]
GO

DECLARE @SettingId as nvarchar(450);
DECLARE @SettingValue as nvarchar(max)
DECLARE @BusinessCursor as CURSOR;

SET @BusinessCursor = CURSOR FOR SELECT [Id], [Value] FROM Settings

OPEN @BusinessCursor;
FETCH NEXT FROM @BusinessCursor INTO @SettingId, @SettingValue;
WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Replace database name with v6 database
		IF EXISTS (SELECT * FROM [IpsIdentityProvider].[dbo].[Settings] WHERE [Id] = @SettingId)
			BEGIN
				-- Replace database name with v6 database
				UPDATE [IpsIdentityProvider].[dbo].[Settings]
				SET [Value] = @SettingValue
				WHERE [Id] = @SettingId
			END
		FETCH NEXT FROM @BusinessCursor INTO @SettingId, @SettingValue;
	END