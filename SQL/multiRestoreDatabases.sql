USE [master]


RESTORE DATABASE [IpsEnergyCache] FROM  DISK = N'D:\dusmat00\IpsEnergyCache_2026-06-30.bak' WITH  FILE = 1,   STATS = 5

GO

RESTORE DATABASE [IpsEnergy193] FROM  DISK = N'D:\dusmat00\IpsEnergy193_2026-06-30.bak' WITH  FILE = 1,   STATS = 5

GO

RESTORE DATABASE [IpsEnergyServices_REST] FROM  DISK = N'D:\dusmat00\IpsEnergyServices_REST_2026-06-30.bak' WITH  FILE = 1,   STATS = 5

GO

RESTORE DATABASE [IpsIdentityProvider] FROM  DISK = N'D:\dusmat00\IpsIdentityProvider_2026-06-30.bak' WITH  FILE = 1,   STATS = 5

GO

RESTORE DATABASE [IpsSmartGridConfiguration] FROM  DISK = N'D:\dusmat00\IpsSmartGridConfiguration_2026-06-30.bak' WITH  FILE = 1,   STATS = 5

GO

RESTORE DATABASE [IpsSmartGridDI] FROM  DISK = N'D:\dusmat00\IpsSmartGridDI_2026-06-30.bak' WITH  FILE = 1,   STATS = 5

GO



