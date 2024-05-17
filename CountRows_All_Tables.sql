--Getting a Count of rows from all Tables that exist in a database
SET NOCOUNT ON;
GO

SELECT 
CONCAT(
STRING_AGG(
CAST(
'SELECT '''+ QUOTENAME(S.NAME) + '.'+ QUOTENAME(O.NAME) + ''' AS TableName, COUNT(*) AS [Row_Count] FROM '+ QUOTENAME(S.NAME) + '.'+QUOTENAME(O.NAME)
 AS VARCHAR(MAX))+ CHAR(13) + CHAR(10)
, ' UNION ALL '+ CHAR(13) + CHAR(10)
),
'ORDER BY [TableName]') AS Query
FROM SYS.ALL_OBJECTS O
LEFT OUTER JOIN SYS.SCHEMAS S ON O.SCHEMA_ID = S.SCHEMA_ID
WHERE [TYPE]= 'U';