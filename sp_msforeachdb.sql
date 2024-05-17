EXEC sp_msforeachdb 
    'IF EXISTS
    (
        SELECT  1 
        FROM    [?].sys.objects 
        WHERE   name LIKE ''VW_ENTITY_EntityTitles''
    )
    SELECT 
        ''?''       AS DB, 
        name        AS Name, 
        type_desc   AS Type 
    FROM [?].sys.objects 
    WHERE name LIKE ''VW_ENTITY_EntityTitles'''