WITH cteDependencies AS (
    SELECT e.referencing_id object_id, e.referencing_id, e.referenced_id, e.referenced_schema_name, e.referenced_entity_name
    FROM sys.sql_expression_dependencies e
    WHERE e.referencing_id = OBJECT_ID('dbo.vs_employee_details_user_sec_rpt')
    UNION ALL
    SELECT d.object_id, e.referencing_id, e.referenced_id, e.referenced_schema_name, e.referenced_entity_name
    FROM sys.sql_expression_dependencies e
    JOIN cteDependencies d ON d.referenced_id = e.referencing_id AND e.referenced_id <> e.referencing_id
)
SELECT OBJECT_NAME(d.object_id) source_name, d.*
    FROM cteDependencies d
    JOIN sys.all_objects o ON d.referenced_id = o.object_id;


/*USE Boxer_Entities

select * 
from 
   sys.procedures 
where 
   name like '%Sp%_Entities_%ByEntityId%'

WITH cteDependencies AS (
    SELECT e.referencing_id object_id, e.referencing_id, e.referenced_id, e.referenced_schema_name, e.referenced_entity_name
    FROM sys.sql_expression_dependencies e
    WHERE e.referencing_id = OBJECT_ID('dbo.vs_employee_details_user_sec_rpt')
    UNION ALL
    SELECT d.object_id, e.referencing_id, e.referenced_id, e.referenced_schema_name, e.referenced_entity_name
    FROM sys.sql_expression_dependencies e
    JOIN cteDependencies d ON d.referenced_id = e.referencing_id AND e.referenced_id <> e.referencing_id
)
SELECT OBJECT_NAME(d.object_id) source_name, d.*
    FROM cteDependencies d
    JOIN sys.all_objects o ON d.referenced_id = o.object_id;
    
	WHERE o.[type] IN ('P','FN','TF');*/    