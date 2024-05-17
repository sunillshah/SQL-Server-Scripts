DECLARE @cnt int = 0, @index int;
DECLARE @viewNames table (number int, name varchar(max))
DECLARE @viewGen table (id uniqueidentifier, gen int, name varchar(max), parentId uniqueidentifier)

INSERT INTO @viewNames
SELECT ROW_NUMBER() OVER(ORDER BY object_Id), name FROM sys.views


SELECT @cnt = COUNT(*) FROM @viewNames
SET @index = @cnt;
WHILE ((SELECT COUNT(*) FROM @viewGen) < @cnt)
BEGIN
 DECLARE @viewName varchar(200)
 SELECT @viewName = name FROM @viewNames WHERE number = @index;

 DECLARE @depCnt int = 0;
 SELECT @depCnt = COUNT(*) FROM sys.dm_sql_referencing_entities ('dbo.' + @viewName, 'OBJECT')
 IF (@depCnt = 0)
 BEGIN
  INSERT INTO @viewGen SELECT NEWID(), 0, name, null FROM @viewNames WHERE number = @index;
 END
 ELSE
 BEGIN
  IF EXISTS(SELECT * FROM sys.dm_sql_referencing_entities ('dbo.' + @viewName, 'OBJECT') AS r INNER JOIN @viewGen AS v ON r.referencing_entity_name = v.name)
  BEGIN 
   DECLARE @parentId uniqueidentifier = NEWID();
   INSERT INTO @viewGen SELECT @parentId, 0, name, null FROM @viewNames WHERE number = @index;

   UPDATE v
   SET v.gen = (v.gen + 1), parentId = @parentId
   FROM @viewGen AS v
   INNER JOIN sys.dm_sql_referencing_entities('dbo.' + @viewName, 'OBJECT') AS r ON r.referencing_entity_name = v.name

   UPDATE @viewGen
   SET gen = gen + 1
   WHERE Id = parentId OR parentId IN (SELECT Id FROM @viewGen WHERE parentId = parentId)

  END

 END
 SET @index = @index - 1
 IF (@index < 0) BEGIN SET @index = @cnt; END
END

SELECT gen as [order], name FROM @viewGen ORDER BY gen