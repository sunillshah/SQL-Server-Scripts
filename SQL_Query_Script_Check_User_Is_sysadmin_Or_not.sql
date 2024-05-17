SELECT IS_SRVROLEMEMBER('sysadmin');

SELECT sp.name AS username,
       IS_SRVROLEMEMBER('sysadmin') AS is_server_admin,
       CASE WHEN db_principal.name IS NOT NULL THEN 1 ELSE 0 END AS is_db_admin
FROM sys.server_principals sp
LEFT JOIN sys.database_principals db_principal
  ON sp.sid = db_principal.sid
WHERE sp.name = SUSER_NAME();

SELECT 
    dp.name AS username,
    roles.name AS role_name,
    CASE 
        WHEN perm.class = 4 THEN perm.permission_name 
        WHEN perm.class = 1 THEN 'GRANT'
    END AS permission_type,
    CASE 
        WHEN perm.class = 4 THEN perm.state_desc COLLATE SQL_Latin1_General_CP1_CI_AS
        WHEN perm.class = 1 THEN grantee.name COLLATE SQL_Latin1_General_CP1_CI_AS
    END AS permission_detail
FROM 
    sys.database_principals dp
LEFT JOIN 
    sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
LEFT JOIN 
    sys.database_principals roles ON drm.role_principal_id = roles.principal_id
LEFT JOIN 
    sys.database_permissions perm ON roles.principal_id = perm.grantee_principal_id
LEFT JOIN 
    sys.database_principals grantee ON perm.grantee_principal_id = grantee.principal_id
WHERE 
    dp.type IN ('S', 'U') -- Filter for Logins ('S') and Users ('U')
ORDER BY 
    dp.name, role_name, permission_type;

