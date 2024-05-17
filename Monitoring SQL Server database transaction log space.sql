/*Monitoring SQL Server database transaction log space
Below is a simple way of beginning this process.  There are three pieces of code here:

Stored Procedure spSQLPerf - the only purpose of this command is to be able to send the output from the DBCC command into a temporary table
Table logSpaceStats - this will store the long term stats data
Stored Procedure spGetSQLPerfStats - this calls spSQLPerf and inserts the data into table logSpaceStats*/

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