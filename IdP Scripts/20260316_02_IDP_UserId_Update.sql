DECLARE @AspNetUserId NVARCHAR(50), @UserID NVARCHAR(50)

SELECT @AspNetUserId = Id FROM AspNetUsers WHERE UserName = 'Administrator' 

SELECT @UserID = Id FROM Users WHERE UserName = 'Administrator'

/************************************************************************************/


ALTER TABLE [dbo].[UserSubscriptions] DROP CONSTRAINT [FK_UserSubscription_User]

ALTER TABLE [dbo].[UserOrganizations] DROP CONSTRAINT [FK_UserOrganization_User]

ALTER TABLE [dbo].[UserRoles] DROP CONSTRAINT [FK_UserRole_User]

/************************************************************************************/


--SELECT *
UPDATE uo SET uo.UserId = @AspNetUserId
FROM
	[dbo].[UserOrganizations] uo WHERE uo.UserId = @UserID 


--SELECT *
UPDATE us SET us.UserId = @AspNetUserId
FROM 
	[dbo].[UserSubscriptions] us WHERE us.UserId = @UserID 

--SELECT *
UPDATE r SET r.UserId = @AspNetUserId
FROM [dbo].[UserRoles] r WHERE r.UserId = @UserID


--SELECT *
UPDATE u SET u.Id = @AspNetUserId
FROM [dbo].[Users] u WHERE u.Id = @UserID


/************************************************************************************/


ALTER TABLE [dbo].[UserSubscriptions]  WITH CHECK ADD  CONSTRAINT [FK_UserSubscription_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
ON DELETE CASCADE

ALTER TABLE [dbo].[UserSubscriptions] CHECK CONSTRAINT [FK_UserSubscription_User]



ALTER TABLE [dbo].[UserOrganizations]  WITH CHECK ADD  CONSTRAINT [FK_UserOrganization_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
ON DELETE CASCADE

ALTER TABLE [dbo].[UserOrganizations] CHECK CONSTRAINT [FK_UserOrganization_User]



ALTER TABLE [dbo].[UserRoles]  WITH CHECK ADD  CONSTRAINT [FK_UserRole_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
ON DELETE CASCADE

ALTER TABLE [dbo].[UserRoles] CHECK CONSTRAINT [FK_UserRole_User]
/************************************************************************************/