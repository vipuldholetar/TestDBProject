CREATE TABLE [dbo].[CreativeStaging] (
    [CreativeStagingID] INT            IDENTITY (1, 1) NOT NULL,
    [AdID]              INT            NULL,
    [Deleted]           BIT            CONSTRAINT [DF_CreativeMasterStg_Deleted] DEFAULT ((0)) NOT NULL,
    [Event]             INT            NULL,
    [Theme]             INT            NULL,
    [SaleStartDT]       DATETIME       NULL,
    [SaleEndDT]         DATETIME       NULL,
    [Flash]             BIT            NULL,
    [National]          BIT            NULL,
    [CreatedDT]         DATETIME       CONSTRAINT [DF_CreativeMasterStg_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [DeleteDT]          DATETIME       NULL,
    [OccurrenceID]      INT            NULL,
    [CreativeSignature] VARCHAR (250)  NULL,
    [OldID]             INT            NULL,
    [PatternID]         INT            NULL,
    [AssetThmbnlName]   VARCHAR (1000) NULL,
    [ThmbnlRep]         VARCHAR (1000) NULL,
    [ThmbnlFileType]    VARCHAR (50)   NULL,
    CONSTRAINT [PK_CreativeMasterStg] PRIMARY KEY CLUSTERED ([CreativeStagingID] ASC),
    CONSTRAINT [FK_CreativeStaging_To_Pattern] FOREIGN KEY ([PatternID]) REFERENCES [dbo].[Pattern] ([PatternID])
);


GO
CREATE NONCLUSTERED INDEX [IX_CreativeStaging_CreativeSignature]
    ON [dbo].[CreativeStaging]([CreativeSignature] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CreativeStaging_Pattern]
    ON [dbo].[CreativeStaging]([PatternID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CreativeStaging_Occurrence]
    ON [dbo].[CreativeStaging]([OccurrenceID] ASC)
    INCLUDE([CreativeStagingID]);


GO

CREATE TRIGGER [dbo].[CreativeStaging_AuditTrail] ON [dbo].[CreativeStaging] 
FOR INSERT, UPDATE, DELETE
AS
BEGIN
DECLARE @TableNameParm varchar(250)
DECLARE @TableName varchar (250)
DECLARE @LogDMLOperation varchar (250)
DECLARE @KeyName varchar (250)
DECLARE @FieldName varchar (250)
DECLARE @field int
DECLARE @maxfield int 
DECLARE @bit int

DECLARE @sql varchar (max)
DECLARE @sql1 varchar (max)
DECLARE @sql2 varchar (max)
DECLARE @sql3 varchar (max)

SET NOCOUNT ON; 

SET @TableName = 'CreativeStaging'

SELECT @KeyName = COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS a, INFORMATION_SCHEMA.KEY_COLUMN_USAGE b
WHERE a.TABLE_NAME = @TableName
AND a.CONSTRAINT_TYPE = 'PRIMARY KEY'
AND b.TABLE_NAME = a.TABLE_NAME
AND b.CONSTRAINT_NAME = a.CONSTRAINT_NAME
 
SELECT * INTO #ins FROM INSERTED
SELECT * INTO #del FROM DELETED

IF EXISTS (SELECT * FROM INSERTED) AND
   EXISTS (SELECT * FROM DELETED)
   BEGIN
       SET @LogDMLOperation = 'U' --/ for UPDATEs
       SET @SQL3 = ' FROM #ins i LEFT JOIN #del d ON i.' + @KeyName + '=d.' + @KeyName
   END
--/ Devs, please account later for tables with NO PK
ELSE
IF EXISTS (SELECT * FROM INSERTED)
BEGIN
       SET @LogDMLOperation = 'I' --/ for INSERTs
       SET @SQL3 = ' FROM #ins i'
END
ELSE
BEGIN
       SET @LogDMLOperation = 'D' --/ for DELETEs
       SET @SQL3 = ' FROM #del i'
END
--ENDIF
 
--SELECT @LogDMLOperation
 
SET @SQL1 = 'INSERT INTO ' + @TableName + 'Log' + ' ('
SET @SQL1 = @SQL1 +  '            LogTimeStamp, LogDMLOperation, LoginUser'
 
SET @SQL2 = ') SELECT CURRENT_TIMESTAMP, ''' + @LogDMLOperation + ''', ''' + CURRENT_USER + ''''

SELECT @field = 1,
       @maxfield = MAX(ORDINAL_POSITION)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @TableName
 
WHILE @field <= @maxfield
BEGIN
     SET @bit = ((@field - 1) %  8) + 1
     SET @bit = POWER(2, @bit - 1)
 
     SELECT @fieldname = '[' + COLUMN_NAME +']'
     FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_NAME = @TableName
     AND ORDINAL_POSITION = @field
 
     SET @SQL1 = @SQL1 + ',' + @fieldname 
     IF @fieldname <> @KeyName AND @LogDMLOperation = 'U' --THEN           --/ non PK
              SET @SQL1 = @SQL1 + ', OldVal_' + @fieldname 
            --ENDIF

 Set @SQL1 = replace(@SQL1, 'OldVal_[', '[OldVal_')

     SET @SQL2 = @SQL2 + ',i.' + @fieldname  --/ assumption here that if no update, the value is both in INSERT and DELETE.
     --IF SUBSTRING(COLUMNS_UPDATED(),@field, 1) > 0 AND @bit > 0 AND @LogDMLOperation = 'U'
     IF  @LogDMLOperation = 'U'
              IF @fieldname <> @KeyName         --/ non PK
                     SET @SQL2 = @SQL2 + ',d.' + @fieldname 
       --ENDIF
             --ENDIF
 
     SET @field = @field + 1
END
 
SET @SQL = @SQL1 + @SQL2 + @SQL3

EXEC (@SQL)
END
