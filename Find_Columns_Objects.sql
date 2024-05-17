--Change column names in WHERE condition
SELECT DISTINCT QUOTENAME(schema_name(O.schema_id)) + '.' + QUOTENAME(O.[Name]) AS [SchemaTable_Name], C.[Name] AS [Column_Name], type_desc AS [Object_Type]
FROM sys.all_columns C
LEFT OUTER JOIN sys.all_objects O ON C.object_id = O.object_id
WHERE C.[Name] IN	(
      'ColumnName1', 
      'ColumnName2'
      )
ORDER BY [Object_Type], [SchemaTable_Name], [Column_Name];


--Change column names in WHERE condition 
SELECT DISTINCT QUOTENAME(schema_name(O.schema_id)) + '.' + QUOTENAME(O.[Name]) AS [SchemaTable_Name], C.[Name] AS [Column_Name], type_desc AS [Object_Type]
FROM sys.all_columns C
LEFT OUTER JOIN sys.all_objects O ON C.object_id = O.object_id
WHERE C.[Name] LIKE '%Name1%' OR C.[Name] LIKE '%Name2%'
ORDER BY [Object_Type], [SchemaTable_Name], [Column_Name];
