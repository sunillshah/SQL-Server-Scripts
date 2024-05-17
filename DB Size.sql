DECLARE @dbsize TABLE (
  Dbname sysname,
  dbstatus varchar(50),
  Recovery_Model varchar(40) DEFAULT ('NA'),
  file_Size_MB decimal(30, 2) DEFAULT (0),
  Space_Used_MB decimal(30, 2) DEFAULT (0),
  Free_Space_MB decimal(30, 2) DEFAULT (0)
)

INSERT INTO @dbsize (Dbname, dbstatus, Recovery_Model, file_Size_MB, Space_Used_MB, Free_Space_MB)
EXEC sp_msforeachdb 'use [?]; 
  select DB_NAME() AS DbName, 
    CONVERT(varchar(20),DatabasePropertyEx(''?'',''Status'')) ,  
    CONVERT(varchar(20),DatabasePropertyEx(''?'',''Recovery'')),  
sum(size)/128.0 AS File_Size_MB, 
sum(CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT))/128.0 as Space_Used_MB, 
SUM( size)/128.0 - sum(CAST(FILEPROPERTY(name,''SpaceUsed'') AS INT))/128.0 AS Free_Space_MB  
from sys.database_files  where type=0 group by type'

select sum(file_Size_MB),sum(Space_Used_MB), sum(free_space_mb)  From @dbsize

EXEC sp_helpdb;

EXEC sp_databases;

SELECT
    name,
    size,
    size * 8/1024 'Size (MB)',
    max_size
FROM sys.master_files;


SELECT 
    [DESCRIPTION] = A.TYPE_DESC
    ,[FILE_Name] = A.name
    ,[FILEGROUP_NAME] = fg.name
    ,[File_Location] = A.PHYSICAL_NAME
    ,[FILESIZE] = CONVERT(DECIMAL(10,2),A.SIZE/128.0) * 1024 * 1024
    ,[USEDSPACE] = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0)) * 1024 * 1024
    ,[FREESPACE] = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0) * 1024 * 1024
    ,[FREESPACE_%] = CONVERT(DECIMAL(10,2),((A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0)/(A.SIZE/128.0))*100)
FROM sys.database_files A LEFT JOIN sys.filegroups fg ON A.data_space_id = fg.data_space_id 
--WHERE A.type_desc LIKE 'ROWS'
order by A.TYPE desc, A.NAME;  

-- Transaction Log Space 
CREATE PROC dbo.spSQLPerf 
AS 
DBCC SQLPERF(logspace) 
GO 
  
CREATE TABLE dbo.logSpaceStats 
( 
   id INT IDENTITY (1,1), 
   logDate datetime DEFAULT GETDATE(), 
   databaseName sysname, 
   logSize decimal(18,5), 
   logUsed decimal(18,5) 
) 
GO 
 
CREATE PROC dbo.spGetSQLPerfStats 
AS 
SET NOCOUNT ON 

CREATE TABLE #tFileList 
( 
   databaseName sysname, 
   logSize decimal(18,5), 
   logUsed decimal(18,5), 
   status INT 
) 

INSERT INTO #tFileList 
       EXEC spSQLPerf 

INSERT INTO logSpaceStats (databaseName, logSize, logUsed) 
SELECT databasename, logSize, logUsed 
FROM #tFileList 

DROP TABLE #tFileList 
GO
