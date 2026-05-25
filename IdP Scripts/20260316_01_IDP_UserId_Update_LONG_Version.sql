-- ============================================================
-- IDP SAdmin Setup Verification Script
-- Checks the 'administrator' user setup for the 'IPS' tenant
-- Returns: OK if all checks pass, otherwise lists each failure
-- ============================================================
 
DECLARE @errors   NVARCHAR(MAX) = N'';
DECLARE @adminId          NVARCHAR(50);
DECLARE @ipsOrgId         NVARCHAR(50);
DECLARE @ipsSubId         NVARCHAR(50);
DECLARE @ipsAdminRoleId   NVARCHAR(50);
DECLARE @sadminClientDbId INT;
 
-- ============================================================
-- 1. AspNetUsers: 'administrator' exists?
-- ============================================================
SELECT @adminId = Id
FROM   [dbo].[AspNetUsers]
WHERE  UserName = 'administrator';
 
IF @adminId IS NULL
    SET @errors = @errors + CHAR(10) + '  [FAIL] ''administrator'' not found in AspNetUsers';
 
-- ============================================================
-- 2. Users: same Id exists in Users table?
-- ============================================================
IF @adminId IS NOT NULL
    AND NOT EXISTS (
        SELECT 1 FROM [dbo].[Users]
        WHERE  Id = @adminId AND UserName = 'administrator'
    )
    SET @errors = @errors + CHAR(10) + '  [FAIL] ''administrator'' not found in Users with matching Id (' + ISNULL(@adminId, 'NULL') + ')';
 
-- ============================================================
-- 3. IPS Organization exists?
-- ============================================================
SELECT @ipsOrgId = Id
FROM   [dbo].[Organizations]
WHERE  Name = 'IPS';
 
IF @ipsOrgId IS NULL
    SET @errors = @errors + CHAR(10) + '  [FAIL] Organization ''IPS'' not found in Organizations';
 
-- ============================================================
-- 4. IPS Subscription exists?
-- ============================================================
SELECT @ipsSubId = Id
FROM   [dbo].[Subscriptions]
WHERE  Name = 'IPS';
 
IF @ipsSubId IS NULL
    SET @errors = @errors + CHAR(10) + '  [FAIL] Subscription ''IPS'' not found in Subscriptions';
 
-- ============================================================
-- 5. IPS Admin Role: exists for IPS tenant and assigned to user?
-- ============================================================
IF @ipsOrgId IS NOT NULL
BEGIN
    SELECT @ipsAdminRoleId = Id
    FROM   [dbo].[Roles]
    WHERE  Name = 'IPS Admin' AND TenantId = @ipsOrgId;
 
    IF @ipsAdminRoleId IS NULL
        SET @errors = @errors + CHAR(10) + '  [FAIL] Role ''IPS Admin'' not found for ''IPS'' organization';
    ELSE IF @adminId IS NOT NULL
        AND NOT EXISTS (
            SELECT 1 FROM [dbo].[UserRoles]
            WHERE  UserId = @adminId AND RoleId = @ipsAdminRoleId
        )
        SET @errors = @errors + CHAR(10) + '  [FAIL] ''administrator'' is not assigned the ''IPS Admin'' role';
END
 
-- ============================================================
-- 6. User in IPS Subscription?
-- ============================================================
IF @adminId IS NOT NULL AND @ipsSubId IS NOT NULL
    AND NOT EXISTS (
        SELECT 1 FROM [dbo].[UserSubscriptions]
        WHERE  UserId = @adminId AND SubscriptionId = @ipsSubId
    )
    SET @errors = @errors + CHAR(10) + '  [FAIL] ''administrator'' is not in ''IPS'' subscription';
 
-- ============================================================
-- 7. User in IPS Organization?
-- ============================================================
IF @adminId IS NOT NULL AND @ipsOrgId IS NOT NULL
    AND NOT EXISTS (
        SELECT 1 FROM [dbo].[UserOrganizations]
        WHERE  UserId = @adminId AND OrganizationId = @ipsOrgId
    )
    SET @errors = @errors + CHAR(10) + '  [FAIL] ''administrator'' is not in ''IPS'' organization';
 
-- ============================================================
-- 8. ApiScope 'authsrvapi' exists?
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[ApiScopes] WHERE Name = 'authsrvapi')
    SET @errors = @errors + CHAR(10) + '  [FAIL] ApiScope ''authsrvapi'' not found in ApiScopes';
-- ============================================================
-- 8.1 ApiResource 'authsrvapi' exists?
-- ============================================================
 IF NOT EXISTS (SELECT 1 FROM [dbo].[ApiResources] WHERE Name = 'authsrvapi')
    SET @errors = @errors + CHAR(10) + '  [FAIL] ApiResource ''authsrvapi'' not found in ApiResource';
 
-- ============================================================
-- 9. IdentityResources: openid, profile, role exist?
--    (These are identity scopes, not API scopes)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM [dbo].[IdentityResources] WHERE Name = 'openid')
    SET @errors = @errors + CHAR(10) + '  [FAIL] IdentityResource ''openid'' not found in IdentityResources';
 
IF NOT EXISTS (SELECT 1 FROM [dbo].[IdentityResources] WHERE Name = 'profile')
    SET @errors = @errors + CHAR(10) + '  [FAIL] IdentityResource ''profile'' not found in IdentityResources';
 
IF NOT EXISTS (SELECT 1 FROM [dbo].[IdentityResources] WHERE Name = 'role')
    SET @errors = @errors + CHAR(10) + '  [FAIL] IdentityResource ''role'' not found in IdentityResources';
 
-- ============================================================
-- 10. Client 'sadmin' exists?
-- ============================================================
SELECT @sadminClientDbId = Id
FROM   [dbo].[Clients]
WHERE  ClientId = 'sadmin';
 
IF @sadminClientDbId IS NULL
BEGIN
    SET @errors = @errors + CHAR(10) + '  [FAIL] Client ''sadmin'' not found in Clients';
END
ELSE
BEGIN
    -- --------------------------------------------------------
    -- 11. ClientScopes for 'sadmin': authsrvapi, openid, profile, role?
    -- --------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM [dbo].[ClientScopes] WHERE ClientId = @sadminClientDbId AND Scope = 'authsrvapi')
        SET @errors = @errors + CHAR(10) + '  [FAIL] Scope ''authsrvapi'' not found in ClientScopes for ''sadmin''';
 
    IF NOT EXISTS (SELECT 1 FROM [dbo].[ClientScopes] WHERE ClientId = @sadminClientDbId AND Scope = 'openid')
        SET @errors = @errors + CHAR(10) + '  [FAIL] Scope ''openid'' not found in ClientScopes for ''sadmin''';
 
    IF NOT EXISTS (SELECT 1 FROM [dbo].[ClientScopes] WHERE ClientId = @sadminClientDbId AND Scope = 'profile')
        SET @errors = @errors + CHAR(10) + '  [FAIL] Scope ''profile'' not found in ClientScopes for ''sadmin''';
 
    IF NOT EXISTS (SELECT 1 FROM [dbo].[ClientScopes] WHERE ClientId = @sadminClientDbId AND Scope = 'role')
        SET @errors = @errors + CHAR(10) + '  [FAIL] Scope ''role'' not found in ClientScopes for ''sadmin''';
 
    -- --------------------------------------------------------
    -- 12. ClientGrantTypes for 'sadmin': authorization_code, client_credentials?
    -- --------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM [dbo].[ClientGrantTypes] WHERE ClientId = @sadminClientDbId AND GrantType = 'authorization_code')
        SET @errors = @errors + CHAR(10) + '  [FAIL] GrantType ''authorization_code'' not found in ClientGrantTypes for ''sadmin''';
 
    IF NOT EXISTS (SELECT 1 FROM [dbo].[ClientGrantTypes] WHERE ClientId = @sadminClientDbId AND GrantType = 'client_credentials')
        SET @errors = @errors + CHAR(10) + '  [FAIL] GrantType ''client_credentials'' not found in ClientGrantTypes for ''sadmin''';
END
 
-- ============================================================
-- Final Result
-- ============================================================
SELECT CASE WHEN @errors = N''
    THEN N'OK - All checks passed.'
    ELSE N'ISSUES FOUND:' + @errors
END AS [Result];