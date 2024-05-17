
SELECT 
coalesce(Referenced_server_name+'.','')+ --possible server name if cross-server
coalesce(referenced_database_name+'.','')+ --possible database name if cross-database
coalesce(referenced_schema_name+'.','')+ --likely schema name
coalesce(referenced_entity_name,'') + --very likely entity name
coalesce('.'+col_name(referenced_ID,referenced_minor_id),'')AS [referencing],
coalesce(object_schema_name(Referencing_ID)+'.','')+ --likely schema name
object_name(Referencing_ID)+ --definite entity name
coalesce('.'+col_name(referencing_ID,referencing_minor_id),'') AS [referenced]
FROM sys.sql_expression_dependencies
WHERE referenced_id =object_id('ENTITY_TYPE')
ORDER BY [referenced];

/*Query to SQL lists all object dependencies across all databases and servers */
IF(OBJECT_ID('tempdb..#Obj_Dep_Details') IS NOT NULL)
BEGIN
    DROP TABLE #Obj_Dep_Details
END
CREATE TABLE #Obj_Dep_Details
(
   [Database]               nvarchar(128)
  ,[Schema]                 nvarchar(128)
  ,dependent_object         nvarchar(128)
  ,dependent_object_type    nvarchar(60)
  ,referenced_server_name   nvarchar(128)
  ,referenced_database_name nvarchar(128)
  ,referenced_schema_name   nvarchar(128)
  ,referenced_entity_name   nvarchar(128)
  ,referenced_id            int
  ,referenced_object_db     nvarchar(128)
  ,referenced_object_type   nvarchar(60)
  ,referencing_id           int
  ,SchemaDep                nvarchar(128)
)
EXEC sp_MSForEachDB @command1='USE [?];
INSERT INTO #Obj_Dep_Details
SELECT DISTINCT
       DB_NAME()                          AS [Database]
      ,SCHEMA_NAME(od.[schema_id])        AS [Schema]
      ,OBJECT_NAME(d1.referencing_id)     AS dependent_object
      ,od.[type_desc]                     AS dependent_object_type
      ,COALESCE(d1.referenced_server_name, @@SERVERNAME)                AS referenced_server_name
      ,COALESCE(d1.referenced_database_name, DB_NAME())                 AS referenced_database_name
      ,COALESCE(d1.referenced_schema_name, SCHEMA_NAME(ro.[schema_id])) AS referenced_schema_name
      ,d1.referenced_entity_name
      ,d1.referenced_id
      ,DB_NAME(ro.parent_object_id)        AS referenced_object_db
      ,ro.[type_desc]                      AS referenced_object_type
      ,d1.referencing_id
      ,SCHEMA_NAME(od.[schema_id])         AS SchemaDep
  FROM sys.sql_expression_dependencies d1
  LEFT OUTER JOIN sys.all_objects od
    ON d1.referencing_id = od.[object_id]
  LEFT OUTER JOIN sys.objects ro
    ON d1.referenced_id = ro.[object_id]'

SELECT [Database]                                       AS [Dep_Object_DB]
      ,[Schema]                                         AS [Dep_Object_Schema]
      ,dependent_object                                 AS [Dep_Object_Name]
      ,LOWER(REPLACE(dependent_object_type, '_', ' '))  AS [Dep_Object_Type]
      ,referenced_server_name                           AS [Ref_Object_Server_Name]
      ,referenced_database_name                         AS [Ref_Object_DB]
      ,referenced_schema_name                           AS [Ref_Object_Schema]
      ,referenced_entity_name                           AS [Ref_Object_Name]
      ,referenced_id                                    AS [Ref_Object_ID]
      ,LOWER(REPLACE(referenced_object_type, '_', ' ')) AS [Ref_Object_Type]
      ,referencing_id                                   AS [Dep_Object_ID]
  FROM #Obj_Dep_Details WITH(NOLOCK)
 WHERE referenced_entity_name = 'ENTITY_TYPE' and 
ORDER BY [Dep_Object_DB]
        ,[Dep_Object_Name]
        ,[Ref_Object_Name]
        ,[Ref_Object_DB]

