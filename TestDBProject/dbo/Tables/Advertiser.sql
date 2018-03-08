CREATE TABLE [dbo].[Advertiser] (
    [AdvertiserID]        INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Descrip]             VARCHAR (35)  NULL,
    [ShortName]           VARCHAR (35)  NULL,
    [TradeClassID]        INT           NULL,
    [StartDT]             DATETIME      NULL,
    [EndDT]               DATETIME      NULL,
    [Priority]            INT           NULL,
    [LanguageID]          INT           NULL,
    [AdvertiserComments]  VARCHAR (250) NULL,
    [Address1]            VARCHAR (MAX) NULL,
    [Address2]            VARCHAR (MAX) NULL,
    [City]                VARCHAR (MAX) NULL,
    [State]               VARCHAR (MAX) NULL,
    [ZipCode]             VARCHAR (MAX) NULL,
    [CreatedDT]           DATETIME      DEFAULT (getdate()) NULL,
    [CreatedByID]         INT           NULL,
    [ModifiedDT]          DATETIME      NULL,
    [ModifiedByID]        INT           NULL,
    [IndustryID]          INT           NULL,
    [ParentAdvertiserID]  INT           NULL,
    [CTLegacyINSTCOD]     VARCHAR (6)   NULL,
    [MTLegacyRetID]       INT           NULL,
    [CTLegacyINSEQ]       INT           NULL,
    [CTLegacyINSTATE]     VARCHAR (9)   NULL,
    [CTLegacyINCNTRY]     VARCHAR (3)   NULL,
    [CTLegacyINPARENT]    VARCHAR (20)  NULL,
    [CTLegacyINSHORTNAME] VARCHAR (35)  NULL,
    [MTLegacyLanguageID]  INT           NULL,
    [MTLegacyPriority]    INT           NULL,
    CONSTRAINT [PK_RET] PRIMARY KEY CLUSTERED ([AdvertiserID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_Descrip]
    ON [dbo].[Advertiser]([Descrip] ASC)
    INCLUDE([AdvertiserID]);


GO
CREATE NONCLUSTERED INDEX [IX_Advertiser_IDTradeClass]
    ON [dbo].[Advertiser]([AdvertiserID] ASC, [TradeClassID] ASC)
    INCLUDE([Descrip]);


GO
CREATE TRIGGER [dbo].[Advertiser_AuditTrail] ON [dbo].[Advertiser] 
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

SET @TableName = 'Advertiser'

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
 
     SELECT @fieldname = COLUMN_NAME
     FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_NAME = @TableName
     AND ORDINAL_POSITION = @field
 
     SET @SQL1 = @SQL1 + ',' + @fieldname 
     IF @fieldname <> @KeyName AND @LogDMLOperation = 'U' --THEN           --/ non PK
              SET @SQL1 = @SQL1 + ', OldVal_' + @fieldname 
            --ENDIF
 
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