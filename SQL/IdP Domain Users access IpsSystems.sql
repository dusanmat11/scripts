INSERT INTO AspNetUserLogins 
(LoginProvider, 
ProviderDisplayName, 
ProviderKey, 
UserID)
SELECT 
    'Windows' AS LoginProvider,
    'Windows' AS ProviderDisplayName,
    u.NormalizedUserName AS ProviderKey,
    u.Id AS UserID
FROM aspnetUsers u
WHERE NOT EXISTS (SELECT 1 FROM AspNetUserLogins a WHERE 	a.[LoginProvider] = 'Windows' AND a.[ProviderKey] = u.NormalizedUserName)