-- List views in all databases
SELECT
    DB_NAME() AS DatabaseName,
    OBJECT_SCHEMA_NAME(v.object_id) AS SchemaName,
    v.name AS ViewName
FROM
    sys.views AS v;

CREATE PROCEDURE usp_list_views
(
    @schema_name AS VARCHAR(MAX) = NULL,
    @view_name AS VARCHAR(MAX) = NULL
)
AS
BEGIN
    SELECT
        DB_NAME() AS DatabaseName,
        OBJECT_SCHEMA_NAME(v.object_id) AS SchemaName,
        v.name AS ViewName
    FROM
        sys.views AS v
    WHERE
        (@schema_name IS NULL OR OBJECT_SCHEMA_NAME(v.object_id) LIKE '%' + @schema_name + '%')
        AND (@view_name IS NULL OR v.name LIKE '%' + @view_name + '%');
END;

EXEC usp_list_views @view_name = 'sales';



Select session_id,
wait_type,
wait_duration_ms,
blocking_session_id,
resource_description,
      ResourceType = Case
                            When Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 1 % 8088 = 0 Then 'Is PFS Page'
                            When Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 2 % 511232 = 0 Then 'Is GAM Page'
                            When Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 3 % 511232 = 0 Then 'Is SGAM Page'
                            Else 'Is Not PFS, GAM, or SGAM page'
                     End
From sys.dm_os_waiting_tasks
Where wait_type Like 'PAGE%LATCH_%'
    And resource_description Like '2:%'