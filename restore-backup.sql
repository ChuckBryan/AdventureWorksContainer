DECLARE @BackupPath NVARCHAR(500) = '/tmp/AdventureWorksLT2017.bak'
DECLARE @DataFilePath NVARCHAR(500) = '/var/opt/mssql/data/'
DECLARE @LogFilepath NVARCHAR(500) = '/var/opt/mssql/data/'

DECLARE @DataLogicalName NVARCHAR(128)
DECLARE @LogLogicalName NVARCHAR(128)

-- Get Logical Names from the backup into a temporary table
CREATE TABLE #FileList (
                           LogicalName NVARCHAR(128),
                           PhysicalName NVARCHAR(260),
    [Type] CHAR(1),
    FileGroupName NVARCHAR(128),
    Size NUMERIC(20,0),
    MaxSize NUMERIC(20,0),
    FileId INT,
    CreateLSN NUMERIC(25,0),
    DropLSN NUMERIC(25,0),
    UniqueId UNIQUEIDENTIFIER,
    ReadOnlyLSN NUMERIC(25,0),
    ReadWriteLSN NUMERIC(25,0),
    BackupSizeInBytes BIGINT,
    SourceBlockSize INT,
    FileGroupId INT,
    LogGroupGUID UNIQUEIDENTIFIER,
    DifferentialBaseLSN NUMERIC(25,0),
    DifferentialBaseGUID UNIQUEIDENTIFIER,
    IsReadOnly BIT,
    IsPresent BIT,
    TDEThumbprint VARBINARY(32)
    )

    INSERT INTO #FileList
EXEC('RESTORE FILELISTONLY FROM DISK = ''' + @BackupPath + '''')

-- Extract logical names for data and log files
SELECT @DataLogicalName = LogicalName FROM #FileList WHERE [Type] = 'D'
SELECT @LogLogicalName = LogicalName FROM #FileList WHERE [Type] = 'L'

-- Construct the restore script using the extracted names
DECLARE @SQL NVARCHAR(MAX)
SET @SQL = 'RESTORE DATABASE [AdventureWorks] FROM DISK = ''' + @BackupPath + ''' 
            WITH FILE = 1, 
            MOVE ''' + @DataLogicalName + ''' TO ''' + @DataFilePath + 'AdventureWorks.mdf'', 
            MOVE ''' + @LogLogicalName + ''' TO ''' + @LogFilepath + 'AdventureWorks.ldf'', 
            NOUNLOAD, REPLACE, STATS = 5'

-- Execute the restore script
EXEC sp_executesql @SQL

-- Cleanup
DROP TABLE #FileList