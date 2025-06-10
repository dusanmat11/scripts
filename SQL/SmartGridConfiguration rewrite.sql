
-- Config baza
-- Configuration Datasource connections, SystemSetting 
-- Datasouces authentification must be MANUALLY changed!!!


SELECT * FROM [IpsSmartGridConfiguration_DP_QA]..Datasource
SELECT * FROM [IpsSmartGridConfiguration_DP_QA_ZaBrisanje]..Datasource


/* -- Datasource

UPDATE dsnew
SET dsnew.DatabaseName = dsold.DatabaseName, dsnew.ServerName = dsold.ServerName
-- SELECT dsnew.DatasourceId, dsnew.DatabaseName, dsold.DatasourceId, dsold.DatabaseName
FROM [IpsSmartGridConfiguration_DP_QA]..Datasource dsnew
JOIN [IpsSmartGridConfiguration_DP_QA_ZaBrisanje]..Datasource dsold on dsnew.DatasourceId = dsold.DatasourceId
GO
*/



SELECT * FROM [IpsSmartGridConfiguration_DP_QA]..SystemSetting
SELECT * FROM [IpsSmartGridConfiguration_DP_QA_ZaBrisanje]..SystemSetting

/* -- SystemSetting

UPDATE ssnew
SET ssnew.SettingValue = ssold.SettingValue
---- prvo malo proveriti pa onda update
--SELECT ssnew.SystemSettingID, ssnew.SettingName, ssnew.SettingValue, ssnew.SettingGroup, ssnew.Visible, ssnew.[ReadOnly]
--	  ,ssold.SystemSettingID, ssold.SettingName, ssold.SettingValue, ssold.SettingGroup, ssold.Visible, ssold.[ReadOnly]
FROM [IpsSmartGridConfiguration_DP_QA]..SystemSetting ssnew
FULL JOIN [IpsSmartGridConfiguration_DP_QA_ZaBrisanje]..SystemSetting ssold on ssnew.SystemSettingID = ssold.SystemSettingID
WHERE ssnew.SettingValue <> ssold.SettingValue
-- OR BINARY_CHECKSUM(ssnew.SettingName, ssnew.SettingValue, ssnew.SettingGroup, ssnew.Visible, ssnew.[ReadOnly]) <> BINARY_CHECKSUM(ssold.SettingName, ssold.SettingValue, ssold.SettingGroup, ssold.Visible, ssold.[ReadOnly])
GO

*/



