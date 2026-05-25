

-- we run script on destination database !!!
USE [targetDatabase]
GO

-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[ApiResourceClaims] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[ApiResourceProperties] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[ApiResources] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[ApiResourceScopes] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[ApiResourceSecrets] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[ApiScopeClaims] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[ApiScopeProperties] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[ApiScopes] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[AspNetClaimTypes] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[AspNetRoleClaims] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[AspNetRoles] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[AspNetUserClaims] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[AspNetUserLogins] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[AspNetUserRoles] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[AspNetUsers] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[AspNetUserTokens] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[ClientClaims] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[ClientCorsOrigins] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[ClientGrantTypes] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[ClientIdPRestrictions] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[ClientPostLogoutRedirectUris] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[ClientProperties] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[ClientRedirectUris] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[Clients] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[ClientScopes] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[ClientSecrets] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[DeviceCodes] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[IdentityResourceClaims] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[IdentityResourceProperties] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[IdentityResources] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[PersistedGrants] NOCHECK CONSTRAINT ALL;-- disable constraint
ALTER TABLE [targetDatabase].[dbo].[Settings] NOCHECK CONSTRAINT ALL;
GO 
-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[ApiResourceClaims];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[ApiResourceProperties];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[ApiResources];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[ApiResourceScopes];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[ApiResourceSecrets];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[ApiScopeClaims];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[ApiScopeProperties];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[ApiScopes];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[AspNetClaimTypes];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[AspNetRoleClaims];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[AspNetRoles];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[AspNetUserClaims];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[AspNetUserLogins];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[AspNetUserRoles];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[AspNetUsers];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[AspNetUserTokens];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[ClientClaims];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[ClientCorsOrigins];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[ClientGrantTypes];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[ClientIdPRestrictions];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[ClientPostLogoutRedirectUris];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[ClientProperties];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[ClientRedirectUris];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[Clients];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[ClientScopes];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[ClientSecrets];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[DeviceCodes];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[IdentityResourceClaims];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[IdentityResourceProperties];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[IdentityResources];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[PersistedGrants];-- delete existing data from destination 
DELETE FROM [targetDatabase].[dbo].[Settings];
GO 
-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[ApiResourceClaims] ON;
INSERT INTO [targetDatabase].[dbo].[ApiResourceClaims] ([Id], [Type], [ApiResourceId])
SELECT [Id], [Type], [ApiResourceId]
FROM [sourceDatabase].[dbo].[ApiResourceClaims]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[ApiResourceClaims] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[ApiResourceProperties] ON;
INSERT INTO [targetDatabase].[dbo].[ApiResourceProperties] ([Id], [Key], [Value], [ApiResourceId])
SELECT [Id], [Key], [Value], [ApiResourceId]
FROM [sourceDatabase].[dbo].[ApiResourceProperties]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[ApiResourceProperties] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[ApiResources] ON;
INSERT INTO [targetDatabase].[dbo].[ApiResources] ([Id], [Description], [DisplayName], [Enabled], [Name], [Created], [LastAccessed], [NonEditable], [Updated], [AllowedAccessTokenSigningAlgorithms], [ShowInDiscoveryDocument])
SELECT [Id], [Description], [DisplayName], [Enabled], [Name], [Created], [LastAccessed], [NonEditable], [Updated], [AllowedAccessTokenSigningAlgorithms], [ShowInDiscoveryDocument]
FROM [sourceDatabase].[dbo].[ApiResources]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[ApiResources] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[ApiResourceScopes] ON;
INSERT INTO [targetDatabase].[dbo].[ApiResourceScopes] ([Id], [Scope], [ApiResourceId])
SELECT [Id], [Scope], [ApiResourceId]
FROM [sourceDatabase].[dbo].[ApiResourceScopes]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[ApiResourceScopes] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[ApiResourceSecrets] ON;
INSERT INTO [targetDatabase].[dbo].[ApiResourceSecrets] ([Id], [Description], [Value], [Expiration], [Type], [Created], [ApiResourceId])
SELECT [Id], [Description], [Value], [Expiration], [Type], [Created], [ApiResourceId]
FROM [sourceDatabase].[dbo].[ApiResourceSecrets]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[ApiResourceSecrets] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[ApiScopeClaims] ON;
INSERT INTO [targetDatabase].[dbo].[ApiScopeClaims] ([Id], [ScopeId], [Type])
SELECT [Id], [ScopeId], [Type]
FROM [sourceDatabase].[dbo].[ApiScopeClaims]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[ApiScopeClaims] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[ApiScopeProperties] ON;
INSERT INTO [targetDatabase].[dbo].[ApiScopeProperties] ([Id], [Key], [Value], [ScopeId])
SELECT [Id], [Key], [Value], [ScopeId]
FROM [sourceDatabase].[dbo].[ApiScopeProperties]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[ApiScopeProperties] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[ApiScopes] ON;
INSERT INTO [targetDatabase].[dbo].[ApiScopes] ([Id], [Description], [DisplayName], [Emphasize], [Name], [Required], [ShowInDiscoveryDocument], [Enabled])
SELECT [Id], [Description], [DisplayName], [Emphasize], [Name], [Required], [ShowInDiscoveryDocument], [Enabled]
FROM [sourceDatabase].[dbo].[ApiScopes]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[ApiScopes] OFF;

-- Insert into destination database from source database

INSERT INTO [targetDatabase].[dbo].[AspNetClaimTypes] ([Id], [ConcurrencyStamp], [Description], [Name], [NormalizedName], [Required], [Reserved], [Rule], [ValueType])
SELECT [Id], [ConcurrencyStamp], [Description], [Name], [NormalizedName], [Required], [Reserved], [Rule], [ValueType]
FROM [sourceDatabase].[dbo].[AspNetClaimTypes]; 


-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[AspNetRoleClaims] ON;
INSERT INTO [targetDatabase].[dbo].[AspNetRoleClaims] ([Id], [ClaimType], [ClaimValue], [RoleId])
SELECT [Id], [ClaimType], [ClaimValue], [RoleId]
FROM [sourceDatabase].[dbo].[AspNetRoleClaims]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[AspNetRoleClaims] OFF;

-- Insert into destination database from source database

INSERT INTO [targetDatabase].[dbo].[AspNetRoles] ([Id], [ConcurrencyStamp], [Name], [NormalizedName], [Description])
SELECT [Id], [ConcurrencyStamp], [Name], [NormalizedName], [Description]
FROM [sourceDatabase].[dbo].[AspNetRoles]; 


-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[AspNetUserClaims] ON;
INSERT INTO [targetDatabase].[dbo].[AspNetUserClaims] ([Id], [ClaimType], [ClaimValue], [UserId])
SELECT [Id], [ClaimType], [ClaimValue], [UserId]
FROM [sourceDatabase].[dbo].[AspNetUserClaims]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[AspNetUserClaims] OFF;

-- Insert into destination database from source database

INSERT INTO [targetDatabase].[dbo].[AspNetUserLogins] ([LoginProvider], [ProviderKey], [ProviderDisplayName], [UserId])
SELECT [LoginProvider], [ProviderKey], [ProviderDisplayName], [UserId]
FROM [sourceDatabase].[dbo].[AspNetUserLogins]; 


-- Insert into destination database from source database

INSERT INTO [targetDatabase].[dbo].[AspNetUserRoles] ([UserId], [RoleId])
SELECT [UserId], [RoleId]
FROM [sourceDatabase].[dbo].[AspNetUserRoles]; 


-- Insert into destination database from source database

INSERT INTO [targetDatabase].[dbo].[AspNetUsers] ([Id], [AccessFailedCount], [ConcurrencyStamp], [Email], [EmailConfirmed], [LockoutEnabled], [LockoutEnd], [NormalizedEmail], [NormalizedUserName], [PasswordHash], [PhoneNumber], [PhoneNumberConfirmed], [SecurityStamp], [TwoFactorEnabled], [UserName])
SELECT [Id], [AccessFailedCount], [ConcurrencyStamp], [Email], [EmailConfirmed], [LockoutEnabled], [LockoutEnd], [NormalizedEmail], [NormalizedUserName], [PasswordHash], [PhoneNumber], [PhoneNumberConfirmed], [SecurityStamp], [TwoFactorEnabled], [UserName]
FROM [sourceDatabase].[dbo].[AspNetUsers]; 


-- Insert into destination database from source database

INSERT INTO [targetDatabase].[dbo].[AspNetUserTokens] ([UserId], [LoginProvider], [Name], [Value])
SELECT [UserId], [LoginProvider], [Name], [Value]
FROM [sourceDatabase].[dbo].[AspNetUserTokens]; 


-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientClaims] ON;
INSERT INTO [targetDatabase].[dbo].[ClientClaims] ([Id], [ClientId], [Type], [Value])
SELECT [Id], [ClientId], [Type], [Value]
FROM [sourceDatabase].[dbo].[ClientClaims]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientClaims] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientCorsOrigins] ON;
INSERT INTO [targetDatabase].[dbo].[ClientCorsOrigins] ([Id], [ClientId], [Origin])
SELECT [Id], [ClientId], [Origin]
FROM [sourceDatabase].[dbo].[ClientCorsOrigins]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientCorsOrigins] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientGrantTypes] ON;
INSERT INTO [targetDatabase].[dbo].[ClientGrantTypes] ([Id], [ClientId], [GrantType])
SELECT [Id], [ClientId], [GrantType]
FROM [sourceDatabase].[dbo].[ClientGrantTypes]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientGrantTypes] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientIdPRestrictions] ON;
INSERT INTO [targetDatabase].[dbo].[ClientIdPRestrictions] ([Id], [ClientId], [Provider])
SELECT [Id], [ClientId], [Provider]
FROM [sourceDatabase].[dbo].[ClientIdPRestrictions]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientIdPRestrictions] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientPostLogoutRedirectUris] ON;
INSERT INTO [targetDatabase].[dbo].[ClientPostLogoutRedirectUris] ([Id], [ClientId], [PostLogoutRedirectUri])
SELECT [Id], [ClientId], [PostLogoutRedirectUri]
FROM [sourceDatabase].[dbo].[ClientPostLogoutRedirectUris]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientPostLogoutRedirectUris] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientProperties] ON;
INSERT INTO [targetDatabase].[dbo].[ClientProperties] ([Id], [ClientId], [Key], [Value])
SELECT [Id], [ClientId], [Key], [Value]
FROM [sourceDatabase].[dbo].[ClientProperties]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientProperties] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientRedirectUris] ON;
INSERT INTO [targetDatabase].[dbo].[ClientRedirectUris] ([Id], [ClientId], [RedirectUri])
SELECT [Id], [ClientId], [RedirectUri]
FROM [sourceDatabase].[dbo].[ClientRedirectUris]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientRedirectUris] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[Clients] ON;
INSERT INTO [targetDatabase].[dbo].[Clients] ([Id], [AbsoluteRefreshTokenLifetime], [AccessTokenLifetime], [AccessTokenType], [AllowAccessTokensViaBrowser], [AllowOfflineAccess], [AllowPlainTextPkce], [AllowRememberConsent], [AlwaysIncludeUserClaimsInIdToken], [AlwaysSendClientClaims], [AuthorizationCodeLifetime], [BackChannelLogoutSessionRequired], [BackChannelLogoutUri], [ClientClaimsPrefix], [ClientId], [ClientName], [ClientUri], [ConsentLifetime], [Description], [EnableLocalLogin], [Enabled], [FrontChannelLogoutSessionRequired], [FrontChannelLogoutUri], [IdentityTokenLifetime], [IncludeJwtId], [LogoUri], [PairWiseSubjectSalt], [ProtocolType], [RefreshTokenExpiration], [RefreshTokenUsage], [RequireClientSecret], [RequireConsent], [RequirePkce], [SlidingRefreshTokenLifetime], [UpdateAccessTokenClaimsOnRefresh], [Created], [DeviceCodeLifetime], [LastAccessed], [NonEditable], [Updated], [UserCodeType], [UserSsoLifetime], [AllowedIdentityTokenSigningAlgorithms], [RequireRequestObject])
SELECT [Id], [AbsoluteRefreshTokenLifetime], [AccessTokenLifetime], [AccessTokenType], [AllowAccessTokensViaBrowser], [AllowOfflineAccess], [AllowPlainTextPkce], [AllowRememberConsent], [AlwaysIncludeUserClaimsInIdToken], [AlwaysSendClientClaims], [AuthorizationCodeLifetime], [BackChannelLogoutSessionRequired], [BackChannelLogoutUri], [ClientClaimsPrefix], [ClientId], [ClientName], [ClientUri], [ConsentLifetime], [Description], [EnableLocalLogin], [Enabled], [FrontChannelLogoutSessionRequired], [FrontChannelLogoutUri], [IdentityTokenLifetime], [IncludeJwtId], [LogoUri], [PairWiseSubjectSalt], [ProtocolType], [RefreshTokenExpiration], [RefreshTokenUsage], [RequireClientSecret], [RequireConsent], [RequirePkce], [SlidingRefreshTokenLifetime], [UpdateAccessTokenClaimsOnRefresh], [Created], [DeviceCodeLifetime], [LastAccessed], [NonEditable], [Updated], [UserCodeType], [UserSsoLifetime], [AllowedIdentityTokenSigningAlgorithms], [RequireRequestObject]
FROM [sourceDatabase].[dbo].[Clients]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[Clients] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientScopes] ON;
INSERT INTO [targetDatabase].[dbo].[ClientScopes] ([Id], [ClientId], [Scope])
SELECT [Id], [ClientId], [Scope]
FROM [sourceDatabase].[dbo].[ClientScopes]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientScopes] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientSecrets] ON;
INSERT INTO [targetDatabase].[dbo].[ClientSecrets] ([Id], [ClientId], [Description], [Expiration], [Type], [Value], [Created])
SELECT [Id], [ClientId], [Description], [Expiration], [Type], [Value], [Created]
FROM [sourceDatabase].[dbo].[ClientSecrets]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[ClientSecrets] OFF;

-- Insert into destination database from source database

INSERT INTO [targetDatabase].[dbo].[DeviceCodes] ([UserCode], [DeviceCode], [SubjectId], [ClientId], [CreationTime], [Expiration], [Data], [SessionId], [Description])
SELECT [UserCode], [DeviceCode], [SubjectId], [ClientId], [CreationTime], [Expiration], [Data], [SessionId], [Description]
FROM [sourceDatabase].[dbo].[DeviceCodes]; 


-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[IdentityResourceClaims] ON;
INSERT INTO [targetDatabase].[dbo].[IdentityResourceClaims] ([Id], [Type], [IdentityResourceId])
SELECT [Id], [Type], [IdentityResourceId]
FROM [sourceDatabase].[dbo].[IdentityResourceClaims]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[IdentityResourceClaims] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[IdentityResourceProperties] ON;
INSERT INTO [targetDatabase].[dbo].[IdentityResourceProperties] ([Id], [Key], [Value], [IdentityResourceId])
SELECT [Id], [Key], [Value], [IdentityResourceId]
FROM [sourceDatabase].[dbo].[IdentityResourceProperties]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[IdentityResourceProperties] OFF;

-- Insert into destination database from source database
SET IDENTITY_INSERT [targetDatabase].[dbo].[IdentityResources] ON;
INSERT INTO [targetDatabase].[dbo].[IdentityResources] ([Id], [Description], [DisplayName], [Emphasize], [Enabled], [Name], [Required], [ShowInDiscoveryDocument], [Created], [NonEditable], [Updated])
SELECT [Id], [Description], [DisplayName], [Emphasize], [Enabled], [Name], [Required], [ShowInDiscoveryDocument], [Created], [NonEditable], [Updated]
FROM [sourceDatabase].[dbo].[IdentityResources]; 
SET IDENTITY_INSERT [targetDatabase].[dbo].[IdentityResources] OFF;

-- Insert into destination database from source database

INSERT INTO [targetDatabase].[dbo].[PersistedGrants] ([Key], [ClientId], [CreationTime], [Data], [Expiration], [SubjectId], [Type], [SessionId], [Description], [ConsumedTime])
SELECT [Key], [ClientId], [CreationTime], [Data], [Expiration], [SubjectId], [Type], [SessionId], [Description], [ConsumedTime]
FROM [sourceDatabase].[dbo].[PersistedGrants]; 


-- Insert into destination database from source database

INSERT INTO [targetDatabase].[dbo].[Settings] ([Id], [Value])
SELECT [Id], [Value]
FROM [sourceDatabase].[dbo].[Settings]; 



GO 
-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[ApiResourceClaims] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[ApiResourceProperties] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[ApiResources] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[ApiResourceScopes] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[ApiResourceSecrets] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[ApiScopeClaims] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[ApiScopeProperties] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[ApiScopes] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[AspNetClaimTypes] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[AspNetRoleClaims] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[AspNetRoles] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[AspNetUserClaims] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[AspNetUserLogins] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[AspNetUserRoles] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[AspNetUsers] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[AspNetUserTokens] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[ClientClaims] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[ClientCorsOrigins] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[ClientGrantTypes] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[ClientIdPRestrictions] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[ClientPostLogoutRedirectUris] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[ClientProperties] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[ClientRedirectUris] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[Clients] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[ClientScopes] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[ClientSecrets] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[DeviceCodes] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[IdentityResourceClaims] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[IdentityResourceProperties] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[IdentityResources] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[PersistedGrants] WITH CHECK CHECK CONSTRAINT ALL;-- enable constraints on destination
ALTER TABLE [targetDatabase].[dbo].[Settings] WITH CHECK CHECK CONSTRAINT ALL;
GO 

