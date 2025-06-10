:SETVAR NovaBaza "IpsEnergy193_DEO_TEST" -- Baza u koju prebacujemo
:SETVAR StaraBaza "IpsEnergy193_DEO_TEST_20231027" -- Baza sa koje prebacujemo


-- Ips Baza
-- UsrUsers, UsrGroups, UsrUsersGroups, UsrFunctionsGroups
-- UsrTickets,  UsrUsersTickets 


-- truncate i insert

TRUNCATE TABLE [$(NovaBaza)]..UsrTickets
GO

INSERT INTO [$(NovaBaza)]..UsrTickets
SELECT * FROM [$(StaraBaza)]..UsrTickets
GO

TRUNCATE TABLE [$(NovaBaza)]..UsrUsersTickets
GO

INSERT INTO [$(NovaBaza)]..UsrUsersTickets
SELECT * FROM [$(StaraBaza)]..UsrUsersTickets
GO

TRUNCATE TABLE [$(NovaBaza)]..UsrMachines
GO

INSERT INTO [$(NovaBaza)]..UsrMachines
SELECT * FROM [$(StaraBaza)]..UsrMachines
GO


-- skini constrainte

ALTER TABLE [$(NovaBaza)]..UsrUsers NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [$(NovaBaza)]..UsrGroups NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [$(NovaBaza)]..UsrUsersGroups NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [$(NovaBaza)]..UsrFunctionsGroups NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [$(NovaBaza)].sch.Employee NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [$(NovaBaza)].sch.Team NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [$(NovaBaza)].dbo.UsrInvisibleObjects NOCHECK CONSTRAINT ALL
GO


-- delete i insert


DELETE FROM [$(NovaBaza)]..UsrUsers
GO
INSERT INTO [$(NovaBaza)]..UsrUsers
SELECT * FROM [$(StaraBaza)]..UsrUsers
GO


DELETE FROM [$(NovaBaza)]..UsrGroups
GO
INSERT INTO [$(NovaBaza)]..UsrGroups
SELECT * FROM [$(StaraBaza)]..UsrGroups
GO

DELETE FROM [$(NovaBaza)]..UsrUsersGroups
GO
INSERT INTO [$(NovaBaza)]..UsrUsersGroups
SELECT * FROM [$(StaraBaza)]..UsrUsersGroups
GO

DELETE FROM [$(NovaBaza)]..UsrFunctionsGroups
GO
INSERT INTO [$(NovaBaza)]..UsrFunctionsGroups
SELECT * FROM [$(StaraBaza)]..UsrFunctionsGroups
GO

DELETE FROM [$(NovaBaza)].sch.Employee
GO
INSERT INTO [$(NovaBaza)].sch.Employee
SELECT * FROM [$(StaraBaza)].sch.Employee
GO

DELETE FROM [$(NovaBaza)].dbo.UsrInvisibleObjects
GO
INSERT INTO [$(NovaBaza)].dbo.UsrInvisibleObjects
SELECT * FROM [$(StaraBaza)].dbo.UsrInvisibleObjects
GO

-- vrati constrainte

ALTER TABLE [$(NovaBaza)]..UsrUsers WITH CHECK CHECK CONSTRAINT ALL
GO

ALTER TABLE [$(NovaBaza)]..UsrGroups WITH CHECK CHECK CONSTRAINT ALL
GO

ALTER TABLE [$(NovaBaza)]..UsrUsersGroups WITH CHECK CHECK CONSTRAINT ALL
GO

ALTER TABLE [$(NovaBaza)]..UsrFunctionsGroups WITH CHECK CHECK CONSTRAINT ALL
GO

ALTER TABLE [$(NovaBaza)].sch.Employee WITH CHECK CHECK CONSTRAINT ALL
GO

ALTER TABLE [$(NovaBaza)].sch.Team WITH CHECK CHECK CONSTRAINT ALL
GO

ALTER TABLE [$(NovaBaza)]..UsrInvisibleObjects WITH CHECK CHECK CONSTRAINT ALL
GO


