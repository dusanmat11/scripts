DECLARE 
	-- Change source and destintion database names based on your needs !!!
	@SourceDatabase NVARCHAR(255 )= 'IpsIdentityProvider',
	@DestinationDatabase NVARCHAR(255) = 'IpsIdentityProvider_v8',

	@SetDatabase NVARCHAR(MAX),
	@DeleteUsers NVARCHAR(MAX),
	@CopyUsers NVARCHAR(MAX),
	@DeleteUserLogins NVARCHAR(MAX),
	@CopyUserLogins NVARCHAR(MAX),
	@DeleteUserTokens NVARCHAR(MAX),
	@CopyUserTokens NVARCHAR(MAX),
	@DeleteClaimTypes NVARCHAR(MAX),
	@CopyClaimTypes NVARCHAR(MAX),		
	@DeleteUserClaims NVARCHAR(MAX),
	@CopyUserClaims NVARCHAR(MAX),	
	@DeleteRoles NVARCHAR(MAX),
	@CopyRoles NVARCHAR(MAX),
	@DeleteRoleClaims NVARCHAR(MAX),
	@CopyRoleClaims NVARCHAR(MAX),
	@DeleteUserRoles NVARCHAR(MAX),
	@CopyUserRoles NVARCHAR(MAX);

SET @SetDatabase = N'USE ' + QUOTENAME(@DestinationDatabase);
EXEC sp_executesql @SetDatabase;

/* ************************************    Users    ************************************ */
SET @DeleteUsers = 'DELETE FROM ' + QUOTENAME(@DestinationDatabase) + '.[dbo].[AspNetUsers]';
EXEC sp_executesql @DeleteUsers;

SET @CopyUsers = 'INSERT INTO ' + QUOTENAME(@DestinationDatabase) + '.[dbo].[AspNetUsers]
		([Id],[AccessFailedCount],[ConcurrencyStamp],[Email],[EmailConfirmed],[LockoutEnabled],[LockoutEnd],[NormalizedEmail],[NormalizedUserName],[PasswordHash],[PhoneNumber],[PhoneNumberConfirmed],[SecurityStamp],[TwoFactorEnabled],[UserName])
	SELECT 
		[Id],[AccessFailedCount],[ConcurrencyStamp],[Email],[EmailConfirmed],[LockoutEnabled],[LockoutEnd],[NormalizedEmail],[NormalizedUserName],[PasswordHash],[PhoneNumber],[PhoneNumberConfirmed],[SecurityStamp],[TwoFactorEnabled],[UserName]
	FROM 
		' + QUOTENAME(@SourceDatabase) + '.[dbo].[AspNetUsers]';
		
EXEC sp_executesql @CopyUsers;
/* ************************************************************************************* */

/* ************************************ User Logins ************************************ */
SET @DeleteUserLogins = 'DELETE FROM ' + QUOTENAME(@DestinationDatabase) + '.[dbo].[AspNetUserLogins]';
EXEC sp_executesql @DeleteUserLogins;

SET @CopyUserLogins = 'INSERT INTO ' + QUOTENAME(@DestinationDatabase) + '.[dbo].[AspNetUserLogins]
        ([LoginProvider],[ProviderKey],[ProviderDisplayName],[UserId])
    SELECT
        [LoginProvider],[ProviderKey],[ProviderDisplayName],[UserId]
	FROM 
		' + QUOTENAME(@SourceDatabase) + '.[dbo].[AspNetUserLogins]';

EXEC sp_executesql @CopyUserLogins;
/* ************************************************************************************* */

/* ************************************ User Tokens ************************************ */
SET @DeleteUserTokens = 'DELETE FROM ' + QUOTENAME(@DestinationDatabase) + '.[dbo].[AspNetUserTokens]';
EXEC sp_executesql @DeleteUserTokens;

SET @CopyUserTokens = 'INSERT INTO' + QUOTENAME(@DestinationDatabase) + '.[dbo].[AspNetUserTokens]
		([UserId],[LoginProvider],[Name],[Value])
	SELECT
		[UserId],[LoginProvider],[Name],[Value]
	FROM
		' + QUOTENAME(@SourceDatabase) + '.[dbo].[AspNetUserTokens]'

EXEC sp_executesql @CopyUserTokens;
/* ************************************************************************************* */

/* ************************************ Claim Types ************************************ */
SET @DeleteClaimTypes = 'DELETE FROM ' + QUOTENAME(@DestinationDatabase) + '.[dbo].[AspNetClaimTypes]';
EXEC sp_executesql @DeleteClaimTypes;

SET @CopyClaimTypes = 'INSERT INTO ' + QUOTENAME(@DestinationDatabase) + '.[dbo].[AspNetClaimTypes]
		([Id],[ConcurrencyStamp],[Description],[Name],[NormalizedName],[Required],[Reserved],[Rule],[ValueType])
	SELECT
		[Id],[ConcurrencyStamp],[Description],[Name],[NormalizedName],[Required],[Reserved],[Rule],[ValueType]
	FROM 
		' + QUOTENAME(@SourceDatabase) + '.[dbo].[AspNetClaimTypes]';

EXEC sp_executesql @CopyClaimTypes;
/* ************************************************************************************* */

/* ************************************ User Claims ************************************ */
SET @DeleteUserClaims = 'DELETE FROM ' + QUOTENAME(@DestinationDatabase) + '.[dbo].[AspNetUserClaims]';
EXEC sp_executesql @DeleteUserClaims;

SET @CopyUserClaims = 'INSERT INTO ' + QUOTENAME(@DestinationDatabase) + '.[dbo].[AspNetUserClaims]
		([ClaimType],[ClaimValue],[UserId])
	SELECT
		[ClaimType],[ClaimValue],[UserId]
	FROM 
		' + QUOTENAME(@SourceDatabase) + '.[dbo].[AspNetUserClaims]';

EXEC sp_executesql @CopyUserClaims;
/* ************************************************************************************* */

/* ************************************    Roles    ************************************ */
SET @DeleteRoles = 'DELETE FROM ' + QUOTENAME(@DestinationDatabase) + '.[dbo].[AspNetRoles]';
EXEC sp_executesql @DeleteRoles;

SET @CopyRoles = 'INSERT INTO ' + QUOTENAME(@DestinationDatabase) + '.[dbo].[AspNetRoles]
		([Id],[ConcurrencyStamp],[Name],[NormalizedName],[Description])
	SELECT
		[Id],[ConcurrencyStamp],[Name],[NormalizedName],[Description]
	FROM 
		' + QUOTENAME(@SourceDatabase) + '.[dbo].[AspNetRoles]'

EXEC sp_executesql @CopyRoles;
/* ************************************************************************************* */

/* ************************************ Role Claims ************************************ */
SET @DeleteRoleClaims = 'DELETE FROM ' + QUOTENAME(@DestinationDatabase) + '.[dbo].[AspNetRoleClaims]';
EXEC sp_executesql @DeleteRoleClaims;

SET @CopyRoleClaims = 'INSERT INTO ' + QUOTENAME(@DestinationDatabase) + '.[dbo].[AspNetRoleClaims]
		([ClaimType],[ClaimValue],[RoleId])
	SELECT
		[ClaimType],[ClaimValue],[RoleId]
	FROM
		' + QUOTENAME(@SourceDatabase) + '.[dbo].[AspNetRoleClaims]'

EXEC sp_executesql @CopyRoleClaims;
/* ************************************************************************************* */

/* ************************************ User Roles  ************************************ */
SET @DeleteUserRoles = 'DELETE FROM ' + QUOTENAME(@DestinationDatabase) + '.[dbo].[AspNetUserRoles]';
EXEC sp_executesql @DeleteUserRoles;

SET @CopyUserRoles = 'INSERT INTO ' + QUOTENAME(@DestinationDatabase) + '.[dbo].[AspNetUserRoles]
		([UserId],[RoleId])
	SELECT
		[UserId],[RoleId]
	FROM 
		' + QUOTENAME(@SourceDatabase) + '.[dbo].[AspNetUserRoles]';

EXEC sp_executesql @CopyUserRoles;
/* ************************************************************************************* */