SELECT
  obj.type ObjType
 ,'ObjDescription' =
  CASE obj.type
    WHEN 'AF' THEN 'Aggregate function (CLR)'
    WHEN 'C' THEN 'CHECK Constraint'
    WHEN 'D' THEN 'DEFAULT (constraint or stand-alone)'
    WHEN 'EC' THEN 'Edge Constraint'
    WHEN 'ET' THEN 'External Table'
    WHEN 'F' THEN 'FOREIGN KEY Constraint'
    WHEN 'FN' THEN 'SQL Scalar functions'
    WHEN 'FS' THEN 'Assembly (CLR) scalar-function'
    WHEN 'FT' THEN 'Assembly (CLR) table-valued function'
    WHEN 'IF' THEN 'SQL Inline Table-valued Function'
    WHEN 'IT' THEN 'Internal table'
    WHEN 'P' THEN 'SQL Stored Procedure'
    WHEN 'PC' THEN 'Assembly (CLR) stored-procedure'
    WHEN 'PG' THEN 'Plan guide'
    WHEN 'PK' THEN 'Primary Key'
    WHEN 'R' THEN 'Rule (old-style, stand-alone)'
    WHEN 'RF' THEN 'Replication-filter procedure'
    WHEN 'S' THEN 'System base table'
    WHEN 'SN' THEN 'Synonym'
    WHEN 'SO' THEN 'Sequence Object'
    WHEN 'ST' THEN 'STATS_TREE'
    WHEN 'SQ' THEN 'Service Queue'
    WHEN 'TA' THEN 'Assembly (CLR) DML trigger'
    WHEN 'TF' THEN 'SQL table-valued-function'
    WHEN 'TR' THEN 'SQL DML trigger'
    WHEN 'TT' THEN 'Table type'
    WHEN 'UQ' THEN 'UNIQUE Constraint'
    WHEN 'U' THEN 'User Table'
    WHEN 'V' THEN 'View'
    WHEN 'X' THEN 'Extended stored procedure'
    ELSE obj.type
  END
 ,COUNT(*) ObjCount
FROM sys.objects obj
GROUP BY obj.type
ORDER BY ObjCount DESC; 


use Departments
SELECT OBJECT_SCHEMA_NAME([object_id]) AS [SchemaName],
       OBJECT_NAME([object_id]) AS [ObjectName],
       *
FROM   sys.sql_modules 
where  upper(OBJECT_NAME([object_id])) = 'VW_USER_SECURITY_RPT'


