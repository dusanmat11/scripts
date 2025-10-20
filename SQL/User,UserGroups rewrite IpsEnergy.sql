-- =======================================================
-- Database variables
-- =======================================================
:SETVAR NovaBaza "IpsEnergy193_TN_TEST"        -- Target Database
:SETVAR StaraBaza "IpsEnergy193_TN_TEST_20250902" -- Source Database

-- =======================================================
-- Ips Tables
-- =======================================================

-- UsrTickets
TRUNCATE TABLE [$(NovaBaza)]..UsrTickets;
GO
INSERT INTO [$(NovaBaza)]..UsrTickets
SELECT * FROM [$(StaraBaza)]..UsrTickets;
GO

-- UsrUsersTickets
TRUNCATE TABLE [$(NovaBaza)]..UsrUsersTickets;
GO
INSERT INTO [$(NovaBaza)]..UsrUsersTickets
SELECT * FROM [$(StaraBaza)]..UsrUsersTickets;
GO

-- UsrMachines
TRUNCATE TABLE [$(NovaBaza)]..UsrMachines;
GO
INSERT INTO [$(NovaBaza)]..UsrMachines
SELECT * FROM [$(StaraBaza)]..UsrMachines;
GO

-- =======================================================
-- Disable constraints
-- =======================================================
ALTER TABLE [$(NovaBaza)]..UsrUsers            NOCHECK CONSTRAINT ALL;
GO
ALTER TABLE [$(NovaBaza)]..UsrGroups           NOCHECK CONSTRAINT ALL;
GO
ALTER TABLE [$(NovaBaza)]..UsrUsersGroups      NOCHECK CONSTRAINT ALL;
GO
ALTER TABLE [$(NovaBaza)]..UsrFunctionsGroups  NOCHECK CONSTRAINT ALL;
GO
ALTER TABLE [$(NovaBaza)].sch.Employee         NOCHECK CONSTRAINT ALL;
GO
ALTER TABLE [$(NovaBaza)].sch.Team             NOCHECK CONSTRAINT ALL;
GO
ALTER TABLE [$(NovaBaza)].dbo.UsrInvisibleObjects NOCHECK CONSTRAINT ALL;
GO

-- =======================================================
-- Delete and Insert data
-- =======================================================

-- UsrUsers
DELETE FROM [$(NovaBaza)]..UsrUsers;
GO
INSERT INTO [$(NovaBaza)]..UsrUsers
SELECT * FROM [$(StaraBaza)]..UsrUsers;
GO

-- UsrGroups
DELETE FROM [$(NovaBaza)]..UsrGroups;
GO
INSERT INTO [$(NovaBaza)]..UsrGroups
SELECT * FROM [$(StaraBaza)]..UsrGroups;
GO

-- UsrUsersGroups
DELETE FROM [$(NovaBaza)]..UsrUsersGroups;
GO
INSERT INTO [$(NovaBaza)]..UsrUsersGroups
SELECT * FROM [$(StaraBaza)]..UsrUsersGroups;
GO

-- UsrFunctionsGroups
DELETE FROM [$(NovaBaza)]..UsrFunctionsGroups;
GO
INSERT INTO [$(NovaBaza)]..UsrFunctionsGroups
SELECT * FROM [$(StaraBaza)]..UsrFunctionsGroups;
GO

-- Company
DELETE FROM [$(NovaBaza)].sch.Company;
GO
INSERT INTO [$(NovaBaza)].sch.Company
SELECT * FROM [$(StaraBaza)].sch.Company;
GO

-- Employee
DELETE FROM [$(NovaBaza)].sch.Employee;
GO
INSERT INTO [$(NovaBaza)].sch.Employee
SELECT * FROM [$(StaraBaza)].sch.Employee;
GO

-- UsrInvisibleObjects
DELETE FROM [$(NovaBaza)].dbo.UsrInvisibleObjects;
GO
INSERT INTO [$(NovaBaza)].dbo.UsrInvisibleObjects
SELECT * FROM [$(StaraBaza)].dbo.UsrInvisibleObjects;
GO

-- =======================================================
-- Re-enable constraints
-- =======================================================
ALTER TABLE [$(NovaBaza)]..UsrUsers            WITH CHECK CHECK CONSTRAINT ALL;
GO
ALTER TABLE [$(NovaBaza)]..UsrGroups           WITH CHECK CHECK CONSTRAINT ALL;
GO
ALTER TABLE [$(NovaBaza)]..UsrUsersGroups      WITH CHECK CHECK CONSTRAINT ALL;
GO
ALTER TABLE [$(NovaBaza)]..UsrFunctionsGroups  WITH CHECK CHECK CONSTRAINT ALL;
GO
ALTER TABLE [$(NovaBaza)].sch.Employee         WITH CHECK CHECK CONSTRAINT ALL;
GO
ALTER TABLE [$(NovaBaza)].sch.Team             WITH CHECK CHECK CONSTRAINT ALL;
GO
ALTER TABLE [$(NovaBaza)]..UsrInvisibleObjects WITH CHECK CHECK CONSTRAINT ALL;
GO
