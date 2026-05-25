USE [IpsIdentityProvider]
GO

DECLARE @client NVARCHAR(200)
SET @client = 'sadmin'

DECLARE @url NVARCHAR(2000)
SET @url = 'https://localhost:5444' /* Update @url with IPS Seucirty Admin URL in your environment. */

UPDATE [dbo].[Clients]
   SET [BackChannelLogoutUri] = @url + '/logout'
   WHERE [ClientId] = @client

UPDATE [dbo].[ClientRedirectUris]
   SET [RedirectUri] = @url + '/signin-oidc'
   WHERE [ClientId] = (SELECT Id FROM [dbo].[Clients] WHERE [ClientId] = @client)

UPDATE [dbo].[ClientPostLogoutRedirectUris]
   SET [PostLogoutRedirectUri] = @url + '/signout-callback-oidc'
   WHERE [ClientId] = (SELECT Id FROM [dbo].[Clients] WHERE [ClientId] = @client)
GO

SELECT Id, ClientId, BackChannelLogoutUri FROM Clients
SELECT * FROM ClientRedirectUris
SELECT * FROM ClientPostLogoutRedirectUris