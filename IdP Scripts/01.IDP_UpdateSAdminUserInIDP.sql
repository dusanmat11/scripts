DELETE FROM [dbo].[UserRoles]
GO
 
DELETE FROM [dbo].[UserOrganizations]
GO
 
DELETE FROM [dbo].[UserSubscriptions]
GO
 
DELETE FROM [dbo].[Users]
GO
 
INSERT INTO [dbo].[Users] ([Id],[UserName])
SELECT Id, Username 
FROM AspNetUsers au where au.UserName = 'Administrator'
GO
 
INSERT INTO [dbo].[UserSubscriptions] ([UserId],[SubscriptionId])
VALUES
	((SELECT Id FROM [dbo].[Users] WHERE [UserName] = 'administrator'),
	(SELECT Id FROM [dbo].[Subscriptions] WHERE [Name] = 'IPS'))  
GO
 
INSERT INTO [dbo].[UserOrganizations] ([UserId],[OrganizationId])
VALUES
	((SELECT Id FROM [dbo].[Users] WHERE [UserName] = 'administrator'),
	(SELECT Id FROM [dbo].[Organizations] WHERE [Name] = 'IPS'))
GO
 
INSERT INTO [dbo].[UserRoles] ([UserId],[RoleId])
VALUES
	((SELECT Id FROM [dbo].[Users] WHERE [UserName] = 'administrator'),
	(SELECT Id FROM [dbo].[Roles] WHERE [Name] = 'IPS Admin'))
GO
