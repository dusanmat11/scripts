/******    AspNet  User  *********/
SELECT * 
FROM
	[dbo].[AspNetUsers]
WHERE
	UserName = 'Administrator'

/******     Users *********/
SELECT *
FROM
	[dbo].[Users]
WHERE
	UserName = 'Administrator'

/******     User Roles   *********/
SELECT *
FROM
	[dbo].[UserRoles]
WHERE
	UserId IN 
		(SELECT Id FROM [dbo].[Users] WHERE UserName = 'Administrator') AND 
	RoleId in 
		(SELECT Id FROM [dbo].[Roles] WHERE [Name] = 'IPS Admin')

/******     User Subscription   *********/
SELECT *
FROM
	[dbo].[UserSubscriptions]
WHERE
	UserId IN (SELECT Id FROM [dbo].[Users] WHERE UserName = 'Administrator')

/******     User Organizations *********/
SELECT *
FROM
	[dbo].[UserOrganizations]
WHERE
	UserId IN (SELECT Id FROM [dbo].[Users] WHERE UserName = 'Administrator')

/******     Api Scopes *********/
SELECT *
FROM
	[dbo].[ApiScopes]
WHERE
	Name = 'authsrvapi'

/******     Client Scopes *********/
SELECT *
FROM
	[dbo].[ClientScopes]
WHERE
	[Scope] = 'authsrvapi'


/******     Client Grant Types - result whould be 2 records ********************/
--------1	authorization_code
--------1	client_credentials
/*********************************************************************************/
SELECT * 
FROM
	[dbo].[ClientGrantTypes]
WHERE	
	[ClientId] = 1 
