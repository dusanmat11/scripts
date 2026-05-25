IF NOT EXISTS (SELECT * FROM [dbo].[ApiScopes] WHERE [Name]='authsrvapi')
BEGIN
	INSERT INTO [dbo].[ApiScopes]
		(
		 [Description]
		,[DisplayName]
		,[Emphasize]
		,[Name]
		,[Required]
		,[ShowInDiscoveryDocument]
		,[Enabled]
		,[Created]
		,[LastAccessed]
		,[NonEditable]
		,[Updated]
		)
	SELECT
		'Exclusive authsrvapi API Resource Scope',
		'IPS Authorization Server Scope	False',
		0,
		'authsrvapi',
		'False',
		'True',
		'True',
		'2026-03-12 03:14:17.5187777',
		NULL,	
		'False',
		NULL
END
ELSE
PRINT 'ApiScope EXISTS!!!!!'

IF NOT EXISTS (SELECT * FROM [dbo].[ClientScopes] WHERE [Scope]='authsrvapi')
BEGIN
	INSERT INTO [dbo].[ClientScopes]
		(
		 [ClientId]
		,[Scope]
		)
	SELECT
		1,	
		'authsrvapi'
END
ELSE
PRINT 'ClientScope EXISTS!!!!!'

IF NOT EXISTS (SELECT * FROM [dbo].[ClientGrantTypes] WHERE [ClientId] = 1 AND  [GrantType]='client_credentials')
BEGIN
	INSERT INTO [dbo].[ClientGrantTypes]
		(
		 [ClientId]
		,[GrantType]
		)
	SELECT
		1,
		'client_credentials'
END
ELSE
PRINT 'ClientGrantType EXISTS!!!!!'

IF NOT EXISTS (SELECT * FROM[dbo].[ApiResources] WHERE [Name]='authsrvapi')
  BEGIN
     INSERT [dbo].[ApiResources] 
       (
       [Description], 
       [DisplayName], 
       [Enabled], 
       [Name], 
       [Created], 
       [LastAccessed], 
       [NonEditable], 
       [Updated], 
       [AllowedAccessTokenSigningAlgorithms], 
       [ShowInDiscoveryDocument], 
       [RequireResourceIndicator]
       ) 
     SELECT  
       'IPS Authorization Server API', 
       'IPS Authorization Server API', 
       1, 
       'authsrvapi', 
       CAST(GETDATE() AS DateTime2), 
       NULL, 
       0, 
       NULL, 
       NULL, 
       0, 
       0
       END
	ELSE
	PRINT 'ApiResource EXISTS!!!'